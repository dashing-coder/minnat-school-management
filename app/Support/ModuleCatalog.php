<?php
namespace App\Support;
final class ModuleCatalog {
    public const ITEMS=[
        'students'=>['name'=>'Students & SIS','permission'=>'students.view','description'=>'Student profiles, guardians and documents','badge'=>'ST','tables'=>['guardians','students','student_guardians','student_documents']],
        'admissions'=>['name'=>'Admissions','permission'=>'admissions.view','description'=>'Applications, merit and enrollment offers','badge'=>'AD','tables'=>['admission_cycles','admission_applications','admission_offers']],
        'academics'=>['name'=>'Academics & LMS','permission'=>'academics.manage','description'=>'Curriculum, class scheduling and assignments','badge'=>'AC','tables'=>['academic_departments','academic_terms','academic_calendar_events','academic_programs','subjects','class_levels','class_sections','class_subjects','course_offerings','class_routines','lesson_plans','assignments','teacher_assignments','lms_resources','assignment_submissions']],
        'attendance'=>['name'=>'Attendance','permission'=>'attendance.view','description'=>'Student attendance and leave records','badge'=>'AT','tables'=>['student_leave_requests','attendance_sessions','student_attendance']],
        'exams'=>['name'=>'Exams & Results','permission'=>'exams.view','description'=>'Grade scales, examinations and marks','badge'=>'EX','tables'=>['grading_scales','grading_bands','examinations','exam_papers','published_results','exam_marks','exam_recheck_requests']],
        'finance'=>['name'=>'Fees & Accounting','permission'=>'fees.view','description'=>'Invoices, payments and double-entry ledger','badge'=>'FN','tables'=>['chart_of_accounts','payment_methods','ledger_journals','financial_period_closings','fee_heads','student_invoices','ledger_lines','bank_accounts','expenses','student_invoice_lines','student_payments','bank_reconciliations','fee_plans','payment_allocations','payment_refunds','fee_plan_lines']],
        'hr'=>['name'=>'Teachers & HR','permission'=>'hr.view','description'=>'Staff attendance, payroll and appraisals','badge'=>'HR','tables'=>['employees','payroll_runs','staff_attendance','staff_leave_requests','payslips','staff_appraisals','payslip_items']],
        'communication'=>['name'=>'Communication','permission'=>'institutions.manage','description'=>'Notices, notification delivery and meetings','badge'=>'CM','tables'=>['notices','direct_messages','notification_templates','notification_deliveries','parent_meetings']],
        'library'=>['name'=>'Library','permission'=>'library.manage','description'=>'Catalog, copies and circulation','badge'=>'LB','tables'=>['library_books','library_copies','library_loans']],
        'residential'=>['name'=>'Hostel & Transport','permission'=>'hostel.manage','description'=>'Boarding, meal plans and transport','badge'=>'HT','tables'=>['vehicles','hostels','transport_routes','hostel_rooms','meal_plans','transport_stops','hostel_beds','student_transport_assignments','hostel_allocations','hostel_leave_requests']],
        'inventory'=>['name'=>'Inventory & Assets','permission'=>'inventory.manage','description'=>'Purchasing, stock movements and assets','badge'=>'IV','tables'=>['suppliers','inventory_items','fixed_assets','stock_movements','purchase_orders','asset_assignments','purchase_order_lines']],
        'security'=>['name'=>'Security & Analytics','permission'=>'audit.view','description'=>'Tenant reports and audit visibility','badge'=>'SC','tables'=>['sms_audit_logs','institution_memberships','institution_roles','report_exports']],
        'institutions'=>['name'=>'Institutions & Campuses','permission'=>'institutions.manage','description'=>'Institution, campus and session settings','badge'=>'IN','tables'=>['campuses','academic_sessions','institution_module_settings']],
        'lifecycle'=>['name'=>'Academic Lifecycle','permission'=>'students.view','description'=>'Enrollments, promotions, transfers and alumni','badge'=>'LC','tables'=>['student_transfers','alumni_profiles','enrollments','student_promotions']],
        'hifz'=>['name'=>'Hifz & Madrasha','permission'=>'hifz.progress.record','description'=>'Sabaq, revision and Hifz assessment','badge'=>'HF','tables'=>['hifz_groups','hifz_enrollments','hifz_progress_logs','hifz_assessments']],
        'scholarship'=>['name'=>'Scholarships & Donations','permission'=>'donations.manage','description'=>'Scholarship grants, donors and restricted funds','badge'=>'DN','tables'=>['scholarships','donors','donation_funds','scholarship_awards','donations','fund_expenses']],
        'welfare'=>['name'=>'Student Welfare','permission'=>'institutions.manage','description'=>'Discipline, health and welfare cases','badge'=>'WL','tables'=>['student_health_records','student_incidents','welfare_cases']],
        'certificates'=>['name'=>'Certificates','permission'=>'institutions.manage','description'=>'Issued documents and verification metadata','badge'=>'CT','tables'=>['certificate_templates','issued_certificates']],
        'campus'=>['name'=>'Campus & Events','permission'=>'campuses.view','description'=>'Visitors, events and room reservations','badge'=>'CP','tables'=>['visitor_logs','campus_events','room_bookings']],
        'integrations'=>['name'=>'Integrations','permission'=>'institutions.manage','description'=>'Connection settings and processing logs','badge'=>'IT','tables'=>['integration_connections','integration_logs']],
    ];
    public static function all(): array { return self::ITEMS; }
    public static function find(string $slug): ?array { return self::ITEMS[$slug] ?? null; }
    public static function includesTable(string $slug,string $table): bool {
        return in_array($table,self::ITEMS[$slug]['tables'] ?? [], true);
    }
}
