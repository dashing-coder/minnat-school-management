<?php

declare(strict_types=1);

namespace App\Support;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Throwable;

/**
 * Read-only sanity checks for the *actual* configured Laravel/MySQL instance.
 * It does not modify credentials, data, sessions, schema or cache.
 */
final class SmsQualityAudit
{
    public static function run(): array
    {
        $checks = [];
        $add = static function (string $id, string $status, string $message) use (&$checks): void {
            $checks[] = compact('id', 'status', 'message');
        };
        $modules = ModuleCatalog::all();
        $tables = array_values(array_unique(array_merge(...array_map(
            static fn (array $module): array => $module['tables'],
            array_values($modules)
        ))));
        $add('MODULE_COUNT', count($modules) === 20 ? 'PASS' : 'FAIL', count($modules).' module definitions');
        $add('REGISTER_COUNT', count($tables) === 111 ? 'PASS' : 'FAIL', count($tables).' unique registered data tables');
        $summary = ['modules' => [], 'checks' => &$checks, 'read_only' => true];

        try {
            DB::connection()->getPdo();
            $database = (string) DB::connection()->getDatabaseName();
            $add('MYSQL_CONNECTION', 'PASS', 'Connected to the configured database '.$database);
        } catch (Throwable $e) {
            $add('MYSQL_CONNECTION', 'FAIL', 'Unable to connect to the configured database; check driver, host, port and .env.');
            $summary['pass'] = count(array_filter($checks, fn($c) => $c['status'] === 'PASS'));
            $summary['fail'] = count(array_filter($checks, fn($c) => $c['status'] === 'FAIL'));
            $summary['warn'] = 0;
            return $summary;
        }

        foreach ($modules as $key => $module) {
            $missing = []; $count = 0;
            foreach ($module['tables'] as $table) {
                if (!Schema::hasTable($table)) { $missing[] = $table; continue; }
                if (!Schema::hasColumn($table, 'institution_id') || !Schema::hasColumn($table, 'id')) {
                    $missing[] = $table.' (missing scope/id)'; continue;
                }
                ++$count;
            }
            $summary['modules'][$key] = [
                'name' => $module['name'], 'expected_tables' => count($module['tables']),
                'valid_tables' => $count, 'missing' => $missing,
                // Register availability is not equal to a completed business workflow.
                'workflow_verified' => false,
            ];
            $add('MODULE_'.strtoupper($key), $missing ? 'FAIL' : 'PASS',
                $module['name'].': '.$count.'/'.count($module['tables']).' registers with institution scope'.
                ($missing ? '; missing or invalid: '.implode(', ', $missing) : ''));
        }

        foreach (['users', 'institutions', 'institution_memberships', 'institution_roles',
            'membership_roles', 'institution_role_permissions', 'sms_permissions', 'sms_audit_logs'] as $table) {
            $add('CORE_'.strtoupper($table), Schema::hasTable($table) ? 'PASS' : 'FAIL',
                $table.' '.(Schema::hasTable($table) ? 'exists' : 'is missing'));
        }
        $session = config('session.driver');
        $cache = config('cache.default');
        $add('SESSIONS', $session === 'database' && !Schema::hasTable('sessions') ? 'FAIL' : 'PASS',
            'Session driver '.$session.($session === 'database' ? ' (database table '.(Schema::hasTable('sessions') ? 'present' : 'missing').')' : ''));
        $add('CACHE', $cache === 'database' && !Schema::hasTable('cache') ? 'FAIL' : 'PASS',
            'Cache driver '.$cache.($cache === 'database' ? ' (database table '.(Schema::hasTable('cache') ? 'present' : 'missing').')' : ''));
        if ($session === 'file') {
            $path = storage_path('framework/sessions');
            $add('SESSION_STORAGE', is_dir($path) && is_writable($path) ? 'PASS' : 'FAIL',
                'Storage sessions directory '.(is_dir($path) && is_writable($path) ? 'writable' : 'missing/not writable'));
        }
        $adminEmail = 'admin.school@example.test';
        if (Schema::hasTable('users') && Schema::hasTable('institution_memberships')) {
            $admin = DB::table('users')->where('email', $adminEmail)->first(['id']);
            $add('SCHOOL_ADMIN', $admin ? 'PASS' : 'WARN',
                $admin ? 'School demo administrator found (password not inspected)' : 'School demo administrator not found; normal for non-demo data');
            if ($admin) {
                $membership = DB::table('institution_memberships')->where('user_id', $admin->id)->where('status', 'active')->exists();
                $add('ADMIN_MEMBERSHIP', $membership ? 'PASS' : 'FAIL',
                    $membership ? 'School demo administrator has active institution membership' : 'Demo administrator has no active institution membership');
            }
        }

        // Integrity checks are strictly SELECT-only. Empty tables are acceptable.
        if (self::present(['students', 'campuses'])) {
            $invalid = DB::table('students as s')->leftJoin('campuses as c', 'c.id', '=', 's.campus_id')
                ->where(fn($q) => $q->whereNull('c.id')->orWhereColumn('c.institution_id', '<>', 's.institution_id'))->count();
            $add('STUDENT_CAMPUS_TENANT', $invalid ? 'FAIL' : 'PASS', $invalid.' mismatched student/campus institution associations');
        }
        if (self::present(['student_invoices'])) {
            $invalid = DB::table('student_invoices')
                ->whereRaw('paid_amount < 0 OR total_amount < 0 OR paid_amount > total_amount')->count();
            $add('INVOICE_AMOUNT_BOUNDS', $invalid ? 'FAIL' : 'PASS', $invalid.' invoices with invalid amount bounds');
        }
        if (self::present(['student_invoices', 'payment_allocations', 'payment_refunds', 'student_payments'])) {
            $allocated = DB::table('payment_allocations')
                ->select('institution_id','student_invoice_id')
                ->selectRaw('SUM(amount) AS amount')
                ->groupBy('institution_id','student_invoice_id');
            $refunded = DB::table('payment_refunds as r')->join('student_payments as p',function($join){
                $join->on('p.id','=','r.student_payment_id')->on('p.institution_id','=','r.institution_id');
            })->whereIn('r.status',['approved','processed'])
                ->select('p.institution_id','p.student_invoice_id')
                ->selectRaw('SUM(r.amount) AS amount')
                ->groupBy('p.institution_id','p.student_invoice_id');
            $rows = DB::table('student_invoices as i')
                ->leftJoinSub($allocated,'a',function($j){
                    $j->on('a.institution_id','=','i.institution_id')->on('a.student_invoice_id','=','i.id');
                })->leftJoinSub($refunded,'r',function($j){
                    $j->on('r.institution_id','=','i.institution_id')->on('r.student_invoice_id','=','i.id');
                })->select('i.id','i.paid_amount')->selectRaw('COALESCE(a.amount,0) AS allocated')
                ->selectRaw('COALESCE(r.amount,0) AS refunded')->get();
            $mismatched = $rows->filter(fn($row) =>
                abs((float)$row->paid_amount-((float)$row->allocated-(float)$row->refunded)) > 0.009)->count();
            $add('INVOICE_PAYMENT_RECONCILIATION', $mismatched ? 'FAIL' : 'PASS',
                $mismatched.' invoices differ from allocations minus approved refunds');
        }
        if (self::present(['student_invoices','student_invoice_lines'])) {
            $lineTotals=DB::table('student_invoice_lines')->select('institution_id','student_invoice_id')
                ->selectRaw('SUM(amount) AS amount')->groupBy('institution_id','student_invoice_id');
            $rows=DB::table('student_invoices as i')->leftJoinSub($lineTotals,'l',function($j){
                $j->on('l.institution_id','=','i.institution_id')->on('l.student_invoice_id','=','i.id');
            })->select('i.total_amount')->selectRaw('COALESCE(l.amount,0) AS line_amount')->get();
            $bad=$rows->filter(fn($r)=>abs((float)$r->total_amount-(float)$r->line_amount)>0.009)->count();
            $add('INVOICE_LINE_TOTALS',$bad?'FAIL':'PASS',$bad.' invoice headers differ from their fee lines');
        }
        if (self::present(['ledger_journals'])) {
            $dups=DB::table('ledger_journals')->whereNotNull('source_reference')
                ->select('institution_id','source_type','source_reference')
                ->groupBy('institution_id','source_type','source_reference')
                ->havingRaw('COUNT(*) > 1')->get()->count();
            $add('JOURNAL_SOURCE_UNIQUENESS',$dups?'FAIL':'PASS',$dups.' duplicated journal source keys');
        }
        if (self::present(['ledger_journals', 'ledger_lines'])) {
            $journals = DB::table('ledger_journals as j')
                ->leftJoin('ledger_lines as l', function ($join) {
                    $join->on('l.ledger_journal_id', '=', 'j.id')->on('l.institution_id', '=', 'j.institution_id');
                })->where('j.status', 'posted')->select('j.id')
                ->selectRaw('COALESCE(SUM(l.debit),0) AS debits, COALESCE(SUM(l.credit),0) AS credits, COUNT(l.id) AS line_count')
                ->groupBy('j.id')->get();
            $unbalanced = $journals->filter(fn($row) => abs((float)$row->debits-(float)$row->credits)>0.009 || (int)$row->line_count<2)->count();
            $add('POSTED_JOURNAL_BALANCE', $unbalanced ? 'FAIL' : 'PASS', $unbalanced.' posted journals unbalanced or missing 2 entries');
        }
        if (self::present(['student_attendance'])) {
            $duplicates = DB::table('student_attendance')->select('institution_id', 'attendance_session_id', 'student_id')
                ->groupBy('institution_id', 'attendance_session_id', 'student_id')->havingRaw('COUNT(*) > 1')->get()->count();
            $add('ATTENDANCE_DUPLICATES', $duplicates ? 'FAIL' : 'PASS', $duplicates.' duplicate student attendance keys');
        }
        if (self::present(['exam_marks','exam_papers'])) {
            $invalid=DB::table('exam_marks as m')->join('exam_papers as p',function($j){
                $j->on('p.id','=','m.exam_paper_id')->on('p.institution_id','=','m.institution_id');
            })->where(fn($q)=>$q->where('m.marks','<',0)->orWhereColumn('m.marks','>','p.full_marks'))->count();
            $add('EXAM_MARK_BOUNDS',$invalid?'FAIL':'PASS',$invalid.' exam marks outside paper bounds');
        }
        if (self::present(['payslips'])) {
            $invalid=DB::table('payslips')->whereRaw('ABS(gross_amount - deduction_amount - net_amount) > 0.009')->count();
            $add('PAYROLL_NET_AMOUNT',$invalid?'FAIL':'PASS',$invalid.' payslips with inconsistent net salary');
        }
        if (self::present(['hostel_allocations'])) {
            $duplicates=DB::table('hostel_allocations')->where('status','active')
                ->select('institution_id','hostel_bed_id')->groupBy('institution_id','hostel_bed_id')
                ->havingRaw('COUNT(*) > 1')->get()->count();
            $add('HOSTEL_BED_DOUBLE_BOOKING',$duplicates?'FAIL':'PASS',$duplicates.' beds with multiple active allocations');
        }
        if (self::present(['students'])) {
            $count=DB::table('students')->count();
            $add('STUDENT_RECORDS',$count?'PASS':'WARN',$count.' student records; empty business data means workflows are not exercised');
        }
        $summary['pass'] = count(array_filter($checks, fn($c) => $c['status'] === 'PASS'));
        $summary['fail'] = count(array_filter($checks, fn($c) => $c['status'] === 'FAIL'));
        $summary['warn'] = count(array_filter($checks, fn($c) => $c['status'] === 'WARN'));
        return $summary;
    }

    private static function present(array $tables): bool
    {
        foreach ($tables as $table) if (!Schema::hasTable($table)) return false;
        return true;
    }
}
