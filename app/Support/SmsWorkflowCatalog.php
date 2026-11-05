<?php
namespace App\Support;

final class SmsWorkflowCatalog
{
    // The operation catalog is intentionally explicit. No dynamic table insert is allowed.
    public const ITEMS = [
        'admission-application'=>['label'=>'Register admission application','module'=>'admissions','permission'=>'admissions.manage','description'=>'Create an applicant record linked to a configured admission cycle.','fields'=>[
            'admission_cycle_id'=>['select','admission_cycles'],'class_level_id'=>['select','class_levels'],
            'application_no'=>['text'],'applicant_name'=>['text'],'guardian_phone'=>['text'],'score'=>['optional_number'],
        ]],
        'admission-offer'=>['label'=>'Approve admission offer','module'=>'admissions','permission'=>'admissions.manage','description'=>'Create an offer only for an eligible submitted application.','fields'=>[
            'admission_application_id'=>['select','admission_applications'],'offered_on'=>['date'],
        ]],
        'admission-confirm'=>['label'=>'Confirm admission against student ID','module'=>'admissions','permission'=>'admissions.manage','description'=>'Confirm a previously offered application against an existing authorized student record.','fields'=>[
            'admission_application_id'=>['select','admission_applications'],'student_id'=>['select','students'],
        ]],
        'student-enrollment'=>['label'=>'Enroll student','module'=>'lifecycle','permission'=>'students.update','description'=>'Assign an existing student to a session and class section.','fields'=>[
            'student_id'=>['select','students'],'academic_session_id'=>['select','academic_sessions'],'class_section_id'=>['select','class_sections'],'roll_no'=>['text'],
        ]],
        'timetable-create'=>['label'=>'Schedule conflict-free lesson','module'=>'academics','permission'=>'academics.manage','description'=>'Checks class, room and assigned-teacher overlaps before saving.','fields'=>[
            'class_section_id'=>['select','class_sections'],'class_subject_id'=>['select','class_subjects'],
            'day_of_week'=>['choices',['Monday'=>'Monday','Tuesday'=>'Tuesday','Wednesday'=>'Wednesday','Thursday'=>'Thursday','Friday'=>'Friday','Saturday'=>'Saturday','Sunday'=>'Sunday']],
            'starts_at'=>['time'],'ends_at'=>['time'],'room'=>['text'],
        ]],
        'exam-mark'=>['label'=>'Enter examination mark','module'=>'exams','permission'=>'marks.enter','description'=>'Marks cannot exceed the paper maximum. Published examinations are locked.','fields'=>[
            'exam_paper_id'=>['select','exam_papers'],'student_id'=>['select','students'],'marks'=>['number'],
        ]],
        'publish-results'=>['label'=>'Calculate and publish results','module'=>'exams','permission'=>'results.publish','description'=>'Computes scores from all papers and snapshots verified, complete results.','fields'=>[
            'examination_id'=>['select','examinations'],'grading_scale_id'=>['select','grading_scales'],
        ]],
        'fee-invoice'=>['label'=>'Issue fee invoice & journal','module'=>'finance','permission'=>'fees.adjust','description'=>'Creates a fee invoice and balanced receivable/revenue journal.','fields'=>[
            'student_id'=>['select','students'],'fee_head_id'=>['select','fee_heads'],
            'receivable_account_id'=>['select','chart_of_accounts'],'invoice_no'=>['text'],
            'amount'=>['money'],'issued_on'=>['date'],'due_on'=>['date'],
        ]],
        'fee-payment'=>['label'=>'Collect payment & journal','module'=>'finance','permission'=>'fees.collect','description'=>'Records a payment exactly once, allocates it to the invoice, and updates the general ledger.','fields'=>[
            'student_invoice_id'=>['select','student_invoices'],'payment_method_id'=>['select','payment_methods'],
            'cash_account_id'=>['select','chart_of_accounts'],
            'amount'=>['money'],'reference_no'=>['text'],'paid_on'=>['date'],
        ]],
        'refund-request'=>['label'=>'Request fee refund','module'=>'finance','permission'=>'refunds.request','description'=>'Create a pending refund request; no cash changes before separate approval.','fields'=>[
            'student_payment_id'=>['select','student_payments'],'amount'=>['money'],'reason'=>['text'],
        ]],
        'refund-approve'=>['label'=>'Approve and post refund','module'=>'finance','permission'=>'refunds.approve','description'=>'Requires a second approver, applies cash/receivable reversal, and updates invoice balance.','fields'=>[
            'payment_refund_id'=>['select','payment_refunds'],
            'refunded_on'=>['date'],
        ]],
        'bank-reconcile'=>['label'=>'Reconcile bank account','module'=>'finance','permission'=>'accounting.reconcile','description'=>'Compares statement balance to the posted general ledger as of a selected date.','fields'=>[
            'bank_account_id'=>['select','bank_accounts'],'statement_on'=>['date'],'statement_balance'=>['money'],
        ]],
        'payroll-run'=>['label'=>'Generate draft payroll','module'=>'hr','permission'=>'payroll.process','description'=>'Creates payslips from active employees at their basic salary. Payroll approval and disbursement are separate.','fields'=>[
            'period_start'=>['date'],'period_end'=>['date'],
        ]],
        'payroll-approve'=>['label'=>'Approve payroll batch','module'=>'hr','permission'=>'payroll.approve','description'=>'Approves draft payroll; does not initiate bank disbursement.','fields'=>[
            'payroll_run_id'=>['select','payroll_runs'],
        ]],
        'library-issue'=>['label'=>'Issue library book','module'=>'library','permission'=>'library.manage','description'=>'Prevents lending an unavailable copy.','fields'=>[
            'library_copy_id'=>['select','library_copies'],'student_id'=>['select','students'],'issued_on'=>['date'],'due_on'=>['date'],
        ]],
        'library-return'=>['label'=>'Return library book','module'=>'library','permission'=>'library.manage','description'=>'Returns an active loan and makes its copy available.','fields'=>[
            'library_loan_id'=>['select','library_loans'],'returned_on'=>['date'],
        ]],
        'hifz-progress'=>['label'=>'Record Hifz lesson progress','module'=>'hifz','permission'=>'hifz.progress.record','description'=>'Logs new lessons, recent revision, long revision and completion progress.','fields'=>[
            'hifz_enrollment_id'=>['select','hifz_enrollments'],'logged_on'=>['date'],
            'sabaq'=>['text'],'sabqi'=>['text'],'manzil'=>['text'],'juz_completed'=>['integer'],'accuracy_percent'=>['percent'],'notes'=>['optional_text'],
        ]],
        'inventory-movement'=>['label'=>'Record stock movement','module'=>'inventory','permission'=>'inventory.manage','description'=>'Stock cannot become negative. Uses signed immutable stock movements.','fields'=>[
            'inventory_item_id'=>['select','inventory_items'],'movement_type'=>['choices',['in'=>'Stock in','out'=>'Stock out']],
            'quantity'=>['integer'],'reference_no'=>['text'],'moved_on'=>['date'],
        ]],
        'donation-receipt'=>['label'=>'Receive donation & journal','module'=>'scholarship','permission'=>'donations.manage','description'=>'Records a designated-fund donation and posts balanced cash/revenue entries.','fields'=>[
            'donor_id'=>['select','donors'],'donation_fund_id'=>['select','donation_funds'],
            'cash_account_id'=>['select','chart_of_accounts'],'income_account_id'=>['select','chart_of_accounts'],
            'receipt_no'=>['text'],'amount'=>['money'],'received_on'=>['date'],
        ]],
        'certificate-issue'=>['label'=>'Issue verified certificate','module'=>'certificates','permission'=>'institutions.manage','description'=>'Issue an unguessable verification token with a unique certificate number.','fields'=>[
            'student_id'=>['select','students'],'certificate_template_id'=>['select','certificate_templates'],'certificate_no'=>['text'],'issued_on'=>['date'],
        ]],
        'hostel-allocation'=>['label'=>'Allocate residential bed','module'=>'residential','permission'=>'hostel.manage','description'=>'Allocates only vacant beds to authorized students in the same campus.','fields'=>[
            'student_id'=>['select','students'],'hostel_bed_id'=>['select','hostel_beds'],'check_in_on'=>['date'],'monthly_fee'=>['money'],
        ]],
        'student-leave'=>['label'=>'Request student leave','module'=>'attendance','permission'=>'attendance.record','description'=>'Records a pending student leave request for review.','fields'=>[
            'student_id'=>['select','students'],'starts_on'=>['date'],'ends_on'=>['date'],'reason'=>['text'],
        ]],
        'staff-leave'=>['label'=>'Request staff leave','module'=>'hr','permission'=>'payroll.process','description'=>'Records a pending employee leave request.','fields'=>[
            'employee_id'=>['select','employees'],'starts_on'=>['date'],'ends_on'=>['date'],'reason'=>['text'],
        ]],
        'student-leave-review'=>['label'=>'Review student leave','module'=>'attendance','permission'=>'attendance.approve_correction','description'=>'Approve or reject a pending leave request.','fields'=>[
            'student_leave_request_id'=>['select','student_leave_requests'],'decision'=>['choices',['approved'=>'Approve','rejected'=>'Reject']],
        ]],
        'staff-leave-review'=>['label'=>'Review staff leave','module'=>'hr','permission'=>'payroll.approve','description'=>'Approve or reject an employee leave request.','fields'=>[
            'staff_leave_request_id'=>['select','staff_leave_requests'],'decision'=>['choices',['approved'=>'Approve','rejected'=>'Reject']],
        ]],
        'transport-assign'=>['label'=>'Assign student transport','module'=>'residential','permission'=>'hostel.manage','description'=>'Assign a route and matching stop to a student.','fields'=>[
            'student_id'=>['select','students'],'transport_route_id'=>['select','transport_routes'],'transport_stop_id'=>['select','transport_stops'],
            'starts_on'=>['date'],'monthly_fee'=>['money'],
        ]],
        'student-promotion'=>['label'=>'Promote student to new session','module'=>'lifecycle','permission'=>'students.update','description'=>'Closes the previous enrollment and adds a separate historical promotion record.','fields'=>[
            'from_enrollment_id'=>['select','enrollments'],'academic_session_id'=>['select','academic_sessions'],
            'class_section_id'=>['select','class_sections'],'roll_no'=>['text'],'promoted_on'=>['date'],
        ]],
    ];
    public static function find(string $slug): ?array { return self::ITEMS[$slug] ?? null; }
    public static function forModule(string $slug): array { return array_filter(self::ITEMS,fn($x)=>$x['module']===$slug); }
}
