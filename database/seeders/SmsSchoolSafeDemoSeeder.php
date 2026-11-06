<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * Additive data for the *existing* SCHDEMO-only local database.
 * Does not touch users, existing memberships, roles, permissions or passwords.
 * Refuses nonempty operational data. Use backup/staging and explicit opt-in.
 */
final class SmsSchoolSafeDemoSeeder extends Seeder
{
    private int $institutionId;
    private array $counts=[];
    private const DATE='2026-11-05';

    public function run(): void
    {
        if (!app()->environment(['local','testing']) ||
            !filter_var(env('SMS_ALLOW_SCHOOL_DEMO_SEED',false), FILTER_VALIDATE_BOOLEAN)) {
            throw new RuntimeException('School demo seeding requires local/testing and SMS_ALLOW_SCHOOL_DEMO_SEED=true.');
        }
        foreach (['institutions','users','students','campuses','academic_sessions','student_invoices',
                  'ledger_journals','student_payments','employees','sms_permissions','attendance_sessions'] as $table) {
            if (!Schema::hasTable($table)) throw new RuntimeException("Required table missing: {$table}. Run migrations first.");
        }
        $codes=DB::table('institutions')->pluck('code')->all();
        if (count($codes)!==1 || $codes[0]!=='SCHDEMO') {
            throw new RuntimeException('Only the existing single-school SCHDEMO database is supported; no changes made.');
        }
        $school=DB::table('institutions')->where('code','SCHDEMO')->where('status','active')->whereNull('deleted_at')->first();
        if (!$school) throw new RuntimeException('The active SCHDEMO institution does not exist.');
        $this->institutionId=(int)$school->id;
        foreach (['students','enrollments','student_invoices','student_payments','ledger_journals',
                  'employees','attendance_sessions','examinations','admission_applications','library_loans'] as $table) {
            if (DB::table($table)->where('institution_id',$this->institutionId)->exists()) {
                throw new RuntimeException("{$table} already has records. Seeder is deliberately non-destructive and non-repeatable.");
            }
        }
        if (!DB::table('users')->where('email','admin.school@example.test')->exists()) {
            throw new RuntimeException('Expected demo administrator is missing. Existing user account must be repaired separately.');
        }
        DB::transaction(fn()=> $this->populate(),1);
        $this->command?->info('Local fictitious SCHOOL data installed without changing any user or role.');
        foreach ($this->counts as $table=>$count) $this->command?->line("{$table}: {$count}");
        $this->command?->warn('Set SMS_ALLOW_SCHOOL_DEMO_SEED=false. Never run this on real student data.');
    }

    private function add(string $table,array $values): int
    {
        $id=DB::table($table)->insertGetId(array_merge(['institution_id'=>$this->institutionId],$values,
            ['created_at'=>now(),'updated_at'=>now()]));
        $this->counts[$table]=($this->counts[$table]??0)+1;
        return (int)$id;
    }
    private function journal(string $type,string $reference,string $label,int $debitAccount,int $creditAccount,string $amount): void
    {
        $id=$this->add('ledger_journals',['journal_no'=>'DEMO-'.strtoupper(substr(hash('sha256',$type.'|'.$reference),0,14)),
            'posted_on'=>self::DATE,'source_type'=>$type,'source_reference'=>$reference,
            'description'=>$label,'status'=>'posted']);
        $this->add('ledger_lines',['ledger_journal_id'=>$id,'account_id'=>$debitAccount,'debit'=>$amount,'credit'=>'0.00']);
        $this->add('ledger_lines',['ledger_journal_id'=>$id,'account_id'=>$creditAccount,'debit'=>'0.00','credit'=>$amount]);
    }
    private function populate(): void
    {
        $campus=$this->add('campuses',['code'=>'MAIN','name'=>'Sunrise Main Campus','is_main'=>1,'is_active'=>1,
            'address'=>'Fictional campus address (demo only)']);
        $session=$this->add('academic_sessions',['code'=>'2026','name'=>'Academic Year 2026',
            'starts_on'=>'2026-01-01','ends_on'=>'2026-12-31','status'=>'active']);
        $department=$this->add('academic_departments',['campus_id'=>$campus,'code'=>'GENERAL','name'=>'General Education','category'=>'general']);
        $levels=[];$sections=[];
        foreach ([['G06','Grade Six',6],['G07','Grade Seven',7]] as [$code,$name,$seq]) {
            $level=$this->add('class_levels',['program_id'=>null,'code'=>$code,'name'=>$name,'sequence'=>$seq]);
            $levels[]=$level;
            $sections[]=$this->add('class_sections',['campus_id'=>$campus,'class_level_id'=>$level,'code'=>'A',
                'name'=>'Section A','shift'=>'day']);
        }
        $subjects=[];
        foreach ([['BAN','Bangla'],['MATH','Mathematics']] as [$code,$name]) {
            $subjects[]=$this->add('subjects',['department_id'=>$department,'code'=>$code,'name'=>$name,'credit_hours'=>'0.00']);
        }
        $classSubject=[];
        foreach ($subjects as $subjectId) {
            $classSubject[]=$this->add('class_subjects',['class_level_id'=>$levels[0],'subject_id'=>$subjectId,
                'academic_session_id'=>$session,'is_compulsory'=>1]);
        }
        $teacherUser=DB::table('users')->where('email','teacher.school@example.test')->value('id');
        $parentUser=DB::table('users')->where('email','parent.school@example.test')->value('id');
        $studentUser=DB::table('users')->where('email','student.school@example.test')->value('id');
        $teacher=$this->add('employees',['user_id'=>$teacherUser,'campus_id'=>$campus,'employee_no'=>'DEMO-T001',
            'name'=>'Demo Teacher Nabila','designation'=>'Subject Teacher','joined_on'=>'2025-01-01',
            'basic_salary'=>'28000.00','status'=>'active']);
        $accountant=$this->add('employees',['user_id'=>DB::table('users')->where('email','accounts.school@example.test')->value('id'),
            'campus_id'=>$campus,'employee_no'=>'DEMO-A001','name'=>'Demo Accounts Officer','designation'=>'Accountant',
            'joined_on'=>'2025-01-01','basic_salary'=>'30000.00','status'=>'active']);
        foreach($classSubject as $cs) $this->add('teacher_assignments',['employee_id'=>$teacher,
            'class_subject_id'=>$cs,'academic_session_id'=>$session]);
        $cycle=$this->add('admission_cycles',['academic_session_id'=>$session,'campus_id'=>$campus,
            'title'=>'Local Demo Intake 2026','opens_on'=>'2026-01-01','closes_on'=>'2026-12-15']);
        $students=[];
        foreach (['Ayesha Rahman','Shahid Hasan','Nusrat Jahan','Fahim Ahmed','Sadia Akter','Tanvir Hossain',
                  'Mim Sultana','Rahat Islam','Tasnim Khan','Arif Mahmud','Jannat Ferdous','Abir Chowdhury'] as $i=>$name) {
            $student=$this->add('students',['user_id'=>$i===0?$studentUser:null,'campus_id'=>$campus,
                'admission_no'=>sprintf('SCH-DEMO-%03d',$i+1),'name'=>$name,
                'gender'=>$i%2===0?'female':'male','birth_date'=>'2013-04-12','blood_group'=>'B+', 'status'=>'active']);
            $students[]=$student;
            $guardian=$this->add('guardians',['user_id'=>$i===0?$parentUser:null,'name'=>'Guardian '.($i+1),
                'relation'=>'parent','phone'=>sprintf('0170000%04d',$i+1),'email'=>null]);
            $this->add('student_guardians',['student_id'=>$student,'guardian_id'=>$guardian,'relationship'=>'parent','is_primary'=>1]);
            $this->add('enrollments',['student_id'=>$student,'academic_session_id'=>$session,
                'class_section_id'=>$sections[0],'roll_no'=>(string)($i+1),'status'=>'active']);
            if ($i<4) $this->add('admission_applications',['admission_cycle_id'=>$cycle,'class_level_id'=>$levels[0],
                'application_no'=>sprintf('ADM-DEMO-%03d',$i+1),'applicant_name'=>$name,
                'guardian_phone'=>sprintf('0170000%04d',$i+1),'score'=>'85.00','status'=>'approved']);
        }
        foreach(['2026-11-02','2026-11-03','2026-11-04'] as $day) {
            $attendance=$this->add('attendance_sessions',['class_section_id'=>$sections[0],
                'attendance_on'=>$day,'period_code'=>'daily','status'=>'closed']);
            foreach($students as $i=>$student) {
                $status=($i===1 && $day==='2026-11-03')?'absent':(($i===2 && $day==='2026-11-04')?'late':'present');
                $this->add('student_attendance',['attendance_session_id'=>$attendance,'student_id'=>$student,
                    'status'=>$status,'minutes_late'=>$status==='late'?12:0]);
            }
        }
        $grading=$this->add('grading_scales',['code'=>'BD-2026','name'=>'Demo Percentage Grade Scale']);
        foreach ([[0,32.99,'F',0],[33,49.99,'D',1],[50,59.99,'C',2],[60,69.99,'B',3],[70,79.99,'A',4],[80,100,'A+',5]] as $g) {
            $this->add('grading_bands',['grading_scale_id'=>$grading,'min_percent'=>$g[0],
                'max_percent'=>$g[1],'letter_grade'=>$g[2],'grade_point'=>$g[3]]);
        }
        $exam=$this->add('examinations',['academic_session_id'=>$session,'class_level_id'=>$levels[0],
            'name'=>'Demo Midterm','exam_type'=>'midterm','starts_on'=>'2026-10-15','ends_on'=>'2026-10-20','status'=>'published']);
        $papers=[];
        foreach($subjects as $subject) $papers[]=$this->add('exam_papers',['examination_id'=>$exam,
            'subject_id'=>$subject,'full_marks'=>'100.00','pass_marks'=>'33.00']);
        foreach($students as $i=>$student) {
            $total=0;
            foreach($papers as $j=>$paper) {
                $mark=70+$i%12+$j*3;
                $this->add('exam_marks',['exam_paper_id'=>$paper,'student_id'=>$student,'marks'=>(string)$mark,'status'=>'approved']);
                $total+=$mark;
            }
            $pct=round($total/count($papers),2);
            $this->add('published_results',['examination_id'=>$exam,'student_id'=>$student,
                'percentage'=>number_format($pct,2,'.',''),'gpa'=>$pct>=80?'5.00':'4.00',
                'result'=>'pass','status'=>'published']);
        }
        $cash=$this->add('chart_of_accounts',['code'=>'1000','name'=>'Demo Cash','account_type'=>'asset','parent_account_id'=>null,'is_active'=>1]);
        $receivable=$this->add('chart_of_accounts',['code'=>'1100','name'=>'Demo Student Receivables','account_type'=>'asset','parent_account_id'=>null,'is_active'=>1]);
        $revenue=$this->add('chart_of_accounts',['code'=>'4100','name'=>'Demo Tuition Income','account_type'=>'income','parent_account_id'=>null,'is_active'=>1]);
        $giftRevenue=$this->add('chart_of_accounts',['code'=>'4200','name'=>'Demo Donation Income','account_type'=>'income','parent_account_id'=>null,'is_active'=>1]);
        $feeHead=$this->add('fee_heads',['code'=>'TUITION','name'=>'Demo Monthly Tuition','revenue_account_id'=>$revenue]);
        $plan=$this->add('fee_plans',['class_level_id'=>$levels[0],'academic_session_id'=>$session,
            'name'=>'Demo Grade 6 Monthly Plan','status'=>'active']);
        $this->add('fee_plan_lines',['fee_plan_id'=>$plan,'fee_head_id'=>$feeHead,'amount'=>'2500.00']);
        $cashMethod=$this->add('payment_methods',['code'=>'CASH','name'=>'Cash at Desk','method_type'=>'cash']);
        foreach($students as $i=>$student) {
            $invoice=$this->add('student_invoices',['student_id'=>$student,
                'invoice_no'=>sprintf('DEMO-INV-%03d',$i+1),'issued_on'=>self::DATE,'due_on'=>'2026-11-30',
                'total_amount'=>'2500.00','paid_amount'=>$i<6?'1500.00':'0.00','status'=>$i<6?'partial':'unpaid']);
            $this->add('student_invoice_lines',['student_invoice_id'=>$invoice,'fee_head_id'=>$feeHead,
                'description'=>'Demo monthly tuition','amount'=>'2500.00']);
            $this->journal('fee_invoice',(string)$invoice,'Demo invoice '.($i+1),$receivable,$revenue,'2500.00');
            if($i<6) {
                $payment=$this->add('student_payments',['student_id'=>$student,'student_invoice_id'=>$invoice,
                    'payment_method_id'=>$cashMethod,'amount'=>'1500.00','paid_on'=>self::DATE,
                    'reference_no'=>sprintf('DEMO-PAY-%03d',$i+1),'status'=>'posted']);
                $this->add('payment_allocations',['student_payment_id'=>$payment,'student_invoice_id'=>$invoice,'amount'=>'1500.00']);
                $this->journal('fee_payment',(string)$payment,'Demo tuition payment '.($i+1),$cash,$receivable,'1500.00');
            }
        }
        $payroll=$this->add('payroll_runs',['period_start'=>'2026-11-01','period_end'=>'2026-11-30','status'=>'draft']);
        foreach ([[$teacher,'28000.00'],[$accountant,'30000.00']] as [$employee,$salary]) {
            $payslip=$this->add('payslips',['payroll_run_id'=>$payroll,'employee_id'=>$employee,
                'gross_amount'=>$salary,'deduction_amount'=>'0.00','net_amount'=>$salary,'status'=>'draft']);
            $this->add('payslip_items',['payslip_id'=>$payslip,'item_type'=>'earning','description'=>'Basic salary','amount'=>$salary]);
        }
        $book=$this->add('library_books',['isbn'=>null,'title'=>'Mathematics Practice (Demo)',
            'author'=>'Fictional Publisher','category'=>'Academic']);
        $copy=$this->add('library_copies',['library_book_id'=>$book,'barcode'=>'LIB-DEMO-001','status'=>'issued']);
        $this->add('library_loans',['library_copy_id'=>$copy,'student_id'=>$students[0],
            'issued_on'=>'2026-11-01','due_on'=>'2026-11-15','returned_on'=>null,'fine_amount'=>'0.00','status'=>'issued']);
        $item=$this->add('inventory_items',['sku'=>'DEMO-PEN','name'=>'Demo Ballpoint Pen','unit'=>'piece','reorder_level'=>20]);
        $this->add('stock_movements',['inventory_item_id'=>$item,'quantity'=>100,'movement_type'=>'in',
            'reference_no'=>'DEMO-OPEN','moved_on'=>self::DATE]);
        $this->add('stock_movements',['inventory_item_id'=>$item,'quantity'=>-5,'movement_type'=>'out',
            'reference_no'=>'DEMO-ISSUE','moved_on'=>self::DATE]);
        $hostel=$this->add('hostels',['campus_id'=>$campus,'name'=>'Demo Boys Hostel','category'=>'boys']);
        $room=$this->add('hostel_rooms',['hostel_id'=>$hostel,'room_code'=>'R-101','capacity'=>2]);
        $bed=$this->add('hostel_beds',['hostel_room_id'=>$room,'bed_code'=>'B1','status'=>'occupied']);
        $this->add('hostel_beds',['hostel_room_id'=>$room,'bed_code'=>'B2','status'=>'available']);
        $this->add('hostel_allocations',['student_id'=>$students[1],'hostel_bed_id'=>$bed,'check_in_on'=>self::DATE,
            'monthly_fee'=>'1200.00','status'=>'active']);
        $vehicle=$this->add('vehicles',['vehicle_code'=>'BUS-01','plate_number'=>'DEMO-12345','seats'=>30,'status'=>'active']);
        $route=$this->add('transport_routes',['vehicle_id'=>$vehicle,'employee_id'=>null,'route_name'=>'Demo Central Route']);
        $stop=$this->add('transport_stops',['transport_route_id'=>$route,'name'=>'Main Square','stop_order'=>1]);
        $this->add('student_transport_assignments',['student_id'=>$students[2],'transport_route_id'=>$route,
            'transport_stop_id'=>$stop,'starts_on'=>self::DATE,'monthly_fee'=>'700.00']);
        $donor=$this->add('donors',['name'=>'Fictional Community Donor','phone'=>null,'email'=>null]);
        $fund=$this->add('donation_funds',['code'=>'GENERAL','name'=>'Demo General Donation Fund','is_restricted'=>0]);
        $donation=$this->add('donations',['donor_id'=>$donor,'donation_fund_id'=>$fund,'receipt_no'=>'DEMO-DON-001',
            'amount'=>'5000.00','received_on'=>self::DATE]);
        $this->journal('donation',(string)$donation,'Demo general donation',$cash,$giftRevenue,'5000.00');
        $scholarship=$this->add('scholarships',['name'=>'Demo Merit Scholarship','criteria'=>'Fictional demonstration','status'=>'active']);
        $this->add('scholarship_awards',['scholarship_id'=>$scholarship,'student_id'=>$students[0],
            'amount'=>'500.00','status'=>'approved']);
        $template=$this->add('certificate_templates',['code'=>'STUDENT','name'=>'Demo Student Certificate',
            'template_html'=>'<p>Fictional demo certificate</p>','status'=>'active']);
        $this->add('issued_certificates',['student_id'=>$students[0],'certificate_template_id'=>$template,
            'certificate_no'=>'DEMO-CERT-001','issued_on'=>self::DATE,'verification_token'=>Str::random(48),'status'=>'issued']);
        $this->add('notices',['title'=>'Welcome to the demo campus','body'=>'Fictional local test records only.',
            'audience'=>'all','published_at'=>'2026-11-05 09:00:00']);
        $this->add('student_leave_requests',['student_id'=>$students[3],
            'starts_on'=>'2026-11-10','ends_on'=>'2026-11-11','reason'=>'Fictional family event','status'=>'pending']);
        $this->add('staff_attendance',['employee_id'=>$teacher,'attendance_on'=>self::DATE,
            'status'=>'present','check_in_at'=>'2026-11-05 09:00:00']);
        // Assert core financial invariants before committing any of the changes.
        $unbalanced=DB::table('ledger_journals as j')->join('ledger_lines as l','j.id','=','l.ledger_journal_id')
            ->where('j.institution_id',$this->institutionId)->groupBy('j.id')
            ->havingRaw('ABS(SUM(l.debit) - SUM(l.credit)) > 0.009')->count();
        if ($unbalanced) throw new RuntimeException('Demo ledger balance assertion failed; transaction rolled back.');
    }
}
