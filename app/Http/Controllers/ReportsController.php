<?php
namespace App\Http\Controllers;

use App\Support\SmsAccess;
use Illuminate\Support\Facades\DB;

final class ReportsController
{
    public const REPORTS = [
        'fees'=>['label'=>'Student Fee Aging','module'=>'finance','permission'=>'fees.view'],
        'trial-balance'=>['label'=>'General Ledger Trial Balance','module'=>'finance','permission'=>'accounting.reconcile'],
        'attendance'=>['label'=>'Student Attendance Summary','module'=>'attendance','permission'=>'attendance.view'],
        'results'=>['label'=>'Published Examination Results','module'=>'exams','permission'=>'exams.view'],
        'hifz'=>['label'=>'Hifz Progress Review','module'=>'hifz','permission'=>'hifz.progress.record'],
        'payroll'=>['label'=>'Payroll Register','module'=>'hr','permission'=>'hr.view'],
        'stock'=>['label'=>'Inventory Stock on Hand','module'=>'inventory','permission'=>'inventory.manage'],
        'donations'=>['label'=>'Donation Fund Register','module'=>'scholarship','permission'=>'donations.manage'],
    ];
    public static function forModule(string $slug): array
    {
        return array_filter(self::REPORTS,fn($r)=>$r['module']===$slug);
    }
    public function show(string $report)
    {
        $config=self::REPORTS[$report]??null;abort_unless($config,404);
        SmsAccess::require($config['permission']);
        $tenant=SmsAccess::institutionId();$columns=[];$rows=collect();$note='';
        switch ($report) {
            case 'fees':
                $columns=['Invoice','Student','Issued','Due','Billed','Paid','Outstanding','Status'];
                $rows=SmsAccess::scopedQuery('student_invoices')->join('students as s',function($j){
                    $j->on('s.id','=','student_invoices.student_id')->on('s.institution_id','=','student_invoices.institution_id');
                })->select('student_invoices.invoice_no as invoice','s.name as student','student_invoices.issued_on as issued',
                    'student_invoices.due_on as due','student_invoices.total_amount as billed','student_invoices.paid_amount as paid',
                    DB::raw('(student_invoices.total_amount - student_invoices.paid_amount) as outstanding'),'student_invoices.status')
                    ->orderBy('student_invoices.due_on')->limit(200)->get();
                $note='Shows first 200 invoices. Outstanding = billed minus net paid; review approved refunds separately.';
                break;
            case 'trial-balance':
                abort_unless((int)SmsAccess::membership()->can_access_all_campuses===1,403);
                $columns=['Account Code','Account Name','Type','Debit','Credit','Net Debit'];
                $rows=DB::table('chart_of_accounts as a')->leftJoin('ledger_lines as l',function($j){
                    $j->on('l.account_id','=','a.id')->on('l.institution_id','=','a.institution_id');
                })->leftJoin('ledger_journals as j',function($j){
                    $j->on('j.id','=','l.ledger_journal_id')->on('j.institution_id','=','l.institution_id')->where('j.status','=','posted');
                })->where('a.institution_id',$tenant)->groupBy('a.id','a.code','a.name','a.account_type')
                    ->select('a.code as account_code','a.name as account_name','a.account_type as type',
                        DB::raw('ROUND(SUM(CASE WHEN j.id IS NOT NULL THEN l.debit ELSE 0 END),2) as debit'),
                        DB::raw('ROUND(SUM(CASE WHEN j.id IS NOT NULL THEN l.credit ELSE 0 END),2) as credit'),
                        DB::raw('ROUND(SUM(CASE WHEN j.id IS NOT NULL THEN l.debit-l.credit ELSE 0 END),2) as net_debit'))
                    ->orderBy('a.code')->limit(200)->get();
                $note='Posted journals only. A balanced ledger has total debits equal to total credits.';
                break;
            case 'attendance':
                $columns=['Date','Student','Status','Minutes Late'];
                $rows=SmsAccess::scopedQuery('student_attendance')->join('students as s',function($j){
                    $j->on('s.id','=','student_attendance.student_id')->on('s.institution_id','=','student_attendance.institution_id');
                })->join('attendance_sessions as a',function($j){
                    $j->on('a.id','=','student_attendance.attendance_session_id')->on('a.institution_id','=','student_attendance.institution_id');
                })->select('a.attendance_on as date','s.name as student','student_attendance.status','student_attendance.minutes_late')
                    ->orderByDesc('a.attendance_on')->limit(200)->get();
                break;
            case 'results':
                $columns=['Exam','Student','Percentage','GPA','Result'];
                $rows=SmsAccess::scopedQuery('published_results')->join('students as s',function($j){
                    $j->on('s.id','=','published_results.student_id')->on('s.institution_id','=','published_results.institution_id');
                })->join('examinations as e',function($j){
                    $j->on('e.id','=','published_results.examination_id')->on('e.institution_id','=','published_results.institution_id');
                })->where('published_results.status','published')
                    ->select('e.name as exam','s.name as student','published_results.percentage','published_results.gpa','published_results.result')
                    ->orderByDesc('published_results.id')->limit(200)->get();
                break;
            case 'hifz':
                $columns=['Date','Student','Sabaq','Sabqi','Manzil','Juz','Accuracy %'];
                $rows=SmsAccess::scopedQuery('hifz_progress_logs')->join('hifz_enrollments as h',function($j){
                    $j->on('h.id','=','hifz_progress_logs.hifz_enrollment_id')->on('h.institution_id','=','hifz_progress_logs.institution_id');
                })->join('students as s',function($j){$j->on('s.id','=','h.student_id')->on('s.institution_id','=','h.institution_id');})
                    ->select('hifz_progress_logs.logged_on as date','s.name as student','hifz_progress_logs.sabaq',
                        'hifz_progress_logs.sabqi','hifz_progress_logs.manzil','hifz_progress_logs.juz_completed as juz',
                        'hifz_progress_logs.accuracy_percent as accuracy_percent')->orderByDesc('hifz_progress_logs.id')->limit(200)->get();
                break;
            case 'payroll':
                abort_unless((int)SmsAccess::membership()->can_access_all_campuses===1,403);
                $columns=['Employee','Period Start','Period End','Gross','Deduction','Net','Status'];
                $rows=SmsAccess::scopedQuery('payslips')->join('employees as e',function($j){$j->on('e.id','=','payslips.employee_id')->on('e.institution_id','=','payslips.institution_id');})
                    ->join('payroll_runs as p',function($j){$j->on('p.id','=','payslips.payroll_run_id')->on('p.institution_id','=','payslips.institution_id');})
                    ->select('e.name as employee','p.period_start','p.period_end','payslips.gross_amount as gross',
                        'payslips.deduction_amount as deduction','payslips.net_amount as net','payslips.status')
                    ->orderByDesc('payslips.id')->limit(200)->get();
                break;
            case 'stock':
                $columns=['SKU','Item','Unit','On Hand','Reorder Level'];
                $rows=SmsAccess::scopedQuery('inventory_items')->leftJoin('stock_movements as m',function($j){
                    $j->on('m.inventory_item_id','=','inventory_items.id')->on('m.institution_id','=','inventory_items.institution_id');
                })->groupBy('inventory_items.id','inventory_items.sku','inventory_items.name','inventory_items.unit','inventory_items.reorder_level')
                    ->select('inventory_items.sku','inventory_items.name','inventory_items.unit',DB::raw('COALESCE(SUM(m.quantity),0) as on_hand'),'inventory_items.reorder_level')
                    ->orderBy('inventory_items.name')->limit(200)->get();
                break;
            case 'donations':
                $columns=['Receipt','Donor','Fund','Restricted','Amount','Date'];
                $rows=SmsAccess::scopedQuery('donations')->join('donors as d',function($j){$j->on('d.id','=','donations.donor_id')->on('d.institution_id','=','donations.institution_id');})
                    ->join('donation_funds as f',function($j){$j->on('f.id','=','donations.donation_fund_id')->on('f.institution_id','=','donations.institution_id');})
                    ->select('donations.receipt_no as receipt','d.name as donor','f.name as fund','f.is_restricted as restricted','donations.amount','donations.received_on as date')
                    ->orderByDesc('donations.received_on')->limit(200)->get();
                break;
        }
        return view('reports.show',compact('report','config','columns','rows','note'));
    }
}
