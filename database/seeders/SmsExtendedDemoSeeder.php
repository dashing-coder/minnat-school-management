<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use RuntimeException;

/**
 * ADDITIVE FICTIONAL demo data for the CampusSphere expanded Laravel schema.
 * Requires the 3 demo institutions from SmsFullDemoSeeder.
 * Never writes to users, roles, permissions or existing student records.
 * Requires explicit local/testing opt-in and refuses duplicate application.
 */
final class SmsExtendedDemoSeeder extends Seeder
{
    private int $added = 0;
    private array $byTable = [];
    private const DEMO_STAMP = '2026-11-05 09:00:00';

    private const TENANTS = [
        ['SCHDEMO', 'S', 'SCH-EX', 2500, 'school'],
        ['COLDEMO', 'C', 'COL-EX', 3800, 'college'],
        ['MADDEMO', 'M', 'MAD-EX', 1800, 'madrasha'],
    ];

    public function run(): void
    {
        if (! app()->environment(['local', 'testing']) || ! filter_var(env('SMS_ALLOW_RICH_DEMO_SEED', false), FILTER_VALIDATE_BOOLEAN)) {
            throw new RuntimeException('Refused. Requires APP_ENV=local/testing and SMS_ALLOW_RICH_DEMO_SEED=true.');
        }

        $tables = [
            'institutions', 'users', 'campuses', 'academic_sessions', 'class_sections',
            'admission_cycles', 'students', 'guardians', 'student_guardians',
            'student_documents', 'enrollments', 'attendance_sessions', 'student_attendance',
            'fee_heads', 'chart_of_accounts', 'payment_methods', 'student_invoices',
            'student_invoice_lines', 'student_payments', 'payment_allocations',
            'ledger_journals', 'ledger_lines', 'examinations', 'exam_papers',
            'exam_marks', 'published_results', 'employees', 'staff_attendance',
            'payroll_runs', 'payslips', 'payslip_items', 'library_books',
            'library_copies', 'library_loans', 'inventory_items', 'stock_movements',
            'hostels', 'hostel_rooms', 'hostel_beds', 'hostel_allocations',
            'transport_routes', 'transport_stops', 'student_transport_assignments',
            'donors', 'donation_funds', 'donations', 'scholarships',
            'scholarship_awards', 'hifz_groups', 'hifz_enrollments',
            'hifz_progress_logs', 'hifz_assessments', 'notices', 'admission_applications',
        ];
        foreach ($tables as $table) {
            if (! Schema::hasTable($table)) {
                throw new RuntimeException("Missing table {$table}. Run migrations before seeding.");
            }
        }
        if (! DB::table('users')->where('email', 'admin.school@example.test')->exists()) {
            throw new RuntimeException('The expected demo administrator account was not found. No data inserted.');
        }

        // Protect other real institutions from accidental demo contamination.
        $codes = DB::table('institutions')->orderBy('code')->pluck('code')->all();
        $expected = ['COLDEMO', 'MADDEMO', 'SCHDEMO'];
        if ($codes !== $expected) {
            throw new RuntimeException('Only a database with precisely SCHDEMO, COLDEMO, MADDEMO tenants is allowed.');
        }
        foreach (self::TENANTS as [$code, , $prefix]) {
            $institution = DB::table('institutions')->where('code', $code)->first();
            if (! $institution || ! DB::table('students')->where('institution_id', $institution->id)->exists()) {
                throw new RuntimeException('Baseline demo fixtures are incomplete for ' . $code . '.');
            }
            if (DB::table('students')->where('institution_id', $institution->id)
                ->where('admission_no', 'like', $prefix . '-%')->exists()) {
                throw new RuntimeException('Extended demo rows already exist for ' . $code . '. Aborting without changing data.');
            }
        }

        DB::transaction(function (): void {
            foreach (self::TENANTS as [$code, $tag, $prefix, $tuition, $kind]) {
                $this->seedInstitution($code, $tag, $prefix, $tuition, $kind);
            }
            $this->validateFinancials();
        }, 1);

        $this->command?->info("Extended fictitious sample dataset inserted: {$this->added} rows.");
        foreach ($this->byTable as $table => $count) {
            $this->command?->line(sprintf('  %-32s %d', $table, $count));
        }
        $this->command?->warn('Remove SMS_ALLOW_RICH_DEMO_SEED=true from .env. No user passwords were changed.');
    }

    private function seedInstitution(string $code, string $tag, string $prefix, int $tuition, string $kind): void
    {
        $inst = DB::table('institutions')->where('code', $code)->first();
        $tenant = (int) $inst->id;
        $campus = DB::table('campuses')->where('institution_id', $tenant)->first();
        $session = DB::table('academic_sessions')->where('institution_id', $tenant)->where('code', '2026')->first();
        $section = DB::table('class_sections')->where('institution_id', $tenant)->first();
        $cycle = DB::table('admission_cycles')->where('institution_id', $tenant)->first();
        $subject = DB::table('subjects')->where('institution_id', $tenant)->first();
        $receivable = DB::table('chart_of_accounts')->where('institution_id', $tenant)->where('code', '1100')->first();
        $revenue = DB::table('chart_of_accounts')->where('institution_id', $tenant)->where('code', '4100')->where('account_type', 'income')->first();
        $cash = DB::table('chart_of_accounts')->where('institution_id', $tenant)->where('code', '1000')->where('account_type', 'asset')->first();
        $paymentMethod = DB::table('payment_methods')->where('institution_id', $tenant)->first();
        $fund = DB::table('donation_funds')->where('institution_id', $tenant)->first();
        $scholarship = DB::table('scholarships')->where('institution_id', $tenant)->first();
        $hostel = DB::table('hostels')->where('institution_id', $tenant)->first();
        $route = DB::table('transport_routes')->where('institution_id', $tenant)->first();
        $hifzGroup = $kind === 'madrasha'
            ? DB::table('hifz_groups')->where('institution_id', $tenant)->first()
            : null;

        foreach (compact('campus', 'session', 'section', 'cycle', 'subject', 'receivable', 'revenue', 'cash', 'paymentMethod', 'fund', 'scholarship', 'hostel', 'route') as $name => $item) {
            if (! $item) {
                throw new RuntimeException("Baseline demo {$code} missing required {$name} reference.");
            }
        }
        if ($kind === 'madrasha' && ! $hifzGroup) {
            throw new RuntimeException('Madrasha demo Hifz group is missing.');
        }
        $classLevel = DB::table('class_levels')->where('institution_id', $tenant)
            ->where('id', $section->class_level_id)->first();
        if (! (bool) $receivable->is_active || ! (bool) $cash->is_active || ! (bool) $revenue->is_active) {
            throw new RuntimeException('Demo financial accounts must be active before inserting transactions.');
        }
        if (! $classLevel) {
            throw new RuntimeException('Missing class level for demo section.');
        }

        $fee = $this->add('fee_heads', [
            'institution_id' => $tenant, 'code' => 'DEMO-TUITION-EXT',
            'name' => 'Extended Demo Tuition', 'revenue_account_id' => $revenue->id,
        ]);

        $students = [];
        $names = [
            'Anika Rahman', 'Shahid Hasan', 'Nusrat Jahan', 'Fahim Ahmed',
            'Sadia Sultana', 'Tanvir Hossain', 'Mim Akter', 'Rahat Islam',
            'Tasnim Khan', 'Arif Mahmud', 'Jannat Ferdous', 'Abir Chowdhury',
            'Nadia Islam', 'Farhan Kabir', 'Afia Begum', 'Sakib Alam',
            'Mahin Ahmed', 'Sumaiya Noor', 'Rafiul Hasan', 'Ishrat Jahan',
            'Zahid Rahman', 'Rukaiya Akter', 'Adnan Siddique', 'Lamisa Haque',
        ];

        $guardianIds = [];
        for ($family = 1; $family <= 12; $family++) {
            $guardianIds[$family] = $this->add('guardians', [
                'institution_id' => $tenant, 'user_id' => null,
                'name' => 'Demo Guardian ' . $tag . '-' . sprintf('%02d', $family),
                'relation' => 'parent', 'phone' => '000-DMO-' . $tag . sprintf('%04d', $family),
                'email' => 'guardian-' . strtolower($tag) . '-' . $family . '@example.test',
            ]);
        }

        for ($n = 1; $n <= 24; $n++) {
            $name = $names[$n - 1];
            $id = $this->add('students', [
                'institution_id' => $tenant, 'user_id' => null, 'campus_id' => $campus->id,
                'admission_no' => $prefix . '-' . sprintf('%04d', $n),
                'name' => $name, 'gender' => $n % 2 ? 'female' : 'male',
                'birth_date' => ($kind === 'college' ? '2009' : '2014') . '-'
                    . sprintf('%02d', ($n % 12) + 1) . '-' . sprintf('%02d', ($n % 25) + 1),
                'blood_group' => ['A+', 'B+', 'O+', 'AB+'][$n % 4], 'status' => 'active',
            ]);
            $students[$n] = $id;
            $guardianId = $guardianIds[(int) ceil($n / 2)];
            $this->add('student_guardians', [
                'institution_id' => $tenant, 'student_id' => $id,
                'guardian_id' => $guardianId, 'relationship' => 'parent', 'is_primary' => 1,
            ]);
            $this->add('student_documents', [
                'institution_id' => $tenant, 'student_id' => $id,
                'document_type' => 'birth_certificate', 'file_path' => null,
                'verification_status' => 'pending_upload',
            ]);
            $this->add('enrollments', [
                'institution_id' => $tenant, 'student_id' => $id,
                'academic_session_id' => $session->id, 'class_section_id' => $section->id,
                'roll_no' => (string) ($n + 20), 'status' => 'active',
            ]);
        }

        // Admission applications are illustrative workflow states, without duplicate enrollments.
        for ($n = 1; $n <= 8; $n++) {
            $this->add('admission_applications', [
                'institution_id' => $tenant, 'admission_cycle_id' => $cycle->id,
                'class_level_id' => $classLevel->id,
                'application_no' => 'EX-APP-' . $tag . '-' . sprintf('%04d', $n),
                'applicant_name' => $n <= 4 ? $names[$n - 1] : 'Demo Applicant ' . $tag . '-' . $n,
                'guardian_phone' => '000-DEMO-' . $tag . '-' . sprintf('%03d', $n),
                'score' => $n <= 6 ? (string) (65 + $n * 3) . '.00' : null,
                'status' => $n <= 4 ? 'approved' : ($n <= 6 ? 'waitlisted' : 'submitted'),
            ]);
        }

        // Five classroom attendance days with present/late/absent/excused variation.
        for ($day = 1; $day <= 5; $day++) {
            $date = sprintf('2026-10-%02d', 20 + $day);
            $attendanceSession = $this->add('attendance_sessions', [
                'institution_id' => $tenant, 'class_section_id' => $section->id,
                'attendance_on' => $date, 'period_code' => 'EXT-DEMO-' . $tag,
                'status' => 'closed',
            ]);
            foreach ($students as $index => $studentId) {
                $rule = ($index + $day) % 12;
                $status = $rule === 0 ? 'absent' : ($rule === 1 ? 'late' : ($rule === 2 ? 'excused' : 'present'));
                $this->add('student_attendance', [
                    'institution_id' => $tenant, 'attendance_session_id' => $attendanceSession,
                    'student_id' => $studentId, 'status' => $status,
                    'minutes_late' => $status === 'late' ? 10 : 0,
                ]);
            }
        }

        // New explicitly 100-mark sample exam; does not alter legacy 0-mark demo papers.
        $examId = $this->add('examinations', [
            'institution_id' => $tenant, 'academic_session_id' => $session->id,
            'class_level_id' => $classLevel->id,
            'name' => 'Extended Demo Class Test 2026', 'exam_type' => 'class_test',
            'starts_on' => '2026-10-21', 'ends_on' => '2026-10-21', 'status' => 'published',
        ]);
        $paperId = $this->add('exam_papers', [
            'institution_id' => $tenant, 'examination_id' => $examId,
            'subject_id' => $subject->id, 'full_marks' => '100.00', 'pass_marks' => '33.00',
        ]);
        foreach ($students as $n => $studentId) {
            $marks = 24 + (($n * 7 + $tenant * 3) % 74);
            $this->add('exam_marks', [
                'institution_id' => $tenant, 'exam_paper_id' => $paperId,
                'student_id' => $studentId, 'marks' => number_format($marks, 2, '.', ''),
                'status' => 'approved',
            ]);
            $gpa = match (true) {
                $marks >= 80 => '5.00', $marks >= 70 => '4.00', $marks >= 60 => '3.50',
                $marks >= 50 => '3.00', $marks >= 40 => '2.00', $marks >= 33 => '1.00',
                default => '0.00',
            };
            $this->add('published_results', [
                'institution_id' => $tenant, 'examination_id' => $examId,
                'student_id' => $studentId, 'percentage' => number_format($marks, 2, '.', ''),
                'gpa' => $gpa, 'result' => $marks >= 33 ? 'pass' : 'fail', 'status' => 'published',
            ]);
        }

        // Invoice + real double-entry demo journal for ALL invoices, regardless of payment state.
        foreach ($students as $n => $studentId) {
            $totalCents = ($tuition + (($n - 1) % 4) * 150) * 100;
            $statusType = $n % 3; // 0 unpaid, 1 partial, 2 paid
            $paidCents = $statusType === 0 ? 0 : ($statusType === 1 ? (int) ($totalCents / 2) : $totalCents);
            $total = $this->money($totalCents);
            $paid = $this->money($paidCents);
            $invoiceNumber = 'EX-INV-' . $tag . '-' . sprintf('%04d', $n);
            $invoiceId = $this->add('student_invoices', [
                'institution_id' => $tenant, 'student_id' => $studentId,
                'invoice_no' => $invoiceNumber, 'issued_on' => '2026-10-01',
                'due_on' => '2026-10-15', 'total_amount' => $total,
                'paid_amount' => $paid, 'status' => $paidCents === 0 ? 'unpaid' :
                    ($paidCents === $totalCents ? 'paid' : 'partial'),
            ]);
            $this->add('student_invoice_lines', [
                'institution_id' => $tenant, 'student_invoice_id' => $invoiceId,
                'fee_head_id' => $fee, 'description' => 'October 2026 demo tuition', 'amount' => $total,
            ]);
            $this->journal($tenant, 'EX-J-INV-' . $tag . '-' . sprintf('%04d', $n),
                'invoice', $invoiceNumber, $total, (int) $receivable->id, (int) $revenue->id);
            if ($paidCents > 0) {
                $paymentRef = 'EX-PAY-' . $tag . '-' . sprintf('%04d', $n);
                $paymentId = $this->add('student_payments', [
                    'institution_id' => $tenant, 'student_id' => $studentId,
                    'student_invoice_id' => $invoiceId, 'payment_method_id' => $paymentMethod->id,
                    'amount' => $paid, 'paid_on' => '2026-10-12',
                    'reference_no' => $paymentRef, 'status' => 'posted',
                ]);
                $this->add('payment_allocations', [
                    'institution_id' => $tenant, 'student_payment_id' => $paymentId,
                    'student_invoice_id' => $invoiceId, 'amount' => $paid,
                ]);
                $this->journal($tenant, 'EX-J-PAY-' . $tag . '-' . sprintf('%04d', $n),
                    'payment', $paymentRef, $paid, (int) $cash->id, (int) $receivable->id);
            }
        }

        $payrollRun = $this->add('payroll_runs', [
            'institution_id' => $tenant, 'period_start' => '2026-10-01',
            'period_end' => '2026-10-31', 'status' => 'draft',
        ]);
        for ($n = 1; $n <= 3; $n++) {
            $basic = 26000 + $n * 2500 + $tenant * 1000;
            $deduction = $n === 3 ? 500 : 0;
            $empId = $this->add('employees', [
                'institution_id' => $tenant, 'user_id' => null,
                'campus_id' => $campus->id,
                'employee_no' => 'EX-EMP-' . $tag . '-' . sprintf('%03d', $n),
                'name' => 'Demo Staff ' . $tag . '-' . $n,
                'designation' => ['Subject Teacher', 'Office Assistant', 'Librarian'][$n - 1],
                'joined_on' => '2025-07-01', 'basic_salary' => $this->money($basic * 100),
                'status' => 'active',
            ]);
            $slipId = $this->add('payslips', [
                'institution_id' => $tenant, 'payroll_run_id' => $payrollRun,
                'employee_id' => $empId, 'gross_amount' => $this->money($basic * 100),
                'deduction_amount' => $this->money($deduction * 100),
                'net_amount' => $this->money(($basic - $deduction) * 100), 'status' => 'draft',
            ]);
            $this->add('payslip_items', [
                'institution_id' => $tenant, 'payslip_id' => $slipId,
                'item_type' => 'earning', 'description' => 'Basic salary (demo)',
                'amount' => $this->money($basic * 100),
            ]);
            if ($deduction > 0) {
                $this->add('payslip_items', [
                    'institution_id' => $tenant, 'payslip_id' => $slipId,
                    'item_type' => 'deduction', 'description' => 'Demo salary advance',
                    'amount' => $this->money($deduction * 100),
                ]);
            }
            foreach (['2026-10-20', '2026-10-21', '2026-10-22', '2026-10-23'] as $date) {
                $this->add('staff_attendance', [
                    'institution_id' => $tenant, 'employee_id' => $empId,
                    'attendance_on' => $date, 'status' => 'present',
                    'check_in_at' => $date . ' 08:30:00',
                ]);
            }
        }

        for ($n = 1; $n <= 3; $n++) {
            $bookId = $this->add('library_books', [
                'institution_id' => $tenant,
                'isbn' => null,
                'title' => [
                    'Demo Mathematics Workbook', 'Demo English Reader', 'Demo General Knowledge',
                ][$n - 1] . ' (' . $tag . ')',
                'author' => 'CampusSphere Demo Editorial', 'category' => 'Academic',
            ]);
            for ($copy = 1; $copy <= 2; $copy++) {
                $isIssued = $n <= 2 && $copy === 1;
                $copyId = $this->add('library_copies', [
                    'institution_id' => $tenant, 'library_book_id' => $bookId,
                    'barcode' => 'EX-LIB-' . $tag . '-' . $n . '-' . $copy,
                    'status' => $isIssued ? 'issued' : 'available',
                ]);
                if ($isIssued) {
                    $this->add('library_loans', [
                        'institution_id' => $tenant, 'library_copy_id' => $copyId,
                        'student_id' => $students[$n], 'issued_on' => '2026-10-20',
                        'due_on' => '2026-11-20', 'returned_on' => null,
                        'fine_amount' => '0.00', 'status' => 'issued',
                    ]);
                }
            }
        }

        for ($n = 1; $n <= 3; $n++) {
            $item = $this->add('inventory_items', [
                'institution_id' => $tenant,
                'sku' => 'EX-ITEM-' . $tag . '-' . sprintf('%02d', $n),
                'name' => ['A4 Exercise Books', 'Whiteboard Markers', 'Classroom Chalk'][$n - 1]
                    . ' (' . $tag . ')',
                'unit' => 'piece', 'reorder_level' => 15,
            ]);
            foreach (['in' => 100, 'out' => -15] as $direction => $quantity) {
                $this->add('stock_movements', [
                    'institution_id' => $tenant, 'inventory_item_id' => $item,
                    'quantity' => $quantity, 'movement_type' => $direction,
                    'reference_no' => 'EX-STOCK-' . $tag . '-' . $n . '-' . strtoupper($direction),
                    'moved_on' => $direction === 'receive' ? '2026-10-10' : '2026-10-18',
                ]);
            }
        }

        $allocated = 0;
        for ($room = 1; $room <= 2; $room++) {
            $roomId = $this->add('hostel_rooms', [
                'institution_id' => $tenant, 'hostel_id' => $hostel->id,
                'room_code' => 'EX-RM-' . $tag . '-' . $room, 'capacity' => 3,
            ]);
            for ($bed = 1; $bed <= 3; $bed++) {
                $allocated++;
                $occupied = $allocated <= 3;
                $bedId = $this->add('hostel_beds', [
                    'institution_id' => $tenant, 'hostel_room_id' => $roomId,
                    'bed_code' => 'EX-BED-' . $bed,
                    'status' => $occupied ? 'occupied' : 'available',
                ]);
                if ($occupied) {
                    $this->add('hostel_allocations', [
                        'institution_id' => $tenant, 'student_id' => $students[$allocated + 5],
                        'hostel_bed_id' => $bedId, 'check_in_on' => '2026-10-01',
                        'monthly_fee' => $this->money(($kind === 'madrasha' ? 1200 : 2000) * 100),
                        'status' => 'active',
                    ]);
                }
            }
        }

        $stops = [];
        for ($n = 1; $n <= 2; $n++) {
            $stops[$n] = $this->add('transport_stops', [
                'institution_id' => $tenant, 'transport_route_id' => $route->id,
                'name' => 'Extended Demo Stop ' . $tag . '-' . $n,
                'stop_order' => 10 + $n,
            ]);
        }
        for ($n = 1; $n <= 4; $n++) {
            $this->add('student_transport_assignments', [
                'institution_id' => $tenant, 'student_id' => $students[$n + 10],
                'transport_route_id' => $route->id,
                'transport_stop_id' => $stops[$n % 2 + 1],
                'starts_on' => '2026-10-01', 'monthly_fee' => '800.00',
            ]);
        }

        for ($n = 1; $n <= 2; $n++) {
            $donor = $this->add('donors', [
                'institution_id' => $tenant, 'name' => 'Fictional Supporter ' . $tag . '-' . $n,
                'phone' => null,
                'email' => 'supporter-' . strtolower($tag) . '-' . $n . '@example.test',
            ]);
            $this->add('donations', [
                'institution_id' => $tenant, 'donor_id' => $donor,
                'donation_fund_id' => $fund->id,
                'receipt_no' => 'EX-DON-' . $tag . '-' . sprintf('%04d', $n),
                'amount' => $this->money((1500 + $n * 500) * 100),
                'received_on' => '2026-10-14',
            ]);
        }

        for ($n = 1; $n <= 3; $n++) {
            $this->add('scholarship_awards', [
                'institution_id' => $tenant, 'scholarship_id' => $scholarship->id,
                'student_id' => $students[$n + 12], 'amount' => '500.00',
                'status' => 'approved',
            ]);
        }
        foreach (['Parent Orientation Meeting', 'Demo Midterm Notice'] as $title) {
            $this->add('notices', [
                'institution_id' => $tenant,
                'title' => $title . ' (' . $tag . ')',
                'body' => 'This is a fictional CampusSphere sample notice; no real announcement was sent.',
                'audience' => 'all', 'published_at' => '2026-10-15 09:00:00',
            ]);
        }

        if ($kind === 'madrasha') {
            for ($n = 1; $n <= 8; $n++) {
                $enrollment = $this->add('hifz_enrollments', [
                    'institution_id' => $tenant, 'student_id' => $students[$n],
                    'hifz_group_id' => $hifzGroup->id, 'started_on' => '2026-09-01',
                    'target_juz' => 30, 'status' => 'active',
                ]);
                for ($d = 1; $d <= 3; $d++) {
                    $this->add('hifz_progress_logs', [
                        'institution_id' => $tenant, 'hifz_enrollment_id' => $enrollment,
                        'logged_on' => sprintf('2026-10-%02d', 15 + $d),
                        'sabaq' => 'Surah Al-Mulk, verses ' . ($d * 5) . '-' . ($d * 5 + 4),
                        'sabqi' => 'Surah Ar-Rahman revision',
                        'manzil' => 'Juz Amma daily revision',
                        'juz_completed' => $d + ($n % 5),
                        'accuracy_percent' => number_format(84 + (($n + $d) % 10), 2, '.', ''),
                        'notes' => 'Fictional Hifz progress for testing.',
                    ]);
                }
                $this->add('hifz_assessments', [
                    'institution_id' => $tenant, 'hifz_enrollment_id' => $enrollment,
                    'assessed_on' => '2026-10-24',
                    'score' => number_format(80 + ($n % 16), 2, '.', ''),
                    'remarks' => 'Illustrative weekly assessment',
                ]);
            }
        }
    }

    private function add(string $table, array $attributes): int
    {
        $attributes['created_at'] = self::DEMO_STAMP;
        $attributes['updated_at'] = self::DEMO_STAMP;
        $id = (int) DB::table($table)->insertGetId($attributes);
        $this->added++;
        $this->byTable[$table] = ($this->byTable[$table] ?? 0) + 1;
        return $id;
    }

    private function money(int $cents): string
    {
        return sprintf('%d.%02d', intdiv($cents, 100), $cents % 100);
    }

    private function journal(int $tenant, string $number, string $sourceType, string $reference,
        string $amount, int $debitAccount, int $creditAccount): void
    {
        $journal = $this->add('ledger_journals', [
            'institution_id' => $tenant, 'journal_no' => $number,
            'posted_on' => '2026-10-12', 'source_type' => $sourceType,
            'source_reference' => $reference, 'description' => 'Extended fictional demo transaction',
            'status' => 'posted',
        ]);
        $this->add('ledger_lines', [
            'institution_id' => $tenant, 'ledger_journal_id' => $journal,
            'account_id' => $debitAccount, 'debit' => $amount, 'credit' => '0.00',
        ]);
        $this->add('ledger_lines', [
            'institution_id' => $tenant, 'ledger_journal_id' => $journal,
            'account_id' => $creditAccount, 'debit' => '0.00', 'credit' => $amount,
        ]);
    }

    private function validateFinancials(): void
    {
        // Count debit-credit imbalances in the new extended-demo posted journals.
        $bad = DB::table('ledger_journals as j')
            ->join('ledger_lines as l', function ($join): void {
                $join->on('l.ledger_journal_id', '=', 'j.id')
                    ->on('l.institution_id', '=', 'j.institution_id');
            })
            ->where('j.journal_no', 'like', 'EX-J-%')
            ->groupBy('j.id')
            ->havingRaw('ROUND(SUM(l.debit) - SUM(l.credit), 2) <> 0')
            ->get()->count();
        if ($bad > 0) {
            throw new RuntimeException("Demo ledger is unbalanced: {$bad} journals. Rollback in progress.");
        }
    }
}
