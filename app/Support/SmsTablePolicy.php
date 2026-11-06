<?php
namespace App\Support;

/** Table-specific access checks for the generic register viewer and CSV export.
 * Sensitive clinical, safeguarding, financial and integration records are not
 * automatically readable just because the parent navigation module is visible.
 */
final class SmsTablePolicy
{
    private const RESTRICTED = [
        'student_health_records' => 'institutions.manage',
        'student_incidents' => 'institutions.manage',
        'welfare_cases' => 'institutions.manage',
        'student_documents' => 'students.update',
        'guardians' => 'students.update',
        'student_guardians' => 'students.update',
        'direct_messages' => 'institutions.manage',
        'notification_deliveries' => 'institutions.manage',
        'integration_connections' => 'institutions.manage',
        'sms_audit_logs' => 'audit.view',
        'institution_memberships' => 'memberships.view',
        'institution_roles' => 'roles.manage',
        'payroll_runs' => 'payroll.process',
        'payslips' => 'payroll.process',
        'payslip_items' => 'payroll.process',
        'staff_appraisals' => 'payroll.process',
        'chart_of_accounts' => 'accounting.reconcile',
        'ledger_journals' => 'accounting.reconcile',
        'ledger_lines' => 'accounting.reconcile',
        'bank_accounts' => 'accounting.reconcile',
        'bank_reconciliations' => 'accounting.reconcile',
        'financial_period_closings' => 'accounting.reconcile',
        'expenses' => 'accounting.reconcile',
        'payment_refunds' => 'refunds.approve',
    ];

    // Positive export allowlist: no arbitrary columns, notes, contact data,
    // bank metadata, student medical data or transactional GL lines in CSV.
    private const EXPORTS = [
        'students' => ['id','admission_no','name','campus_id','status'],
        'enrollments' => ['id','student_id','academic_session_id','class_section_id','roll_no','status'],
        'class_levels' => ['id','code','name','sequence'],
        'class_sections' => ['id','campus_id','class_level_id','code','name','shift'],
        'subjects' => ['id','code','name','credit_hours'],
        'academic_sessions' => ['id','code','name','starts_on','ends_on','status'],
        'student_attendance' => ['id','attendance_session_id','student_id','status','minutes_late'],
        'attendance_sessions' => ['id','class_section_id','attendance_on','period_code','status'],
        'examinations' => ['id','academic_session_id','class_level_id','name','exam_type','status'],
        'published_results' => ['id','examination_id','student_id','percentage','gpa','result','status'],
        'student_invoices' => ['id','student_id','invoice_no','issued_on','due_on','total_amount','paid_amount','status'],
        'student_payments' => ['id','student_id','student_invoice_id','amount','paid_on','reference_no','status'],
        'fee_heads' => ['id','code','name'],
        'inventory_items' => ['id','sku','name','unit','reorder_level'],
        'library_books' => ['id','isbn','title','author','category'],
    ];

    public static function canRead(string $table): bool
    {
        if (!array_key_exists($table,self::RESTRICTED)) return true;
        return SmsAccess::has(self::RESTRICTED[$table])
            && (int) SmsAccess::membership()->can_access_all_campuses === 1;
    }
    public static function requireRead(string $table): void
    {
        abort_unless(self::canRead($table),403,'This register requires extra access authorization.');
    }
    public static function canExport(string $table): bool
    {
        if (!isset(self::EXPORTS[$table]) || !SmsAccess::has('reports.export') || !self::canRead($table)) return false;
        if ($table === 'students' || $table === 'enrollments') return SmsAccess::has('students.export');
        return true;
    }
    public static function exportColumns(string $table): array
    {
        abort_unless(self::canExport($table),403,'CSV export is not permitted for this table.');
        return self::EXPORTS[$table];
    }
    public static function displayColumns(string $table,array $available): array
    {
        // Protected registers display only non-confidential fields, even to
        // an authorized administrator. Detailed access belongs in specific UIs.
        $protected = [
            'student_health_records'=>['id','student_id','created_at'],
            'student_incidents'=>['id','student_id','occurred_on','category','status'],
            'welfare_cases'=>['id','student_id','category','opened_on','status'],
            'student_documents'=>['id','student_id','document_type','verification_status'],
            'guardians'=>['id','name','relation'],
            'direct_messages'=>['id','sender_user_id','recipient_user_id','created_at'],
            'integration_connections'=>['id','provider','category','status'],
            'sms_audit_logs'=>['id','action','resource_type','resource_id','created_at'],
            'payslips'=>['id','payroll_run_id','employee_id','status'],
            'staff_appraisals'=>['id','employee_id','reviewed_on','score'],
        ];
        if(isset($protected[$table])) return array_values(array_intersect($protected[$table],$available));
        return array_slice(array_values(array_filter($available,fn($c) =>
            !preg_match('/(password|secret|credential|token|private_key|api_key|payload|before_data|after_data|metadata|encrypted|config|options|medical_notes|allergies|file_path|phone|email|address|details|reason|body)/i',$c)
        )),0,9);
    }
}
