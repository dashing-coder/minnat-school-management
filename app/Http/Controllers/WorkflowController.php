<?php
namespace App\Http\Controllers;

use App\Services\LedgerPostingService;
use App\Support\SmsAccess;
use App\Support\SmsAudit;
use App\Support\SmsMoney;
use App\Support\SmsWorkflowCatalog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

/** Explicit transactional ERP workflows. Never use generic register editing for money or results. */
final class WorkflowController
{
    private const LABELS=['student_id'=>'name','employee_id'=>'name','exam_paper_id'=>'id','student_invoice_id'=>'invoice_no',
        'library_copy_id'=>'barcode','library_loan_id'=>'id','hifz_enrollment_id'=>'id','hostel_bed_id'=>'bed_code',
        'payment_refund_id'=>'id','student_payment_id'=>'reference_no','bank_account_id'=>'bank_name','payroll_run_id'=>'id',
        'student_leave_request_id'=>'id','staff_leave_request_id'=>'id','from_enrollment_id'=>'id','admission_cycle_id'=>'title','academic_session_id'=>'name',
        'examination_id'=>'name','grading_scale_id'=>'name','fee_head_id'=>'name',
        'admission_application_id'=>'applicant_name'];

    private function definition(string $flow): array
    {
        $definition=SmsWorkflowCatalog::find($flow);abort_unless($definition,404);
        SmsAccess::require($definition['permission']);
        return $definition;
    }

    private function tenantRow(string $table,int $id,bool $lock=false): object
    {
        $q=SmsAccess::scopedQuery($table)->where($table.'.id',$id);
        if ($lock)$q->lockForUpdate();
        $row=$q->first();
        if (!$row)throw ValidationException::withMessages(['record'=>'The selected record does not belong to your authorized institution/campus.']);
        return $row;
    }
    private function allCampusesOnly(): void
    {
        abort_unless((int) SmsAccess::membership()->can_access_all_campuses === 1,403,'This institution-wide operation requires all-campus authorization.');
    }
    private function invoiceReceivable(object $invoice): int
    {
        // Prevent posting payments/refunds to a different receivables account
        // than was used when the original invoice was posted.
        $journal=DB::table('ledger_journals')->where('institution_id',SmsAccess::institutionId())
            ->where(function($q)use($invoice){
                $q->where(fn($x)=>$x->where('source_type','fee_invoice')->where('source_reference',(string)$invoice->id))
                  ->orWhere(fn($x)=>$x->where('source_type','invoice')->where('source_reference',$invoice->invoice_no));
            })->where('status','posted')->first();
        if(!$journal)throw ValidationException::withMessages(['student_invoice_id'=>'Invoice is missing its posted general-ledger entry.']);
        $accountId=DB::table('ledger_lines')->where('institution_id',SmsAccess::institutionId())
            ->where('ledger_journal_id',$journal->id)->where('debit','>',0)->value('account_id');
        if(!$accountId)throw ValidationException::withMessages(['student_invoice_id'=>'Invoice receivables account is not identifiable.']);
        $this->account((int)$accountId,'asset');
        return (int)$accountId;
    }
    private function paymentCashAccount(object $payment): int
    {
        $journal=DB::table('ledger_journals')->where('institution_id',SmsAccess::institutionId())
            ->where(fn($q)=>$q->where(fn($x)=>$x->where('source_type','fee_payment')->where('source_reference',(string)$payment->id))
                ->orWhere(fn($x)=>$x->where('source_type','payment')->where('source_reference',$payment->reference_no)))
            ->where('status','posted')->first();
        if(!$journal)throw ValidationException::withMessages(['payment_refund_id'=>'Original payment journal not found.']);
        $accountId=DB::table('ledger_lines')->where('institution_id',SmsAccess::institutionId())
            ->where('ledger_journal_id',$journal->id)->where('debit','>',0)->value('account_id');
        if(!$accountId)throw ValidationException::withMessages(['payment_refund_id'=>'Original cash/bank account not found.']);
        $this->account((int)$accountId,'asset');
        return (int)$accountId;
    }
    private function account(int $id,string $expectedType): object
    {
        $this->allCampusesOnly();
        $a=$this->tenantRow('chart_of_accounts',$id);
        if(!(bool)$a->is_active || $a->account_type !== $expectedType)
            throw ValidationException::withMessages(['account_id'=>"Select an active {$expectedType} account."]);
        return $a;
    }
    public function show(string $flow)
    {
        $def=$this->definition($flow);$options=[];
        foreach($def['fields'] as $name=>$spec) {
            if($spec[0]!== 'select')continue;
            $table=$spec[1];
            abort_unless(Schema::hasTable($table),500);
            $rows=SmsAccess::scopedQuery($table)->orderByDesc($table.'.id')->limit(500)->get();
            $options[$name]=$rows->map(function($r)use($name){
                $label=$r->{self::LABELS[$name] ?? 'name'} ?? $r->name ?? $r->title ?? $r->code ?? ('#'.$r->id);
                return ['id'=>(int)$r->id,'label'=>(string)$label.' (#'.$r->id.')'];
            })->all();
        }
        return view('workflows.form',compact('flow','def','options'));
    }
    public function store(Request $request,string $flow,LedgerPostingService $ledger)
    {
        $def=$this->definition($flow);
        $rules=[];
        foreach($def['fields'] as $name=>$spec) {
            $rules[$name]=match($spec[0]) {
                'select'=>['required','integer','min:1'],
                'number','percent','money'=>['required','numeric','min:0'],
                'optional_number'=>['nullable','numeric','min:0'],
                'integer'=>['required','integer','min:0'],
                'date'=>['required','date_format:Y-m-d'],
                'time'=>['required','date_format:H:i'],
                'optional_text'=>['nullable','string','max:3000'],
                'choices'=>['required',Rule::in(array_keys($spec[1]))],
                default=>['required','string','min:1','max:190']
            };
        }
        $data=$request->validate($rules);
        foreach($def['fields'] as $name=>$spec){
            if($spec[0]==='select') $this->tenantRow($spec[1],(int)$data[$name]);
            if($spec[0]==='money') {
                try { if(SmsMoney::cents((string)$data[$name])<1 && $name!=='monthly_fee')throw new \InvalidArgumentException(); }
                catch (\InvalidArgumentException $e) { throw ValidationException::withMessages([$name=>'Enter a valid non-negative amount with at most 2 decimals.']); }
            }
        }
        $result=DB::transaction(function() use($flow,$data,$ledger) {
            return match($flow) {
                'admission-application'=>$this->admission($data),
                'admission-offer'=>$this->admissionOffer($data),
                'admission-confirm'=>$this->admissionConfirm($data),
                'student-enrollment'=>$this->enroll($data),
                'timetable-create'=>$this->timetable($data),
                'student-promotion'=>$this->promote($data),
                'exam-mark'=>$this->mark($data),
                'publish-results'=>$this->publish($data),
                'fee-invoice'=>$this->invoice($data,$ledger),
                'fee-payment'=>$this->payment($data,$ledger),
                'refund-request'=>$this->refundRequest($data),
                'refund-approve'=>$this->refundApprove($data,$ledger),
                'bank-reconcile'=>$this->bankReconcile($data),
                'payroll-run'=>$this->payroll($data),
                'payroll-approve'=>$this->payrollApprove($data),
                'library-issue'=>$this->issue($data),
                'library-return'=>$this->returnBook($data),
                'hifz-progress'=>$this->hifz($data),
                'inventory-movement'=>$this->stock($data),
                'donation-receipt'=>$this->donation($data,$ledger),
                'certificate-issue'=>$this->certificate($data),
                'hostel-allocation'=>$this->hostel($data),
                'student-leave'=>$this->leave($data,'student_leave_requests','student_id'),
                'staff-leave'=>$this->leave($data,'staff_leave_requests','employee_id'),
                'student-leave-review'=>$this->reviewLeave($data,'student_leave_requests','student_leave_request_id'),
                'staff-leave-review'=>$this->reviewLeave($data,'staff_leave_requests','staff_leave_request_id'),
                'transport-assign'=>$this->transport($data),
                default=>abort(404),
            };
        }, 3);
        return redirect()->route('workflow.show',$flow)->with('success',$result);
    }
    private function insert(string $table,array $data,string $action): int
    {
        $id=DB::table($table)->insertGetId(array_merge($data,['institution_id'=>SmsAccess::institutionId(),'created_at'=>now(),'updated_at'=>now()]));
        SmsAudit::record($action,$table,$id);
        return $id;
    }
    private function admission(array $d): string
    {
        $cycle=$this->tenantRow('admission_cycles',(int)$d['admission_cycle_id']);
        $level=$this->tenantRow('class_levels',(int)$d['class_level_id']);
        if(DB::table('admission_applications')->where('institution_id',SmsAccess::institutionId())->where('application_no',$d['application_no'])->exists())
            throw ValidationException::withMessages(['application_no'=>'Application number is already in use.']);
        $id=$this->insert('admission_applications',[
            'admission_cycle_id'=>$cycle->id,'class_level_id'=>$level->id,'application_no'=>$d['application_no'],
            'applicant_name'=>$d['applicant_name'],'guardian_phone'=>$d['guardian_phone'],
            'score'=>$d['score']??null,'status'=>'submitted'
        ],'admission.application');
        return "Application #{$id} submitted.";
    }
    private function admissionOffer(array $d): string
    {
        $app=$this->tenantRow('admission_applications',(int)$d['admission_application_id'],true);
        if($app->status!=='submitted')throw ValidationException::withMessages(['admission_application_id'=>'Only submitted applications can receive a new offer.']);
        $cycle=$this->tenantRow('admission_cycles',(int)$app->admission_cycle_id);
        if($d['offered_on']<$cycle->opens_on)throw ValidationException::withMessages(['offered_on'=>'Offer date precedes admission cycle opening.']);
        $id=$this->insert('admission_offers',['admission_application_id'=>$app->id,'student_id'=>null,'offered_on'=>$d['offered_on'],'status'=>'offered'],'admission.offer');
        DB::table('admission_applications')->where('institution_id',SmsAccess::institutionId())->where('id',$app->id)->update(['status'=>'offered','updated_at'=>now()]);
        return "Offer #{$id} created. Register the student before confirming.";
    }
    private function admissionConfirm(array $d): string
    {
        $app=$this->tenantRow('admission_applications',(int)$d['admission_application_id'],true);
        $student=$this->tenantRow('students',(int)$d['student_id']);
        if($app->status!=='offered')throw ValidationException::withMessages(['admission_application_id'=>'Application must have an outstanding offer.']);
        $offer=DB::table('admission_offers')->where('institution_id',SmsAccess::institutionId())->where('admission_application_id',$app->id)
            ->where('status','offered')->lockForUpdate()->first();
        $cycle=$this->tenantRow('admission_cycles',(int)$app->admission_cycle_id);
        if(!$offer || (int)$student->campus_id !== (int)$cycle->campus_id)
            throw ValidationException::withMessages(['student_id'=>'Student must belong to the same campus as the admission cycle.']);
        DB::table('admission_offers')->where('institution_id',SmsAccess::institutionId())->where('id',$offer->id)
            ->update(['student_id'=>$student->id,'status'=>'accepted','updated_at'=>now()]);
        DB::table('admission_applications')->where('institution_id',SmsAccess::institutionId())->where('id',$app->id)
            ->update(['status'=>'accepted','updated_at'=>now()]);
        SmsAudit::record('admission.accept','admission_offers',$offer->id);
        return "Admission offer #{$offer->id} accepted for student #{$student->id}.";
    }
    private function enroll(array $d): string
    {
        $student=$this->tenantRow('students',(int)$d['student_id'],true);
        $section=$this->tenantRow('class_sections',(int)$d['class_section_id']);
        $session=$this->tenantRow('academic_sessions',(int)$d['academic_session_id']);
        if((int)$section->campus_id !== (int)$student->campus_id || $student->status!=='active'||$session->status==='closed')
            throw ValidationException::withMessages(['student_id'=>'Student and class must share a campus, be active, and the session must be open.']);
        $existing=DB::table('enrollments')->where('institution_id',SmsAccess::institutionId())
            ->where('student_id',$student->id)->where('academic_session_id',$session->id)->where('status','active')->exists();
        if($existing) throw ValidationException::withMessages(['student_id'=>'Student already has an active enrollment for this session.']);
        $id=$this->insert('enrollments',[
            'student_id'=>$student->id,'academic_session_id'=>$session->id,'class_section_id'=>$section->id,
            'roll_no'=>$d['roll_no'],'status'=>'active'
        ],'student.enroll');
        return "Enrollment #{$id} created.";
    }
    private function promote(array $d): string
    {
        $previous=$this->tenantRow('enrollments',(int)$d['from_enrollment_id'],true);
        if($previous->status!=='active')throw ValidationException::withMessages(['from_enrollment_id'=>'Only active enrollments can be promoted.']);
        $student=$this->tenantRow('students',(int)$previous->student_id,true);
        $newSession=$this->tenantRow('academic_sessions',(int)$d['academic_session_id']);
        $section=$this->tenantRow('class_sections',(int)$d['class_section_id']);
        if((int)$section->campus_id!==(int)$student->campus_id || $newSession->status==='closed'
            || (int)$previous->academic_session_id === (int)$newSession->id)
            throw ValidationException::withMessages(['academic_session_id'=>'Choose a different open session and section from the same campus.']);
        if(DB::table('enrollments')->where('institution_id',SmsAccess::institutionId())->where('student_id',$student->id)
            ->where('academic_session_id',$newSession->id)->where('status','active')->exists())
            throw ValidationException::withMessages(['academic_session_id'=>'An active enrollment already exists in this session.']);
        $newId=$this->insert('enrollments',[
            'student_id'=>$student->id,'academic_session_id'=>$newSession->id,'class_section_id'=>$section->id,
            'roll_no'=>$d['roll_no'],'status'=>'active'
        ],'student.promotion.enrollment');
        DB::table('enrollments')->where('institution_id',SmsAccess::institutionId())->where('id',$previous->id)
            ->update(['status'=>'promoted','updated_at'=>now()]);
        $id=$this->insert('student_promotions',[
            'student_id'=>$student->id,'from_enrollment_id'=>$previous->id,'to_enrollment_id'=>$newId,
            'promoted_on'=>$d['promoted_on'],'status'=>'completed'
        ],'student.promote');
        return "Promotion #{$id} completed. Original academic enrollment retained.";
    }
    private function timetable(array $d): string
    {
        $section=$this->tenantRow('class_sections',(int)$d['class_section_id'],true);
        $subject=$this->tenantRow('class_subjects',(int)$d['class_subject_id']);
        if((int)$section->class_level_id!==(int)$subject->class_level_id)
            throw ValidationException::withMessages(['class_subject_id'=>'Subject does not belong to the chosen class level.']);
        if($d['ends_at']<=$d['starts_at'])throw ValidationException::withMessages(['ends_at'=>'End time must be after start time.']);
        $room=trim((string)$d['room']);
        $q=DB::table('class_routines')->where('institution_id',SmsAccess::institutionId())
            ->where('day_of_week',$d['day_of_week'])->where('starts_at','<',$d['ends_at'])->where('ends_at','>',$d['starts_at']);
        if((clone $q)->where('class_section_id',$section->id)->exists())
            throw ValidationException::withMessages(['starts_at'=>'Overlapping lesson already exists in this class section.']);
        if((clone $q)->join('class_sections as cs',function($j){
            $j->on('cs.id','=','class_routines.class_section_id')->on('cs.institution_id','=','class_routines.institution_id');
        })->where('cs.campus_id',$section->campus_id)->where('room',$room)->exists())
            throw ValidationException::withMessages(['room'=>'Room is already booked during this time.']);
        $teacherIds=DB::table('teacher_assignments')->where('institution_id',SmsAccess::institutionId())
            ->where('class_subject_id',$subject->id)->where('academic_session_id',$subject->academic_session_id)
            ->pluck('employee_id')->all();
        if($teacherIds) {
            $conflict=(clone $q)->join('teacher_assignments as t',function($j){
                $j->on('t.class_subject_id','=','class_routines.class_subject_id')->on('t.institution_id','=','class_routines.institution_id');
            })->where('t.academic_session_id',$subject->academic_session_id)->whereIn('t.employee_id',$teacherIds)->exists();
            if($conflict)throw ValidationException::withMessages(['starts_at'=>'Assigned teacher already has a lesson at this time.']);
        }
        $id=$this->insert('class_routines',[
            'class_section_id'=>$section->id,'class_subject_id'=>$subject->id,'day_of_week'=>$d['day_of_week'],
            'starts_at'=>$d['starts_at'],'ends_at'=>$d['ends_at'],'room'=>$room
        ],'academics.timetable.create');
        return "Class lesson #{$id} scheduled without detected conflicts.";
    }
    private function mark(array $d): string
    {
        $paper=$this->tenantRow('exam_papers',(int)$d['exam_paper_id']);
        $exam=$this->tenantRow('examinations',(int)$paper->examination_id,true);
        if($exam->status==='published')throw ValidationException::withMessages(['exam_paper_id'=>'Published examinations are locked.']);
        $student=$this->tenantRow('students',(int)$d['student_id']);
        if((float)$d['marks']>(float)$paper->full_marks)throw ValidationException::withMessages(['marks'=>'Mark exceeds full marks.']);
        $enrolled=DB::table('enrollments as e')
            ->join('class_sections as s',fn($join)=>$join->on('s.id','=','e.class_section_id')->on('s.institution_id','=','e.institution_id'))
            ->where('e.institution_id',SmsAccess::institutionId())->where('e.student_id',$student->id)
            ->where('e.academic_session_id',$exam->academic_session_id)->where('s.class_level_id',$exam->class_level_id)
            ->where('e.status','active')->exists();
        if(!$enrolled) throw ValidationException::withMessages(['student_id'=>'Student is not actively enrolled in this examination class/session.']);
        DB::table('exam_marks')->updateOrInsert([
            'institution_id'=>SmsAccess::institutionId(),'exam_paper_id'=>$paper->id,'student_id'=>$student->id
        ],['marks'=>$d['marks'],'status'=>'draft','updated_at'=>now(),'created_at'=>now()]);
        SmsAudit::record('exam.mark','exam_marks',$student->id,['paper_id'=>$paper->id]);
        return 'Student mark saved as draft.';
    }
    private function publish(array $d): string
    {
        $this->allCampusesOnly();
        $exam=$this->tenantRow('examinations',(int)$d['examination_id'],true);
        $scale=$this->tenantRow('grading_scales',(int)$d['grading_scale_id']);
        if($exam->status==='published')throw ValidationException::withMessages(['examination_id'=>'Examination has already been published.']);
        $papers=DB::table('exam_papers')->where('institution_id',SmsAccess::institutionId())->where('examination_id',$exam->id)->get();
        if($papers->isEmpty())throw ValidationException::withMessages(['examination_id'=>'There are no exam papers.']);
        $bands=DB::table('grading_bands')->where('institution_id',SmsAccess::institutionId())
            ->where('grading_scale_id',$scale->id)->orderBy('min_percent','desc')->get();
        if($bands->isEmpty())throw ValidationException::withMessages(['grading_scale_id'=>'Add grading bands before publishing.']);
        $students=DB::table('enrollments as e')->join('class_sections as s',fn($j)=>$j->on('s.id','=','e.class_section_id')->on('s.institution_id','=','e.institution_id'))
            ->where('e.institution_id',SmsAccess::institutionId())->where('e.academic_session_id',$exam->academic_session_id)
            ->where('s.class_level_id',$exam->class_level_id)->where('e.status','active')->distinct()->pluck('e.student_id');
        if($students->isEmpty())throw ValidationException::withMessages(['examination_id'=>'No eligible students are enrolled.']);
        $count=0;
        foreach($students as $studentId) {
            $total=0.;$scored=0.;$passed=true;
            foreach($papers as $paper){
                $mark=DB::table('exam_marks')->where('institution_id',SmsAccess::institutionId())
                    ->where('exam_paper_id',$paper->id)->where('student_id',$studentId)->first();
                if(!$mark)throw ValidationException::withMessages(['examination_id'=>"Marks incomplete for student #{$studentId}; no results published."]);
                $total+=(float)$paper->full_marks;$scored+=(float)$mark->marks;
                if((float)$mark->marks<(float)$paper->pass_marks)$passed=false;
            }
            $pct=$total>0?round(($scored/$total)*100,2):0;
            $band=$bands->first(fn($b)=>(float)$b->min_percent<=$pct && (float)$b->max_percent>=$pct);
            if(!$band)throw ValidationException::withMessages(['grading_scale_id'=>"Grading bands do not cover {$pct}%."]);
            $gpa=$passed?(float)$band->grade_point:0;
            DB::table('published_results')->updateOrInsert([
                'institution_id'=>SmsAccess::institutionId(),'examination_id'=>$exam->id,'student_id'=>$studentId,
            ],['percentage'=>$pct,'gpa'=>$gpa,'result'=>$passed?'pass':'fail','status'=>'published',
                'updated_at'=>now(),'created_at'=>now()]);
            $count++;
        }
        DB::table('examinations')->where('institution_id',SmsAccess::institutionId())->where('id',$exam->id)
            ->update(['status'=>'published','updated_at'=>now()]);
        SmsAudit::record('exam.publish','examinations',$exam->id,['student_count'=>$count]);
        return "Exam results published for {$count} students.";
    }
    private function invoice(array $d,LedgerPostingService $ledger): string
    {
        $this->allCampusesOnly();
        $student=$this->tenantRow('students',(int)$d['student_id']);
        $head=$this->tenantRow('fee_heads',(int)$d['fee_head_id']);
        $this->account((int)$d['receivable_account_id'],'asset');
        $income=$this->account((int)$head->revenue_account_id,'income');
        if($d['due_on']<$d['issued_on'])throw ValidationException::withMessages(['due_on'=>'Due date must be on or after issue date.']);
        if(DB::table('student_invoices')->where('institution_id',SmsAccess::institutionId())->where('invoice_no',$d['invoice_no'])->exists())
            throw ValidationException::withMessages(['invoice_no'=>'Invoice number is already used.']);
        $amount=SmsMoney::decimal(SmsMoney::cents((string)$d['amount']));
        $id=$this->insert('student_invoices',[
            'student_id'=>$student->id,'invoice_no'=>$d['invoice_no'],'issued_on'=>$d['issued_on'],'due_on'=>$d['due_on'],
            'total_amount'=>$amount,'paid_amount'=>'0.00','status'=>'unpaid'
        ],'fee.invoice');
        $this->insert('student_invoice_lines',['student_invoice_id'=>$id,'fee_head_id'=>$head->id,
            'description'=>$head->name,'amount'=>$amount],'fee.invoice.line');
        $ledger->post('fee_invoice',(string)$id,'Fee invoice '.$d['invoice_no'],$d['issued_on'],[
            ['account_id'=>(int)$d['receivable_account_id'],'debit'=>$amount,'credit'=>'0.00'],
            ['account_id'=>(int)$income->id,'debit'=>'0.00','credit'=>$amount],
        ]);
        return "Fee invoice #{$id} issued and posted to ledger.";
    }
    private function payment(array $d,LedgerPostingService $ledger): string
    {
        $this->allCampusesOnly();
        $invoice=$this->tenantRow('student_invoices',(int)$d['student_invoice_id'],true);
        $method=$this->tenantRow('payment_methods',(int)$d['payment_method_id']);
        $this->account((int)$d['cash_account_id'],'asset');
        $receivableAccount=$this->invoiceReceivable($invoice);
        if ((int)$d['cash_account_id']===$receivableAccount) throw ValidationException::withMessages(['cash_account_id'=>'Cash account must differ from the invoice receivables account.']);
        $cents=SmsMoney::cents((string)$d['amount']);
        $left=SmsMoney::cents((string)$invoice->total_amount)-SmsMoney::cents((string)$invoice->paid_amount);
        if($cents>$left || $left<1)throw ValidationException::withMessages(['amount'=>'Payment exceeds outstanding invoice amount.']);
        if(DB::table('student_payments')->where('institution_id',SmsAccess::institutionId())->where('reference_no',$d['reference_no'])->exists())
            throw ValidationException::withMessages(['reference_no'=>'Payment reference already exists; duplicate rejected.']);
        $amount=SmsMoney::decimal($cents);
        $id=$this->insert('student_payments',[
            'student_id'=>$invoice->student_id,'student_invoice_id'=>$invoice->id,'payment_method_id'=>$method->id,
            'amount'=>$amount,'paid_on'=>$d['paid_on'],'reference_no'=>$d['reference_no'],'status'=>'posted',
        ],'fee.payment');
        $this->insert('payment_allocations',[
            'student_payment_id'=>$id,'student_invoice_id'=>$invoice->id,'amount'=>$amount,
        ],'fee.payment.allocation');
        $newPaid=SmsMoney::cents((string)$invoice->paid_amount)+$cents;
        DB::table('student_invoices')->where('institution_id',SmsAccess::institutionId())->where('id',$invoice->id)->update([
            'paid_amount'=>SmsMoney::decimal($newPaid),'status'=>$newPaid===SmsMoney::cents((string)$invoice->total_amount)?'paid':'partial',
            'updated_at'=>now()
        ]);
        $ledger->post('fee_payment',(string)$id,'Fee payment '.$d['reference_no'],$d['paid_on'],[
            ['account_id'=>(int)$d['cash_account_id'],'debit'=>$amount,'credit'=>'0.00'],
            ['account_id'=>$receivableAccount,'debit'=>'0.00','credit'=>$amount],
        ]);
        return "Payment #{$id} allocated and posted to ledger.";
    }
    private function refundRequest(array $d): string
    {
        $this->allCampusesOnly();
        $payment=$this->tenantRow('student_payments',(int)$d['student_payment_id'],true);
        $prior=DB::table('payment_refunds')->where('institution_id',SmsAccess::institutionId())
            ->where('student_payment_id',$payment->id)->whereIn('status',['requested','approved','processed'])
            ->get()->sum(fn($x)=>SmsMoney::cents((string)$x->amount));
        $requested=SmsMoney::cents((string)$d['amount']);
        if($requested+$prior>SmsMoney::cents((string)$payment->amount))
            throw ValidationException::withMessages(['amount'=>'Refund exceeds remaining refundable amount.']);
        $id=$this->insert('payment_refunds',['student_payment_id'=>$payment->id,
            'amount'=>SmsMoney::decimal($requested),'reason'=>$d['reason'],'status'=>'requested'],'refund.request');
        return "Refund request #{$id} pending independent approval.";
    }
    private function refundApprove(array $d,LedgerPostingService $ledger): string
    {
        $this->allCampusesOnly();
        $refund=$this->tenantRow('payment_refunds',(int)$d['payment_refund_id'],true);
        if($refund->status!=='requested')throw ValidationException::withMessages(['payment_refund_id'=>'Refund is not awaiting approval.']);
        $originalActor=DB::table('sms_audit_logs')->where('institution_id',SmsAccess::institutionId())
            ->where('action','refund.request')->where('resource_type','payment_refunds')->where('resource_id',(string)$refund->id)
            ->orderByDesc('id')->value('actor_user_id');
        if($originalActor && (int)$originalActor===(int)auth()->id())
            throw ValidationException::withMessages(['payment_refund_id'=>'A different authorized user must approve this refund.']);
        $payment=$this->tenantRow('student_payments',(int)$refund->student_payment_id,true);
        $invoice=$this->tenantRow('student_invoices',(int)$payment->student_invoice_id,true);
        $receivableAccount=$this->invoiceReceivable($invoice);
        $cashAccount=$this->paymentCashAccount($payment);
        $amount=SmsMoney::cents((string)$refund->amount);
        $paid=SmsMoney::cents((string)$invoice->paid_amount);
        if($amount>$paid)throw ValidationException::withMessages(['payment_refund_id'=>'Refund exceeds invoice paid balance.']);
        $dec=SmsMoney::decimal($amount);
        $ledger->post('fee_refund',(string)$refund->id,'Refund for payment #'.$payment->id,$d['refunded_on'],[
            ['account_id'=>$receivableAccount,'debit'=>$dec,'credit'=>'0.00'],
            ['account_id'=>$cashAccount,'debit'=>'0.00','credit'=>$dec],
        ]);
        DB::table('payment_refunds')->where('institution_id',SmsAccess::institutionId())->where('id',$refund->id)->update(['status'=>'approved','updated_at'=>now()]);
        $net=$paid-$amount;
        DB::table('student_invoices')->where('institution_id',SmsAccess::institutionId())->where('id',$invoice->id)
            ->update(['paid_amount'=>SmsMoney::decimal($net),'status'=>$net===0?'unpaid':'partial','updated_at'=>now()]);
        SmsAudit::record('refund.approve','payment_refunds',$refund->id);
        return "Refund #{$refund->id} approved and financial reversal journal created.";
    }
    private function bankReconcile(array $d): string
    {
        $this->allCampusesOnly();
        $bank=$this->tenantRow('bank_accounts',(int)$d['bank_account_id']);
        $account=$this->account((int)$bank->account_id,'asset');
        $lines=DB::table('ledger_lines as l')->join('ledger_journals as j',function($join){$join->on('j.id','=','l.ledger_journal_id')->on('j.institution_id','=','l.institution_id');})
            ->where('l.institution_id',SmsAccess::institutionId())->where('l.account_id',$account->id)
            ->where('j.status','posted')->whereDate('j.posted_on','<=',$d['statement_on'])
            ->selectRaw('COALESCE(SUM(l.debit),0) AS debits, COALESCE(SUM(l.credit),0) AS credits')->first();
        $ledgerCents=SmsMoney::cents((string)$lines->debits)-SmsMoney::cents((string)$lines->credits);
        $statementCents=SmsMoney::cents((string)$d['statement_balance']);
        $status=$ledgerCents===$statementCents?'matched':'variance';
        $id=$this->insert('bank_reconciliations',[
            'bank_account_id'=>$bank->id,'statement_on'=>$d['statement_on'],
            'statement_balance'=>SmsMoney::decimal($statementCents),
            'ledger_balance'=>SmsMoney::decimal($ledgerCents),'status'=>$status,
        ],'accounting.reconcile');
        return "Bank comparison #{$id}: {$status}. Variances require manual reconciliation.";
    }
    private function payrollApprove(array $d): string
    {
        $this->allCampusesOnly();
        $run=$this->tenantRow('payroll_runs',(int)$d['payroll_run_id'],true);
        if($run->status!=='draft')throw ValidationException::withMessages(['payroll_run_id'=>'Only draft payroll batches can be approved.']);
        $generator=DB::table('sms_audit_logs')->where('institution_id',SmsAccess::institutionId())
            ->where('action','payroll.draft')->where('resource_type','payroll_runs')->where('resource_id',(string)$run->id)
            ->orderByDesc('id')->value('actor_user_id');
        if($generator && (int)$generator===(int)auth()->id())
            throw ValidationException::withMessages(['payroll_run_id'=>'A separate authorized approver is required.']);
        DB::table('payroll_runs')->where('institution_id',SmsAccess::institutionId())->where('id',$run->id)->update(['status'=>'approved','updated_at'=>now()]);
        DB::table('payslips')->where('institution_id',SmsAccess::institutionId())->where('payroll_run_id',$run->id)->update(['status'=>'approved','updated_at'=>now()]);
        SmsAudit::record('payroll.approve','payroll_runs',$run->id);
        return "Payroll #{$run->id} approved. Payment disbursement remains a separate task.";
    }
    private function reviewLeave(array $d,string $table,string $key): string
    {
        $row=$this->tenantRow($table,(int)$d[$key],true);
        if($row->status!=='pending')throw ValidationException::withMessages([$key=>'Leave request has already been reviewed.']);
        DB::table($table)->where('institution_id',SmsAccess::institutionId())->where('id',$row->id)->update(['status'=>$d['decision'],'updated_at'=>now()]);
        SmsAudit::record('leave.review',$table,$row->id,['decision'=>$d['decision']]);
        return 'Leave request #'.$row->id.' '.$d['decision'].'.';
    }
    private function payroll(array $d): string
    {
        $this->allCampusesOnly();
        if($d['period_end']<$d['period_start'])throw ValidationException::withMessages(['period_end'=>'Payroll end must follow start.']);
        $dup=DB::table('payroll_runs')->where('institution_id',SmsAccess::institutionId())
            ->where('period_start','<=',$d['period_end'])->where('period_end','>=',$d['period_start'])->exists();
        if($dup)throw ValidationException::withMessages(['period_start'=>'Payroll already overlaps this period.']);
        $staff=DB::table('employees')->where('institution_id',SmsAccess::institutionId())->where('status','active')->get();
        if($staff->isEmpty())throw ValidationException::withMessages(['period_start'=>'No active employees found.']);
        $id=$this->insert('payroll_runs',['period_start'=>$d['period_start'],'period_end'=>$d['period_end'],'status'=>'draft'],'payroll.draft');
        foreach($staff as $employee){
            $gross=SmsMoney::decimal(SmsMoney::cents((string)$employee->basic_salary));
            $p=$this->insert('payslips',['payroll_run_id'=>$id,'employee_id'=>$employee->id,
                'gross_amount'=>$gross,'deduction_amount'=>'0.00','net_amount'=>$gross,'status'=>'draft'],'payroll.payslip');
            $this->insert('payslip_items',['payslip_id'=>$p,'item_type'=>'earning','description'=>'Basic salary','amount'=>$gross],'payroll.payslip.item');
        }
        return "Draft payroll #{$id} generated for {$staff->count()} employees; not yet approved or paid.";
    }
    private function issue(array $d): string
    {
        $copy=$this->tenantRow('library_copies',(int)$d['library_copy_id'],true);
        $student=$this->tenantRow('students',(int)$d['student_id']);
        if($copy->status!=='available')throw ValidationException::withMessages(['library_copy_id'=>'This book copy is not available.']);
        if($d['due_on']<$d['issued_on'])throw ValidationException::withMessages(['due_on'=>'Due date cannot precede issue date.']);
        $id=$this->insert('library_loans',['library_copy_id'=>$copy->id,'student_id'=>$student->id,
            'issued_on'=>$d['issued_on'],'due_on'=>$d['due_on'],'fine_amount'=>'0.00','status'=>'issued'],'library.loan');
        DB::table('library_copies')->where('institution_id',SmsAccess::institutionId())->where('id',$copy->id)
            ->update(['status'=>'issued','updated_at'=>now()]);
        return "Book loan #{$id} created.";
    }
    private function returnBook(array $d): string
    {
        $loan=$this->tenantRow('library_loans',(int)$d['library_loan_id'],true);
        if($loan->status!=='issued')throw ValidationException::withMessages(['library_loan_id'=>'This loan is already closed.']);
        if($d['returned_on']<$loan->issued_on)throw ValidationException::withMessages(['returned_on'=>'Return cannot precede issue date.']);
        $copy=$this->tenantRow('library_copies',(int)$loan->library_copy_id,true);
        DB::table('library_loans')->where('institution_id',SmsAccess::institutionId())->where('id',$loan->id)->update([
            'status'=>'returned','returned_on'=>$d['returned_on'],'updated_at'=>now()
        ]);
        DB::table('library_copies')->where('institution_id',SmsAccess::institutionId())->where('id',$copy->id)->update(['status'=>'available','updated_at'=>now()]);
        SmsAudit::record('library.return','library_loans',$loan->id);
        return "Loan #{$loan->id} returned.";
    }
    private function hifz(array $d): string
    {
        $enroll=$this->tenantRow('hifz_enrollments',(int)$d['hifz_enrollment_id']);
        if($enroll->status!=='active'||(int)$d['juz_completed']>(int)$enroll->target_juz || (float)$d['accuracy_percent']>100)
            throw ValidationException::withMessages(['accuracy_percent'=>'Hifz enrollment must be active; accuracy <=100% and Juz cannot exceed target.']);
        $id=$this->insert('hifz_progress_logs',[
            'hifz_enrollment_id'=>$enroll->id,'logged_on'=>$d['logged_on'],'sabaq'=>$d['sabaq'],
            'sabqi'=>$d['sabqi'],'manzil'=>$d['manzil'],'juz_completed'=>$d['juz_completed'],
            'accuracy_percent'=>$d['accuracy_percent'],'notes'=>$d['notes']??null
        ],'hifz.progress');
        return "Hifz progress #{$id} saved.";
    }
    private function stock(array $d): string
    {
        $item=$this->tenantRow('inventory_items',(int)$d['inventory_item_id'],true);
        if((int)$d['quantity']<1)throw ValidationException::withMessages(['quantity'=>'Quantity must be positive.']);
        $duplicate=DB::table('stock_movements')->where('institution_id',SmsAccess::institutionId())->where('inventory_item_id',$item->id)
            ->where('reference_no',$d['reference_no'])->exists();
        if($duplicate)throw ValidationException::withMessages(['reference_no'=>'This item already has a movement with that reference.']);
        $balance=(int)DB::table('stock_movements')->where('institution_id',SmsAccess::institutionId())->where('inventory_item_id',$item->id)->sum('quantity');
        $change=$d['movement_type']==='out'?-(int)$d['quantity']:(int)$d['quantity'];
        if($balance+$change<0)throw ValidationException::withMessages(['quantity'=>'Insufficient stock. Current balance: '.$balance]);
        $id=$this->insert('stock_movements',[
            'inventory_item_id'=>$item->id,'quantity'=>$change,'movement_type'=>$d['movement_type'],
            'reference_no'=>$d['reference_no'],'moved_on'=>$d['moved_on'],
        ],'inventory.movement');
        return "Movement #{$id} saved. Current stock: ".($balance+$change).'.';
    }
    private function donation(array $d,LedgerPostingService $ledger): string
    {
        $this->allCampusesOnly();
        $donor=$this->tenantRow('donors',(int)$d['donor_id']);
        $fund=$this->tenantRow('donation_funds',(int)$d['donation_fund_id']);
        $this->account((int)$d['cash_account_id'],'asset');
        $this->account((int)$d['income_account_id'],'income');
        if(DB::table('donations')->where('institution_id',SmsAccess::institutionId())->where('receipt_no',$d['receipt_no'])->exists())
            throw ValidationException::withMessages(['receipt_no'=>'Receipt number exists.']);
        $amount=SmsMoney::decimal(SmsMoney::cents((string)$d['amount']));
        $id=$this->insert('donations',[
            'donor_id'=>$donor->id,'donation_fund_id'=>$fund->id,'receipt_no'=>$d['receipt_no'],
            'amount'=>$amount,'received_on'=>$d['received_on'],
        ],'donation.receive');
        $ledger->post('donation',(string)$id,'Donation '.$d['receipt_no'].' (fund #'.$fund->id.')',$d['received_on'],[
            ['account_id'=>(int)$d['cash_account_id'],'debit'=>$amount,'credit'=>'0.00'],
            ['account_id'=>(int)$d['income_account_id'],'debit'=>'0.00','credit'=>$amount],
        ]);
        return "Donation receipt #{$id} created and posted; confirm restricted-fund reporting requirements before production use.";
    }
    private function certificate(array $d): string
    {
        $student=$this->tenantRow('students',(int)$d['student_id']);
        $template=$this->tenantRow('certificate_templates',(int)$d['certificate_template_id']);
        if($template->status!=='active')throw ValidationException::withMessages(['certificate_template_id'=>'Template must be active.']);
        if(DB::table('issued_certificates')->where('institution_id',SmsAccess::institutionId())->where('certificate_no',$d['certificate_no'])->exists())
            throw ValidationException::withMessages(['certificate_no'=>'Certificate number is already used.']);
        $id=$this->insert('issued_certificates',[
            'student_id'=>$student->id,'certificate_template_id'=>$template->id,'certificate_no'=>$d['certificate_no'],
            'issued_on'=>$d['issued_on'],'verification_token'=>Str::random(48),'status'=>'issued'
        ],'certificate.issue');
        return "Certificate #{$id} issued.";
    }
    private function hostel(array $d): string
    {
        $student=$this->tenantRow('students',(int)$d['student_id'],true);
        $bed=$this->tenantRow('hostel_beds',(int)$d['hostel_bed_id'],true);
        $room=$this->tenantRow('hostel_rooms',(int)$bed->hostel_room_id);
        $hostel=$this->tenantRow('hostels',(int)$room->hostel_id);
        if((int)$student->campus_id !== (int)$hostel->campus_id || $bed->status!=='available')
            throw ValidationException::withMessages(['hostel_bed_id'=>'The student/hostel campus differs, or the bed is occupied.']);
        if(DB::table('hostel_allocations')->where('institution_id',SmsAccess::institutionId())->where('student_id',$student->id)->where('status','active')->exists())
            throw ValidationException::withMessages(['student_id'=>'Student already has an active bed assignment.']);
        $id=$this->insert('hostel_allocations',[
            'student_id'=>$student->id,'hostel_bed_id'=>$bed->id,'check_in_on'=>$d['check_in_on'],
            'monthly_fee'=>SmsMoney::decimal(SmsMoney::cents((string)$d['monthly_fee'])),'status'=>'active',
        ],'hostel.allocation');
        DB::table('hostel_beds')->where('institution_id',SmsAccess::institutionId())->where('id',$bed->id)
            ->update(['status'=>'occupied','updated_at'=>now()]);
        return "Bed allocation #{$id} created.";
    }
    private function leave(array $d,string $table,string $subject): string
    {
        if($d['ends_on']<$d['starts_on'])throw ValidationException::withMessages(['ends_on'=>'End date must not precede start.']);
        $id=$this->insert($table,[$subject=>$d[$subject],
            'starts_on'=>$d['starts_on'],'ends_on'=>$d['ends_on'],'reason'=>$d['reason'],'status'=>'pending',
        ],'leave.request');
        return "Leave request #{$id} submitted; approval workflow remains to be configured.";
    }
    private function transport(array $d): string
    {
        $student=$this->tenantRow('students',(int)$d['student_id']);
        $route=$this->tenantRow('transport_routes',(int)$d['transport_route_id']);
        $stop=$this->tenantRow('transport_stops',(int)$d['transport_stop_id']);
        if((int)$stop->transport_route_id !== (int)$route->id)
            throw ValidationException::withMessages(['transport_stop_id'=>'Stop does not belong to selected route.']);
        $id=$this->insert('student_transport_assignments',[
            'student_id'=>$student->id,'transport_route_id'=>$route->id,'transport_stop_id'=>$stop->id,
            'starts_on'=>$d['starts_on'],'monthly_fee'=>SmsMoney::decimal(SmsMoney::cents((string)$d['monthly_fee'])),
        ],'transport.assign');
        return "Transport assignment #{$id} created.";
    }
}
