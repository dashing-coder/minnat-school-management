<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('academic_departments', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_academic_departments_uniq');
        });
        Schema::table('academic_programs', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_academic_programs_uniq');
        });
        Schema::table('class_levels', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_class_levels_uniq');
        });
        Schema::table('class_sections', function (Blueprint $table): void {
            $table->unique(["institution_id", "class_level_id", "code"], 'sms_class_sections_uniq');
        });
        Schema::table('subjects', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_subjects_uniq');
        });
        Schema::table('students', function (Blueprint $table): void {
            $table->unique(["institution_id", "admission_no"], 'sms_students_uniq');
        });
        Schema::table('admission_applications', function (Blueprint $table): void {
            $table->unique(["institution_id", "application_no"], 'sms_admission_applications_uniq');
        });
        Schema::table('employees', function (Blueprint $table): void {
            $table->unique(["institution_id", "employee_no"], 'sms_employees_uniq');
        });
        Schema::table('grading_scales', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_grading_scales_uniq');
        });
        Schema::table('chart_of_accounts', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_chart_of_accounts_uniq');
        });
        Schema::table('fee_heads', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_fee_heads_uniq');
        });
        Schema::table('student_invoices', function (Blueprint $table): void {
            $table->unique(["institution_id", "invoice_no"], 'sms_student_invoices_uniq');
        });
        Schema::table('student_payments', function (Blueprint $table): void {
            $table->unique(["institution_id", "reference_no"], 'sms_student_payments_uniq');
        });
        Schema::table('payment_methods', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_payment_methods_uniq');
        });
        Schema::table('ledger_journals', function (Blueprint $table): void {
            $table->unique(["institution_id", "journal_no"], 'sms_ledger_journals_uniq');
        });
        Schema::table('library_copies', function (Blueprint $table): void {
            $table->unique(["institution_id", "barcode"], 'sms_library_copies_uniq');
        });
        Schema::table('vehicles', function (Blueprint $table): void {
            $table->unique(["institution_id", "vehicle_code"], 'sms_vehicles_uniq');
        });
        Schema::table('hostel_rooms', function (Blueprint $table): void {
            $table->unique(["institution_id", "hostel_id", "room_code"], 'sms_hostel_rooms_uniq');
        });
        Schema::table('hostel_beds', function (Blueprint $table): void {
            $table->unique(["institution_id", "hostel_room_id", "bed_code"], 'sms_hostel_beds_uniq');
        });
        Schema::table('inventory_items', function (Blueprint $table): void {
            $table->unique(["institution_id", "sku"], 'sms_inventory_items_uniq');
        });
        Schema::table('purchase_orders', function (Blueprint $table): void {
            $table->unique(["institution_id", "po_number"], 'sms_purchase_orders_uniq');
        });
        Schema::table('fixed_assets', function (Blueprint $table): void {
            $table->unique(["institution_id", "asset_tag"], 'sms_fixed_assets_uniq');
        });
        Schema::table('donation_funds', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_donation_funds_uniq');
        });
        Schema::table('donations', function (Blueprint $table): void {
            $table->unique(["institution_id", "receipt_no"], 'sms_donations_uniq');
        });
        Schema::table('certificate_templates', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_certificate_templates_uniq');
        });
        Schema::table('issued_certificates', function (Blueprint $table): void {
            $table->unique(["institution_id", "certificate_no"], 'sms_issued_certificates_uniq');
        });
        Schema::table('notification_templates', function (Blueprint $table): void {
            $table->unique(["institution_id", "code"], 'sms_notification_templates_uniq');
        });
        Schema::table('financial_period_closings', function (Blueprint $table): void {
            $table->unique(["institution_id", "academic_session_id"], 'sms_financial_period_closings_uniq');
        });
        Schema::table('student_guardians', function (Blueprint $table): void {
            $table->unique(["institution_id", "student_id", "guardian_id"], 'sms_student_guardians_combo_uniq');
        });
        Schema::table('student_attendance', function (Blueprint $table): void {
            $table->unique(["institution_id", "attendance_session_id", "student_id"], 'sms_student_attendance_combo_uniq');
        });
        Schema::table('exam_marks', function (Blueprint $table): void {
            $table->unique(["institution_id", "exam_paper_id", "student_id"], 'sms_exam_marks_combo_uniq');
        });
        Schema::table('published_results', function (Blueprint $table): void {
            $table->unique(["institution_id", "examination_id", "student_id"], 'sms_published_results_combo_uniq');
        });
        Schema::table('payment_allocations', function (Blueprint $table): void {
            $table->unique(["institution_id", "student_payment_id", "student_invoice_id"], 'sms_payment_allocations_combo_uniq');
        });
        Schema::table('fee_plan_lines', function (Blueprint $table): void {
            $table->unique(["institution_id", "fee_plan_id", "fee_head_id"], 'sms_fee_plan_lines_combo_uniq');
        });
        Schema::table('asset_assignments', function (Blueprint $table): void {
            $table->unique(["institution_id", "fixed_asset_id", "employee_id", "assigned_on"], 'sms_asset_assignments_combo_uniq');
        });
        Schema::table('students', function (Blueprint $table): void {
            $table->index(["institution_id", "status", "campus_id"], 'sms_students_idx');
        });
        Schema::table('enrollments', function (Blueprint $table): void {
            $table->index(["institution_id", "academic_session_id", "class_section_id"], 'sms_enrollments_idx');
        });
        Schema::table('student_attendance', function (Blueprint $table): void {
            $table->index(["institution_id", "student_id", "status"], 'sms_student_attendance_idx');
        });
        Schema::table('exam_marks', function (Blueprint $table): void {
            $table->index(["institution_id", "student_id", "status"], 'sms_exam_marks_idx');
        });
        Schema::table('student_invoices', function (Blueprint $table): void {
            $table->index(["institution_id", "student_id", "status", "due_on"], 'sms_student_invoices_idx');
        });
        Schema::table('student_payments', function (Blueprint $table): void {
            $table->index(["institution_id", "student_id", "paid_on"], 'sms_student_payments_idx');
        });
        Schema::table('ledger_journals', function (Blueprint $table): void {
            $table->index(["institution_id", "posted_on", "status"], 'sms_ledger_journals_idx');
        });
        Schema::table('donations', function (Blueprint $table): void {
            $table->index(["institution_id", "donation_fund_id", "received_on"], 'sms_donations_idx');
        });
        Schema::table('hifz_progress_logs', function (Blueprint $table): void {
            $table->index(["institution_id", "hifz_enrollment_id", "logged_on"], 'sms_hifz_progress_logs_idx');
        });
        Schema::table('notification_deliveries', function (Blueprint $table): void {
            $table->index(["institution_id", "status", "sent_at"], 'sms_notification_deliveries_idx');
        });
        Schema::table('integration_logs', function (Blueprint $table): void {
            $table->index(["institution_id", "status", "logged_at"], 'sms_integration_logs_idx');
        });
    }

    public function down(): void
    {
        Schema::table('integration_logs', function (Blueprint $table): void {
            $table->dropIndex('sms_integration_logs_idx');
        });
        Schema::table('notification_deliveries', function (Blueprint $table): void {
            $table->dropIndex('sms_notification_deliveries_idx');
        });
        Schema::table('hifz_progress_logs', function (Blueprint $table): void {
            $table->dropIndex('sms_hifz_progress_logs_idx');
        });
        Schema::table('donations', function (Blueprint $table): void {
            $table->dropIndex('sms_donations_idx');
        });
        Schema::table('ledger_journals', function (Blueprint $table): void {
            $table->dropIndex('sms_ledger_journals_idx');
        });
        Schema::table('student_payments', function (Blueprint $table): void {
            $table->dropIndex('sms_student_payments_idx');
        });
        Schema::table('student_invoices', function (Blueprint $table): void {
            $table->dropIndex('sms_student_invoices_idx');
        });
        Schema::table('exam_marks', function (Blueprint $table): void {
            $table->dropIndex('sms_exam_marks_idx');
        });
        Schema::table('student_attendance', function (Blueprint $table): void {
            $table->dropIndex('sms_student_attendance_idx');
        });
        Schema::table('enrollments', function (Blueprint $table): void {
            $table->dropIndex('sms_enrollments_idx');
        });
        Schema::table('students', function (Blueprint $table): void {
            $table->dropIndex('sms_students_idx');
        });
        Schema::table('asset_assignments', function (Blueprint $table): void {
            $table->dropUnique('sms_asset_assignments_combo_uniq');
        });
        Schema::table('fee_plan_lines', function (Blueprint $table): void {
            $table->dropUnique('sms_fee_plan_lines_combo_uniq');
        });
        Schema::table('payment_allocations', function (Blueprint $table): void {
            $table->dropUnique('sms_payment_allocations_combo_uniq');
        });
        Schema::table('published_results', function (Blueprint $table): void {
            $table->dropUnique('sms_published_results_combo_uniq');
        });
        Schema::table('exam_marks', function (Blueprint $table): void {
            $table->dropUnique('sms_exam_marks_combo_uniq');
        });
        Schema::table('student_attendance', function (Blueprint $table): void {
            $table->dropUnique('sms_student_attendance_combo_uniq');
        });
        Schema::table('student_guardians', function (Blueprint $table): void {
            $table->dropUnique('sms_student_guardians_combo_uniq');
        });
        Schema::table('financial_period_closings', function (Blueprint $table): void {
            $table->dropUnique('sms_financial_period_closings_uniq');
        });
        Schema::table('notification_templates', function (Blueprint $table): void {
            $table->dropUnique('sms_notification_templates_uniq');
        });
        Schema::table('issued_certificates', function (Blueprint $table): void {
            $table->dropUnique('sms_issued_certificates_uniq');
        });
        Schema::table('certificate_templates', function (Blueprint $table): void {
            $table->dropUnique('sms_certificate_templates_uniq');
        });
        Schema::table('donations', function (Blueprint $table): void {
            $table->dropUnique('sms_donations_uniq');
        });
        Schema::table('donation_funds', function (Blueprint $table): void {
            $table->dropUnique('sms_donation_funds_uniq');
        });
        Schema::table('fixed_assets', function (Blueprint $table): void {
            $table->dropUnique('sms_fixed_assets_uniq');
        });
        Schema::table('purchase_orders', function (Blueprint $table): void {
            $table->dropUnique('sms_purchase_orders_uniq');
        });
        Schema::table('inventory_items', function (Blueprint $table): void {
            $table->dropUnique('sms_inventory_items_uniq');
        });
        Schema::table('hostel_beds', function (Blueprint $table): void {
            $table->dropUnique('sms_hostel_beds_uniq');
        });
        Schema::table('hostel_rooms', function (Blueprint $table): void {
            $table->dropUnique('sms_hostel_rooms_uniq');
        });
        Schema::table('vehicles', function (Blueprint $table): void {
            $table->dropUnique('sms_vehicles_uniq');
        });
        Schema::table('library_copies', function (Blueprint $table): void {
            $table->dropUnique('sms_library_copies_uniq');
        });
        Schema::table('ledger_journals', function (Blueprint $table): void {
            $table->dropUnique('sms_ledger_journals_uniq');
        });
        Schema::table('payment_methods', function (Blueprint $table): void {
            $table->dropUnique('sms_payment_methods_uniq');
        });
        Schema::table('student_payments', function (Blueprint $table): void {
            $table->dropUnique('sms_student_payments_uniq');
        });
        Schema::table('student_invoices', function (Blueprint $table): void {
            $table->dropUnique('sms_student_invoices_uniq');
        });
        Schema::table('fee_heads', function (Blueprint $table): void {
            $table->dropUnique('sms_fee_heads_uniq');
        });
        Schema::table('chart_of_accounts', function (Blueprint $table): void {
            $table->dropUnique('sms_chart_of_accounts_uniq');
        });
        Schema::table('grading_scales', function (Blueprint $table): void {
            $table->dropUnique('sms_grading_scales_uniq');
        });
        Schema::table('employees', function (Blueprint $table): void {
            $table->dropUnique('sms_employees_uniq');
        });
        Schema::table('admission_applications', function (Blueprint $table): void {
            $table->dropUnique('sms_admission_applications_uniq');
        });
        Schema::table('students', function (Blueprint $table): void {
            $table->dropUnique('sms_students_uniq');
        });
        Schema::table('subjects', function (Blueprint $table): void {
            $table->dropUnique('sms_subjects_uniq');
        });
        Schema::table('class_sections', function (Blueprint $table): void {
            $table->dropUnique('sms_class_sections_uniq');
        });
        Schema::table('class_levels', function (Blueprint $table): void {
            $table->dropUnique('sms_class_levels_uniq');
        });
        Schema::table('academic_programs', function (Blueprint $table): void {
            $table->dropUnique('sms_academic_programs_uniq');
        });
        Schema::table('academic_departments', function (Blueprint $table): void {
            $table->dropUnique('sms_academic_departments_uniq');
        });
    }
};
