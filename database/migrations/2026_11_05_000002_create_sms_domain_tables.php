<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Requires the Phase 1 core schema; all module-owned data is tenant scoped.
        Schema::create('academic_departments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('campus_id');
            $table->string('code', 32);
            $table->string('name', 160);
            $table->string('category', 40);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'campus_id'], 'academic_departments_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('academic_terms', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('academic_session_id');
            $table->string('name', 100);
            $table->date('starts_on');
            $table->date('ends_on');
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'academic_session_id'], 'academic_terms_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
        });

        Schema::create('academic_calendar_events', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('academic_session_id');
            $table->string('title', 180);
            $table->string('event_type', 40);
            $table->dateTime('starts_at');
            $table->dateTime('ends_at');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'academic_session_id'], 'academic_calendar_events_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
        });

        Schema::create('guardians', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('name', 180);
            $table->string('relation', 40);
            $table->string('phone', 32);
            $table->string('email', 180)->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign('user_id', 'guardians_user_id_fk')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('students', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('campus_id');
            $table->string('admission_no', 40);
            $table->string('name', 180);
            $table->string('gender', 20)->nullable();
            $table->date('birth_date')->nullable();
            $table->string('blood_group', 8)->nullable();
            $table->string('status', 32)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign('user_id', 'students_user_id_fk')->references('id')->on('users')->restrictOnDelete();
            $table->foreign(['institution_id', 'campus_id'], 'students_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('admission_cycles', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('academic_session_id');
            $table->unsignedBigInteger('campus_id');
            $table->string('title', 150);
            $table->date('opens_on');
            $table->date('closes_on');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'academic_session_id'], 'admission_cycles_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
            $table->foreign(['institution_id', 'campus_id'], 'admission_cycles_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('employees', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('campus_id');
            $table->string('employee_no', 40);
            $table->string('name', 180);
            $table->string('designation', 100);
            $table->date('joined_on');
            $table->decimal('basic_salary', 14, 2)->default(0);
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign('user_id', 'employees_user_id_fk')->references('id')->on('users')->restrictOnDelete();
            $table->foreign(['institution_id', 'campus_id'], 'employees_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('payroll_runs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->date('period_start');
            $table->date('period_end');
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('grading_scales', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 32);
            $table->string('name', 100);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('chart_of_accounts', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 32);
            $table->string('name', 140);
            $table->string('account_type', 40);
            $table->unsignedBigInteger('parent_account_id')->nullable();
            $table->boolean('is_active')->default(1);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'parent_account_id'], 'chart_of_accounts_parent_account_id_fk')
                ->references(['institution_id', 'id'])->on('chart_of_accounts')->restrictOnDelete();
        });

        Schema::create('payment_methods', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 32);
            $table->string('name', 120);
            $table->string('method_type', 40);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('ledger_journals', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('journal_no', 50);
            $table->date('posted_on');
            $table->string('source_type', 60);
            $table->string('source_reference', 70)->nullable();
            $table->string('description', 220);
            $table->string('status', 24)->default('posted');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('financial_period_closings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('academic_session_id');
            $table->date('closed_on');
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'academic_session_id'], 'financial_period_closings_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
        });

        Schema::create('scholarships', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('name', 160);
            $table->text('criteria')->nullable();
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('notices', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('title', 180);
            $table->text('body');
            $table->string('audience', 50);
            $table->dateTime('published_at')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('direct_messages', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('sender_user_id');
            $table->unsignedBigInteger('recipient_user_id');
            $table->text('body');
            $table->dateTime('read_at')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign('sender_user_id', 'direct_messages_sender_user_id_fk')->references('id')->on('users')->restrictOnDelete();
            $table->foreign('recipient_user_id', 'direct_messages_recipient_user_id_fk')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('notification_templates', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 50);
            $table->string('channel', 32);
            $table->text('body');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('library_books', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('isbn', 32)->nullable();
            $table->string('title', 220);
            $table->string('author', 160);
            $table->string('category', 80);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('vehicles', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('vehicle_code', 40);
            $table->string('plate_number', 60);
            $table->unsignedInteger('seats');
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('hostels', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('campus_id');
            $table->string('name', 140);
            $table->string('category', 40);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'campus_id'], 'hostels_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('suppliers', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('name', 180);
            $table->string('phone', 40)->nullable();
            $table->text('address')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('inventory_items', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('sku', 60);
            $table->string('name', 180);
            $table->string('unit', 32);
            $table->unsignedInteger('reorder_level')->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('fixed_assets', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('asset_tag', 60);
            $table->string('name', 160);
            $table->string('category', 100);
            $table->date('purchased_on');
            $table->decimal('purchase_cost', 14, 2);
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('donors', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('name', 160);
            $table->string('phone', 40)->nullable();
            $table->string('email', 160)->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('donation_funds', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 40);
            $table->string('name', 180);
            $table->boolean('is_restricted')->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('certificate_templates', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 50);
            $table->string('name', 150);
            $table->text('template_html');
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('visitor_logs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('campus_id');
            $table->string('visitor_name', 180);
            $table->string('purpose', 150);
            $table->dateTime('checked_in_at');
            $table->dateTime('checked_out_at')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'campus_id'], 'visitor_logs_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('campus_events', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('campus_id');
            $table->string('title', 180);
            $table->dateTime('starts_at');
            $table->dateTime('ends_at');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'campus_id'], 'campus_events_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('room_bookings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('campus_id');
            $table->unsignedBigInteger('booked_by_user_id')->nullable();
            $table->string('room_name', 100);
            $table->dateTime('starts_at');
            $table->dateTime('ends_at');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'campus_id'], 'room_bookings_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
            $table->foreign('booked_by_user_id', 'room_bookings_booked_by_user_id_fk')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('integration_connections', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('provider', 100);
            $table->string('category', 60);
            $table->string('status', 24)->default('disabled');
            $table->json('configuration')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('report_exports', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('user_id');
            $table->string('report_key', 100);
            $table->dateTime('requested_at');
            $table->string('status', 32)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign('user_id', 'report_exports_user_id_fk')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('academic_programs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('department_id');
            $table->string('code', 32);
            $table->string('name', 140);
            $table->string('level', 40);
            $table->decimal('required_credits', 8, 2)->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'department_id'], 'academic_programs_department_id_fk')
                ->references(['institution_id', 'id'])->on('academic_departments')->restrictOnDelete();
        });

        Schema::create('subjects', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('department_id')->nullable();
            $table->string('code', 32);
            $table->string('name', 140);
            $table->decimal('credit_hours', 6, 2)->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'department_id'], 'subjects_department_id_fk')
                ->references(['institution_id', 'id'])->on('academic_departments')->restrictOnDelete();
        });

        Schema::create('student_guardians', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('guardian_id');
            $table->string('relationship', 32);
            $table->boolean('is_primary')->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_guardians_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'guardian_id'], 'student_guardians_guardian_id_fk')
                ->references(['institution_id', 'id'])->on('guardians')->restrictOnDelete();
        });

        Schema::create('student_documents', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->string('document_type', 60);
            $table->string('file_path', 255)->nullable();
            $table->string('verification_status', 32)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_documents_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('student_transfers', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('from_campus_id');
            $table->unsignedBigInteger('to_campus_id')->nullable();
            $table->date('transferred_on');
            $table->text('reason');
            $table->string('status', 32)->default('requested');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_transfers_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'from_campus_id'], 'student_transfers_from_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
            $table->foreign(['institution_id', 'to_campus_id'], 'student_transfers_to_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
        });

        Schema::create('student_health_records', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->text('allergies')->nullable();
            $table->text('medical_notes')->nullable();
            $table->string('emergency_contact', 32);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_health_records_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('student_incidents', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->date('occurred_on');
            $table->string('category', 60);
            $table->text('details');
            $table->string('status', 32)->default('open');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_incidents_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('student_leave_requests', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->date('starts_on');
            $table->date('ends_on');
            $table->text('reason');
            $table->string('status', 24)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_leave_requests_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('staff_attendance', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('employee_id');
            $table->date('attendance_on');
            $table->string('status', 24)->default('present');
            $table->dateTime('check_in_at')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'employee_id'], 'staff_attendance_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('staff_leave_requests', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('employee_id');
            $table->date('starts_on');
            $table->date('ends_on');
            $table->text('reason');
            $table->string('status', 24)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'employee_id'], 'staff_leave_requests_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('payslips', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('payroll_run_id');
            $table->unsignedBigInteger('employee_id');
            $table->decimal('gross_amount', 14, 2);
            $table->decimal('deduction_amount', 14, 2)->default(0);
            $table->decimal('net_amount', 14, 2);
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'payroll_run_id'], 'payslips_payroll_run_id_fk')
                ->references(['institution_id', 'id'])->on('payroll_runs')->restrictOnDelete();
            $table->foreign(['institution_id', 'employee_id'], 'payslips_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('staff_appraisals', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('employee_id');
            $table->date('reviewed_on');
            $table->decimal('score', 5, 2);
            $table->text('remarks')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'employee_id'], 'staff_appraisals_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('grading_bands', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('grading_scale_id');
            $table->decimal('min_percent', 5, 2);
            $table->decimal('max_percent', 5, 2);
            $table->string('letter_grade', 8);
            $table->decimal('grade_point', 4, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'grading_scale_id'], 'grading_bands_grading_scale_id_fk')
                ->references(['institution_id', 'id'])->on('grading_scales')->restrictOnDelete();
        });

        Schema::create('fee_heads', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 32);
            $table->string('name', 120);
            $table->unsignedBigInteger('revenue_account_id');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'revenue_account_id'], 'fee_heads_revenue_account_id_fk')
                ->references(['institution_id', 'id'])->on('chart_of_accounts')->restrictOnDelete();
        });

        Schema::create('student_invoices', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->string('invoice_no', 50);
            $table->date('issued_on');
            $table->date('due_on');
            $table->decimal('total_amount', 14, 2);
            $table->decimal('paid_amount', 14, 2)->default(0);
            $table->string('status', 24)->default('unpaid');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_invoices_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('ledger_lines', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('ledger_journal_id');
            $table->unsignedBigInteger('account_id');
            $table->decimal('debit', 14, 2)->default(0);
            $table->decimal('credit', 14, 2)->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'ledger_journal_id'], 'ledger_lines_ledger_journal_id_fk')
                ->references(['institution_id', 'id'])->on('ledger_journals')->restrictOnDelete();
            $table->foreign(['institution_id', 'account_id'], 'ledger_lines_account_id_fk')
                ->references(['institution_id', 'id'])->on('chart_of_accounts')->restrictOnDelete();
        });

        Schema::create('bank_accounts', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('account_id');
            $table->string('bank_name', 140);
            $table->string('account_mask', 24);
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'account_id'], 'bank_accounts_account_id_fk')
                ->references(['institution_id', 'id'])->on('chart_of_accounts')->restrictOnDelete();
        });

        Schema::create('expenses', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('expense_no', 50);
            $table->string('description', 200);
            $table->date('expense_on');
            $table->decimal('amount', 14, 2);
            $table->unsignedBigInteger('account_id');
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'account_id'], 'expenses_account_id_fk')
                ->references(['institution_id', 'id'])->on('chart_of_accounts')->restrictOnDelete();
        });

        Schema::create('scholarship_awards', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('scholarship_id');
            $table->unsignedBigInteger('student_id');
            $table->decimal('amount', 14, 2);
            $table->string('status', 24)->default('approved');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'scholarship_id'], 'scholarship_awards_scholarship_id_fk')
                ->references(['institution_id', 'id'])->on('scholarships')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'scholarship_awards_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('notification_deliveries', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('notification_template_id');
            $table->unsignedBigInteger('student_id')->nullable();
            $table->string('recipient', 160);
            $table->string('channel', 32);
            $table->string('status', 24)->default('queued');
            $table->dateTime('sent_at')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'notification_template_id'], 'notification_deliveries_notification_template_id_fk')
                ->references(['institution_id', 'id'])->on('notification_templates')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'notification_deliveries_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('parent_meetings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('employee_id');
            $table->dateTime('scheduled_at');
            $table->string('status', 24)->default('requested');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'parent_meetings_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'employee_id'], 'parent_meetings_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('library_copies', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('library_book_id');
            $table->string('barcode', 64);
            $table->string('status', 24)->default('available');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'library_book_id'], 'library_copies_library_book_id_fk')
                ->references(['institution_id', 'id'])->on('library_books')->restrictOnDelete();
        });

        Schema::create('transport_routes', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('vehicle_id');
            $table->unsignedBigInteger('employee_id')->nullable();
            $table->string('route_name', 150);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'vehicle_id'], 'transport_routes_vehicle_id_fk')
                ->references(['institution_id', 'id'])->on('vehicles')->restrictOnDelete();
            $table->foreign(['institution_id', 'employee_id'], 'transport_routes_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('hostel_rooms', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('hostel_id');
            $table->string('room_code', 40);
            $table->unsignedInteger('capacity');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'hostel_id'], 'hostel_rooms_hostel_id_fk')
                ->references(['institution_id', 'id'])->on('hostels')->restrictOnDelete();
        });

        Schema::create('meal_plans', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('hostel_id');
            $table->string('name', 120);
            $table->decimal('monthly_rate', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'hostel_id'], 'meal_plans_hostel_id_fk')
                ->references(['institution_id', 'id'])->on('hostels')->restrictOnDelete();
        });

        Schema::create('stock_movements', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('inventory_item_id');
            $table->integer('quantity');
            $table->string('movement_type', 30);
            $table->string('reference_no', 70);
            $table->date('moved_on');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'inventory_item_id'], 'stock_movements_inventory_item_id_fk')
                ->references(['institution_id', 'id'])->on('inventory_items')->restrictOnDelete();
        });

        Schema::create('purchase_orders', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('supplier_id');
            $table->string('po_number', 60);
            $table->date('ordered_on');
            $table->decimal('total_amount', 14, 2);
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'supplier_id'], 'purchase_orders_supplier_id_fk')
                ->references(['institution_id', 'id'])->on('suppliers')->restrictOnDelete();
        });

        Schema::create('asset_assignments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('fixed_asset_id');
            $table->unsignedBigInteger('employee_id');
            $table->date('assigned_on');
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'fixed_asset_id'], 'asset_assignments_fixed_asset_id_fk')
                ->references(['institution_id', 'id'])->on('fixed_assets')->restrictOnDelete();
            $table->foreign(['institution_id', 'employee_id'], 'asset_assignments_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('hifz_groups', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('name', 150);
            $table->unsignedBigInteger('employee_id');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'employee_id'], 'hifz_groups_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
        });

        Schema::create('donations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('donor_id');
            $table->unsignedBigInteger('donation_fund_id');
            $table->string('receipt_no', 60);
            $table->decimal('amount', 14, 2);
            $table->date('received_on');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'donor_id'], 'donations_donor_id_fk')
                ->references(['institution_id', 'id'])->on('donors')->restrictOnDelete();
            $table->foreign(['institution_id', 'donation_fund_id'], 'donations_donation_fund_id_fk')
                ->references(['institution_id', 'id'])->on('donation_funds')->restrictOnDelete();
        });

        Schema::create('fund_expenses', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('donation_fund_id');
            $table->unsignedBigInteger('approved_by_user_id')->nullable();
            $table->string('description', 190);
            $table->decimal('amount', 14, 2);
            $table->date('spent_on');
            $table->string('status', 24)->default('approved');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'donation_fund_id'], 'fund_expenses_donation_fund_id_fk')
                ->references(['institution_id', 'id'])->on('donation_funds')->restrictOnDelete();
            $table->foreign('approved_by_user_id', 'fund_expenses_approved_by_user_id_fk')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::create('welfare_cases', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->string('category', 70);
            $table->text('details');
            $table->date('opened_on');
            $table->string('status', 24)->default('open');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'welfare_cases_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('issued_certificates', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('certificate_template_id');
            $table->string('certificate_no', 65);
            $table->date('issued_on');
            $table->string('verification_token', 100);
            $table->string('status', 24)->default('issued');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'issued_certificates_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'certificate_template_id'], 'issued_certificates_certificate_template_id_fk')
                ->references(['institution_id', 'id'])->on('certificate_templates')->restrictOnDelete();
        });

        Schema::create('integration_logs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('integration_connection_id');
            $table->string('event_name', 140);
            $table->string('status', 32);
            $table->dateTime('logged_at');
            $table->string('external_reference', 140)->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'integration_connection_id'], 'integration_logs_integration_connection_id_fk')
                ->references(['institution_id', 'id'])->on('integration_connections')->restrictOnDelete();
        });

        Schema::create('alumni_profiles', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedInteger('graduation_year');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'alumni_profiles_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('class_levels', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('program_id')->nullable();
            $table->string('code', 32);
            $table->string('name', 100);
            $table->unsignedInteger('sequence')->default(1);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'program_id'], 'class_levels_program_id_fk')
                ->references(['institution_id', 'id'])->on('academic_programs')->restrictOnDelete();
        });

        Schema::create('payslip_items', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('payslip_id');
            $table->string('item_type', 32);
            $table->string('description', 140);
            $table->decimal('amount', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'payslip_id'], 'payslip_items_payslip_id_fk')
                ->references(['institution_id', 'id'])->on('payslips')->restrictOnDelete();
        });

        Schema::create('student_invoice_lines', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_invoice_id');
            $table->unsignedBigInteger('fee_head_id');
            $table->string('description', 180);
            $table->decimal('amount', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_invoice_id'], 'student_invoice_lines_student_invoice_id_fk')
                ->references(['institution_id', 'id'])->on('student_invoices')->restrictOnDelete();
            $table->foreign(['institution_id', 'fee_head_id'], 'student_invoice_lines_fee_head_id_fk')
                ->references(['institution_id', 'id'])->on('fee_heads')->restrictOnDelete();
        });

        Schema::create('student_payments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('student_invoice_id');
            $table->unsignedBigInteger('payment_method_id');
            $table->decimal('amount', 14, 2);
            $table->date('paid_on');
            $table->string('reference_no', 100);
            $table->string('status', 24)->default('posted');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_payments_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_invoice_id'], 'student_payments_student_invoice_id_fk')
                ->references(['institution_id', 'id'])->on('student_invoices')->restrictOnDelete();
            $table->foreign(['institution_id', 'payment_method_id'], 'student_payments_payment_method_id_fk')
                ->references(['institution_id', 'id'])->on('payment_methods')->restrictOnDelete();
        });

        Schema::create('bank_reconciliations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('bank_account_id');
            $table->date('statement_on');
            $table->decimal('statement_balance', 14, 2);
            $table->decimal('ledger_balance', 14, 2);
            $table->string('status', 24)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'bank_account_id'], 'bank_reconciliations_bank_account_id_fk')
                ->references(['institution_id', 'id'])->on('bank_accounts')->restrictOnDelete();
        });

        Schema::create('library_loans', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('library_copy_id');
            $table->unsignedBigInteger('student_id');
            $table->date('issued_on');
            $table->date('due_on');
            $table->date('returned_on')->nullable();
            $table->decimal('fine_amount', 14, 2)->default(0);
            $table->string('status', 24)->default('issued');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'library_copy_id'], 'library_loans_library_copy_id_fk')
                ->references(['institution_id', 'id'])->on('library_copies')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'library_loans_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('transport_stops', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('transport_route_id');
            $table->string('name', 140);
            $table->unsignedInteger('stop_order');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'transport_route_id'], 'transport_stops_transport_route_id_fk')
                ->references(['institution_id', 'id'])->on('transport_routes')->restrictOnDelete();
        });

        Schema::create('hostel_beds', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('hostel_room_id');
            $table->string('bed_code', 40);
            $table->string('status', 24)->default('available');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'hostel_room_id'], 'hostel_beds_hostel_room_id_fk')
                ->references(['institution_id', 'id'])->on('hostel_rooms')->restrictOnDelete();
        });

        Schema::create('purchase_order_lines', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('purchase_order_id');
            $table->unsignedBigInteger('inventory_item_id');
            $table->unsignedInteger('quantity');
            $table->decimal('unit_price', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'purchase_order_id'], 'purchase_order_lines_purchase_order_id_fk')
                ->references(['institution_id', 'id'])->on('purchase_orders')->restrictOnDelete();
            $table->foreign(['institution_id', 'inventory_item_id'], 'purchase_order_lines_inventory_item_id_fk')
                ->references(['institution_id', 'id'])->on('inventory_items')->restrictOnDelete();
        });

        Schema::create('hifz_enrollments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('hifz_group_id');
            $table->date('started_on');
            $table->unsignedInteger('target_juz')->default(30);
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'hifz_enrollments_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'hifz_group_id'], 'hifz_enrollments_hifz_group_id_fk')
                ->references(['institution_id', 'id'])->on('hifz_groups')->restrictOnDelete();
        });

        Schema::create('class_sections', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('campus_id');
            $table->unsignedBigInteger('class_level_id');
            $table->string('code', 32);
            $table->string('name', 80);
            $table->string('shift', 32)->default('day');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'campus_id'], 'class_sections_campus_id_fk')
                ->references(['institution_id', 'id'])->on('campuses')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_level_id'], 'class_sections_class_level_id_fk')
                ->references(['institution_id', 'id'])->on('class_levels')->restrictOnDelete();
        });

        Schema::create('class_subjects', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_level_id');
            $table->unsignedBigInteger('subject_id');
            $table->unsignedBigInteger('academic_session_id');
            $table->boolean('is_compulsory')->default(1);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_level_id'], 'class_subjects_class_level_id_fk')
                ->references(['institution_id', 'id'])->on('class_levels')->restrictOnDelete();
            $table->foreign(['institution_id', 'subject_id'], 'class_subjects_subject_id_fk')
                ->references(['institution_id', 'id'])->on('subjects')->restrictOnDelete();
            $table->foreign(['institution_id', 'academic_session_id'], 'class_subjects_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
        });

        Schema::create('admission_applications', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('admission_cycle_id');
            $table->unsignedBigInteger('class_level_id');
            $table->string('application_no', 50);
            $table->string('applicant_name', 180);
            $table->string('guardian_phone', 32);
            $table->decimal('score', 7, 2)->nullable();
            $table->string('status', 32)->default('submitted');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'admission_cycle_id'], 'admission_applications_admission_cycle_id_fk')
                ->references(['institution_id', 'id'])->on('admission_cycles')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_level_id'], 'admission_applications_class_level_id_fk')
                ->references(['institution_id', 'id'])->on('class_levels')->restrictOnDelete();
        });

        Schema::create('examinations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('academic_session_id');
            $table->unsignedBigInteger('class_level_id');
            $table->string('name', 140);
            $table->string('exam_type', 60);
            $table->date('starts_on');
            $table->date('ends_on');
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'academic_session_id'], 'examinations_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_level_id'], 'examinations_class_level_id_fk')
                ->references(['institution_id', 'id'])->on('class_levels')->restrictOnDelete();
        });

        Schema::create('fee_plans', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_level_id');
            $table->unsignedBigInteger('academic_session_id');
            $table->string('name', 140);
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_level_id'], 'fee_plans_class_level_id_fk')
                ->references(['institution_id', 'id'])->on('class_levels')->restrictOnDelete();
            $table->foreign(['institution_id', 'academic_session_id'], 'fee_plans_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
        });

        Schema::create('payment_allocations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_payment_id');
            $table->unsignedBigInteger('student_invoice_id');
            $table->decimal('amount', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_payment_id'], 'payment_allocations_student_payment_id_fk')
                ->references(['institution_id', 'id'])->on('student_payments')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_invoice_id'], 'payment_allocations_student_invoice_id_fk')
                ->references(['institution_id', 'id'])->on('student_invoices')->restrictOnDelete();
        });

        Schema::create('payment_refunds', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_payment_id');
            $table->decimal('amount', 14, 2);
            $table->text('reason');
            $table->string('status', 24)->default('requested');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_payment_id'], 'payment_refunds_student_payment_id_fk')
                ->references(['institution_id', 'id'])->on('student_payments')->restrictOnDelete();
        });

        Schema::create('student_transport_assignments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('transport_route_id');
            $table->unsignedBigInteger('transport_stop_id');
            $table->date('starts_on');
            $table->decimal('monthly_fee', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_transport_assignments_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'transport_route_id'], 'student_transport_assignments_transport_route_id_fk')
                ->references(['institution_id', 'id'])->on('transport_routes')->restrictOnDelete();
            $table->foreign(['institution_id', 'transport_stop_id'], 'student_transport_assignments_transport_stop_id_fk')
                ->references(['institution_id', 'id'])->on('transport_stops')->restrictOnDelete();
        });

        Schema::create('hostel_allocations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('hostel_bed_id');
            $table->date('check_in_on');
            $table->decimal('monthly_fee', 14, 2);
            $table->string('status', 24)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'hostel_allocations_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'hostel_bed_id'], 'hostel_allocations_hostel_bed_id_fk')
                ->references(['institution_id', 'id'])->on('hostel_beds')->restrictOnDelete();
        });

        Schema::create('hifz_progress_logs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('hifz_enrollment_id');
            $table->date('logged_on');
            $table->string('sabaq', 150);
            $table->string('sabqi', 150);
            $table->string('manzil', 150);
            $table->unsignedInteger('juz_completed')->default(0);
            $table->decimal('accuracy_percent', 5, 2);
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'hifz_enrollment_id'], 'hifz_progress_logs_hifz_enrollment_id_fk')
                ->references(['institution_id', 'id'])->on('hifz_enrollments')->restrictOnDelete();
        });

        Schema::create('hifz_assessments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('hifz_enrollment_id');
            $table->date('assessed_on');
            $table->decimal('score', 5, 2);
            $table->text('remarks')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'hifz_enrollment_id'], 'hifz_assessments_hifz_enrollment_id_fk')
                ->references(['institution_id', 'id'])->on('hifz_enrollments')->restrictOnDelete();
        });

        Schema::create('course_offerings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('academic_term_id');
            $table->unsignedBigInteger('class_section_id');
            $table->unsignedBigInteger('subject_id');
            $table->unsignedInteger('capacity')->default(30);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'academic_term_id'], 'course_offerings_academic_term_id_fk')
                ->references(['institution_id', 'id'])->on('academic_terms')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_section_id'], 'course_offerings_class_section_id_fk')
                ->references(['institution_id', 'id'])->on('class_sections')->restrictOnDelete();
            $table->foreign(['institution_id', 'subject_id'], 'course_offerings_subject_id_fk')
                ->references(['institution_id', 'id'])->on('subjects')->restrictOnDelete();
        });

        Schema::create('class_routines', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_section_id');
            $table->unsignedBigInteger('class_subject_id');
            $table->string('day_of_week', 12);
            $table->time('starts_at');
            $table->time('ends_at');
            $table->string('room', 50);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_section_id'], 'class_routines_class_section_id_fk')
                ->references(['institution_id', 'id'])->on('class_sections')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_subject_id'], 'class_routines_class_subject_id_fk')
                ->references(['institution_id', 'id'])->on('class_subjects')->restrictOnDelete();
        });

        Schema::create('lesson_plans', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_subject_id');
            $table->date('lesson_date');
            $table->string('topic', 180);
            $table->decimal('completion_percent', 5, 2)->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_subject_id'], 'lesson_plans_class_subject_id_fk')
                ->references(['institution_id', 'id'])->on('class_subjects')->restrictOnDelete();
        });

        Schema::create('assignments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_subject_id');
            $table->string('title', 180);
            $table->text('details')->nullable();
            $table->dateTime('due_at');
            $table->decimal('max_marks', 7, 2)->default(100);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_subject_id'], 'assignments_class_subject_id_fk')
                ->references(['institution_id', 'id'])->on('class_subjects')->restrictOnDelete();
        });

        Schema::create('enrollments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('academic_session_id');
            $table->unsignedBigInteger('class_section_id');
            $table->string('roll_no', 30);
            $table->string('status', 32)->default('active');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'enrollments_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'academic_session_id'], 'enrollments_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_section_id'], 'enrollments_class_section_id_fk')
                ->references(['institution_id', 'id'])->on('class_sections')->restrictOnDelete();
        });

        Schema::create('admission_offers', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('admission_application_id');
            $table->unsignedBigInteger('student_id')->nullable();
            $table->date('offered_on');
            $table->string('status', 32)->default('offered');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'admission_application_id'], 'admission_offers_admission_application_id_fk')
                ->references(['institution_id', 'id'])->on('admission_applications')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'admission_offers_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('attendance_sessions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_section_id');
            $table->date('attendance_on');
            $table->string('period_code', 40)->default('daily');
            $table->string('status', 24)->default('open');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_section_id'], 'attendance_sessions_class_section_id_fk')
                ->references(['institution_id', 'id'])->on('class_sections')->restrictOnDelete();
        });

        Schema::create('teacher_assignments', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('employee_id');
            $table->unsignedBigInteger('class_subject_id');
            $table->unsignedBigInteger('academic_session_id');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'employee_id'], 'teacher_assignments_employee_id_fk')
                ->references(['institution_id', 'id'])->on('employees')->restrictOnDelete();
            $table->foreign(['institution_id', 'class_subject_id'], 'teacher_assignments_class_subject_id_fk')
                ->references(['institution_id', 'id'])->on('class_subjects')->restrictOnDelete();
            $table->foreign(['institution_id', 'academic_session_id'], 'teacher_assignments_academic_session_id_fk')
                ->references(['institution_id', 'id'])->on('academic_sessions')->restrictOnDelete();
        });

        Schema::create('exam_papers', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('examination_id');
            $table->unsignedBigInteger('subject_id');
            $table->decimal('full_marks', 7, 2);
            $table->decimal('pass_marks', 7, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'examination_id'], 'exam_papers_examination_id_fk')
                ->references(['institution_id', 'id'])->on('examinations')->restrictOnDelete();
            $table->foreign(['institution_id', 'subject_id'], 'exam_papers_subject_id_fk')
                ->references(['institution_id', 'id'])->on('subjects')->restrictOnDelete();
        });

        Schema::create('published_results', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('examination_id');
            $table->unsignedBigInteger('student_id');
            $table->decimal('percentage', 5, 2);
            $table->decimal('gpa', 4, 2);
            $table->string('result', 20);
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'examination_id'], 'published_results_examination_id_fk')
                ->references(['institution_id', 'id'])->on('examinations')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'published_results_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('fee_plan_lines', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('fee_plan_id');
            $table->unsignedBigInteger('fee_head_id');
            $table->decimal('amount', 14, 2);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'fee_plan_id'], 'fee_plan_lines_fee_plan_id_fk')
                ->references(['institution_id', 'id'])->on('fee_plans')->restrictOnDelete();
            $table->foreign(['institution_id', 'fee_head_id'], 'fee_plan_lines_fee_head_id_fk')
                ->references(['institution_id', 'id'])->on('fee_heads')->restrictOnDelete();
        });

        Schema::create('hostel_leave_requests', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('hostel_allocation_id');
            $table->date('starts_on');
            $table->date('ends_on');
            $table->string('status', 24)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'hostel_allocation_id'], 'hostel_leave_requests_hostel_allocation_id_fk')
                ->references(['institution_id', 'id'])->on('hostel_allocations')->restrictOnDelete();
        });

        Schema::create('lms_resources', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('class_subject_id');
            $table->string('title', 180);
            $table->string('resource_type', 40);
            $table->string('resource_url', 255)->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'class_subject_id'], 'lms_resources_class_subject_id_fk')
                ->references(['institution_id', 'id'])->on('class_subjects')->restrictOnDelete();
        });

        Schema::create('student_promotions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('student_id');
            $table->unsignedBigInteger('from_enrollment_id');
            $table->unsignedBigInteger('to_enrollment_id')->nullable();
            $table->date('promoted_on');
            $table->string('status', 32)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'student_id'], 'student_promotions_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
            $table->foreign(['institution_id', 'from_enrollment_id'], 'student_promotions_from_enrollment_id_fk')
                ->references(['institution_id', 'id'])->on('enrollments')->restrictOnDelete();
            $table->foreign(['institution_id', 'to_enrollment_id'], 'student_promotions_to_enrollment_id_fk')
                ->references(['institution_id', 'id'])->on('enrollments')->restrictOnDelete();
        });

        Schema::create('assignment_submissions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('assignment_id');
            $table->unsignedBigInteger('student_id');
            $table->dateTime('submitted_at');
            $table->string('status', 24)->default('submitted');
            $table->decimal('marks', 7, 2)->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'assignment_id'], 'assignment_submissions_assignment_id_fk')
                ->references(['institution_id', 'id'])->on('assignments')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'assignment_submissions_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('student_attendance', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('attendance_session_id');
            $table->unsignedBigInteger('student_id');
            $table->string('status', 16)->default('present');
            $table->unsignedInteger('minutes_late')->default(0);
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'attendance_session_id'], 'student_attendance_attendance_session_id_fk')
                ->references(['institution_id', 'id'])->on('attendance_sessions')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'student_attendance_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('exam_marks', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('exam_paper_id');
            $table->unsignedBigInteger('student_id');
            $table->decimal('marks', 7, 2);
            $table->string('status', 24)->default('draft');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'exam_paper_id'], 'exam_marks_exam_paper_id_fk')
                ->references(['institution_id', 'id'])->on('exam_papers')->restrictOnDelete();
            $table->foreign(['institution_id', 'student_id'], 'exam_marks_student_id_fk')
                ->references(['institution_id', 'id'])->on('students')->restrictOnDelete();
        });

        Schema::create('exam_recheck_requests', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->unsignedBigInteger('exam_mark_id');
            $table->text('reason');
            $table->string('status', 24)->default('pending');
            $table->timestamps();
            $table->unique(['institution_id', 'id']);
            $table->foreign(['institution_id', 'exam_mark_id'], 'exam_recheck_requests_exam_mark_id_fk')
                ->references(['institution_id', 'id'])->on('exam_marks')->restrictOnDelete();
        });

    }

    public function down(): void
    {
        Schema::dropIfExists('exam_recheck_requests');
        Schema::dropIfExists('exam_marks');
        Schema::dropIfExists('student_attendance');
        Schema::dropIfExists('assignment_submissions');
        Schema::dropIfExists('student_promotions');
        Schema::dropIfExists('lms_resources');
        Schema::dropIfExists('hostel_leave_requests');
        Schema::dropIfExists('fee_plan_lines');
        Schema::dropIfExists('published_results');
        Schema::dropIfExists('exam_papers');
        Schema::dropIfExists('teacher_assignments');
        Schema::dropIfExists('attendance_sessions');
        Schema::dropIfExists('admission_offers');
        Schema::dropIfExists('enrollments');
        Schema::dropIfExists('assignments');
        Schema::dropIfExists('lesson_plans');
        Schema::dropIfExists('class_routines');
        Schema::dropIfExists('course_offerings');
        Schema::dropIfExists('hifz_assessments');
        Schema::dropIfExists('hifz_progress_logs');
        Schema::dropIfExists('hostel_allocations');
        Schema::dropIfExists('student_transport_assignments');
        Schema::dropIfExists('payment_refunds');
        Schema::dropIfExists('payment_allocations');
        Schema::dropIfExists('fee_plans');
        Schema::dropIfExists('examinations');
        Schema::dropIfExists('admission_applications');
        Schema::dropIfExists('class_subjects');
        Schema::dropIfExists('class_sections');
        Schema::dropIfExists('hifz_enrollments');
        Schema::dropIfExists('purchase_order_lines');
        Schema::dropIfExists('hostel_beds');
        Schema::dropIfExists('transport_stops');
        Schema::dropIfExists('library_loans');
        Schema::dropIfExists('bank_reconciliations');
        Schema::dropIfExists('student_payments');
        Schema::dropIfExists('student_invoice_lines');
        Schema::dropIfExists('payslip_items');
        Schema::dropIfExists('class_levels');
        Schema::dropIfExists('alumni_profiles');
        Schema::dropIfExists('integration_logs');
        Schema::dropIfExists('issued_certificates');
        Schema::dropIfExists('welfare_cases');
        Schema::dropIfExists('fund_expenses');
        Schema::dropIfExists('donations');
        Schema::dropIfExists('hifz_groups');
        Schema::dropIfExists('asset_assignments');
        Schema::dropIfExists('purchase_orders');
        Schema::dropIfExists('stock_movements');
        Schema::dropIfExists('meal_plans');
        Schema::dropIfExists('hostel_rooms');
        Schema::dropIfExists('transport_routes');
        Schema::dropIfExists('library_copies');
        Schema::dropIfExists('parent_meetings');
        Schema::dropIfExists('notification_deliveries');
        Schema::dropIfExists('scholarship_awards');
        Schema::dropIfExists('expenses');
        Schema::dropIfExists('bank_accounts');
        Schema::dropIfExists('ledger_lines');
        Schema::dropIfExists('student_invoices');
        Schema::dropIfExists('fee_heads');
        Schema::dropIfExists('grading_bands');
        Schema::dropIfExists('staff_appraisals');
        Schema::dropIfExists('payslips');
        Schema::dropIfExists('staff_leave_requests');
        Schema::dropIfExists('staff_attendance');
        Schema::dropIfExists('student_leave_requests');
        Schema::dropIfExists('student_incidents');
        Schema::dropIfExists('student_health_records');
        Schema::dropIfExists('student_transfers');
        Schema::dropIfExists('student_documents');
        Schema::dropIfExists('student_guardians');
        Schema::dropIfExists('subjects');
        Schema::dropIfExists('academic_programs');
        Schema::dropIfExists('report_exports');
        Schema::dropIfExists('integration_connections');
        Schema::dropIfExists('room_bookings');
        Schema::dropIfExists('campus_events');
        Schema::dropIfExists('visitor_logs');
        Schema::dropIfExists('certificate_templates');
        Schema::dropIfExists('donation_funds');
        Schema::dropIfExists('donors');
        Schema::dropIfExists('fixed_assets');
        Schema::dropIfExists('inventory_items');
        Schema::dropIfExists('suppliers');
        Schema::dropIfExists('hostels');
        Schema::dropIfExists('vehicles');
        Schema::dropIfExists('library_books');
        Schema::dropIfExists('notification_templates');
        Schema::dropIfExists('direct_messages');
        Schema::dropIfExists('notices');
        Schema::dropIfExists('scholarships');
        Schema::dropIfExists('financial_period_closings');
        Schema::dropIfExists('ledger_journals');
        Schema::dropIfExists('payment_methods');
        Schema::dropIfExists('chart_of_accounts');
        Schema::dropIfExists('grading_scales');
        Schema::dropIfExists('payroll_runs');
        Schema::dropIfExists('employees');
        Schema::dropIfExists('admission_cycles');
        Schema::dropIfExists('students');
        Schema::dropIfExists('guardians');
        Schema::dropIfExists('academic_calendar_events');
        Schema::dropIfExists('academic_terms');
        Schema::dropIfExists('academic_departments');
    }
};
