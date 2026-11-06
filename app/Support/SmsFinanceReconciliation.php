<?php

declare(strict_types=1);

namespace App\Support;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/** Read-only institutional finance integrity checks. No journal or data modifications. */
final class SmsFinanceReconciliation
{
    public static function run(?int $institutionId = null): array
    {
        $checks = [];
        $check = static function (string $name, string $status, int $count, array $ids = []) use (&$checks): void {
            $checks[] = ['check' => $name, 'status' => $status, 'exceptions' => $count, 'sample_ids' => array_slice($ids, 0, 20)];
        };
        $required = ['institutions','student_invoices','student_invoice_lines','student_payments',
            'payment_allocations','payment_refunds','ledger_journals','ledger_lines',
            'payslips','payslip_items','payroll_runs'];
        foreach ($required as $table) {
            if (!Schema::hasTable($table)) {
                return ['status' => 'FAIL', 'institution_id' => $institutionId,
                    'checks' => [['check' => 'MISSING_TABLE_'.$table, 'status' => 'FAIL', 'exceptions' => 1, 'sample_ids' => []]]];
            }
        }
        $tenant = static fn($q, string $column = 'institution_id') => $institutionId === null ? $q : $q->where($column,$institutionId);
        $invoice = $tenant(DB::table('student_invoices'))->get();
        if ($invoice->isEmpty()) $check('INVOICES_PRESENT','WARN',0);

        $lineSums = $tenant(DB::table('student_invoice_lines'))
            ->select('institution_id','student_invoice_id')->selectRaw('SUM(amount) AS amount')
            ->groupBy('institution_id','student_invoice_id')->get()
            ->keyBy(fn($r) => $r->institution_id.':'.$r->student_invoice_id);
        $allocations = $tenant(DB::table('payment_allocations'))
            ->select('institution_id','student_invoice_id')->selectRaw('SUM(amount) AS amount')
            ->groupBy('institution_id','student_invoice_id')->get()
            ->keyBy(fn($r) => $r->institution_id.':'.$r->student_invoice_id);
        $refunds = $tenant(DB::table('payment_refunds as r'),'r.institution_id')
            ->join('student_payments as p',function($j){$j->on('p.id','=','r.student_payment_id')
                ->on('p.institution_id','=','r.institution_id');})
            ->whereIn('r.status',['approved','processed'])
            ->select('r.institution_id','p.student_invoice_id')->selectRaw('SUM(r.amount) AS amount')
            ->groupBy('r.institution_id','p.student_invoice_id')->get()
            ->keyBy(fn($r) => $r->institution_id.':'.$r->student_invoice_id);
        $badLines=[]; $badPaid=[]; $badBounds=[];
        foreach($invoice as $inv) {
            $key=$inv->institution_id.':'.$inv->id;
            $amount=SmsMoney::cents((string)$inv->total_amount);
            $paid=SmsMoney::cents((string)$inv->paid_amount);
            $lines=SmsMoney::cents((string)($lineSums[$key]->amount??'0.00'));
            $allocated=SmsMoney::cents((string)($allocations[$key]->amount??'0.00'));
            $refunded=SmsMoney::cents((string)($refunds[$key]->amount??'0.00'));
            if($amount!==$lines) $badLines[]=$key;
            if($paid!==$allocated-$refunded) $badPaid[]=$key;
            if($paid<0||$amount<0||$paid>$amount||$refunded>$allocated) $badBounds[]=$key;
        }
        $check('INVOICE_LINE_TOTALS',$badLines?'FAIL':'PASS',count($badLines),$badLines);
        $check('INVOICE_ALLOCATIONS_MINUS_REFUNDS',$badPaid?'FAIL':'PASS',count($badPaid),$badPaid);
        $check('INVOICE_FINANCIAL_BOUNDS',$badBounds?'FAIL':'PASS',count($badBounds),$badBounds);
        $missingInvoiceJournals=[];
        foreach($invoice as $inv) {
            $posted=DB::table('ledger_journals')->where('institution_id',$inv->institution_id)
                ->where('status','posted')->where(fn($q)=>$q
                    ->where(fn($x)=>$x->where('source_type','fee_invoice')->where('source_reference',(string)$inv->id))
                    ->orWhere(fn($x)=>$x->where('source_type','invoice')->where('source_reference',$inv->invoice_no)))
                ->exists();
            if(!$posted)$missingInvoiceJournals[]=$inv->institution_id.':'.$inv->id;
        }
        $check('INVOICE_POSTED_JOURNAL_PRESENT',$missingInvoiceJournals?'FAIL':'PASS',count($missingInvoiceJournals),$missingInvoiceJournals);
        $payments=$tenant(DB::table('student_payments'))->where('status','posted')->get();
        $missingPaymentJournals=[];
        foreach($payments as $payment) {
            $posted=DB::table('ledger_journals')->where('institution_id',$payment->institution_id)
                ->where('status','posted')->where(fn($q)=>$q
                    ->where(fn($x)=>$x->where('source_type','fee_payment')->where('source_reference',(string)$payment->id))
                    ->orWhere(fn($x)=>$x->where('source_type','payment')->where('source_reference',$payment->reference_no)))
                ->exists();
            if(!$posted)$missingPaymentJournals[]=$payment->institution_id.':'.$payment->id;
        }
        $check('PAYMENT_POSTED_JOURNAL_PRESENT',$missingPaymentJournals?'FAIL':'PASS',count($missingPaymentJournals),$missingPaymentJournals);


        $journals = $tenant(DB::table('ledger_journals as j'),'j.institution_id')
            ->leftJoin('ledger_lines as l',function($join){$join->on('j.institution_id','=','l.institution_id')
                ->on('j.id','=','l.ledger_journal_id');})
            ->where('j.status','posted')->select('j.institution_id','j.id')
            ->selectRaw('COALESCE(SUM(l.debit),0) AS debits, COALESCE(SUM(l.credit),0) AS credits, COUNT(l.id) AS lines')
            ->groupBy('j.institution_id','j.id')->get();
        if($journals->isEmpty())$check('POSTED_JOURNALS_PRESENT','WARN',0);
        $badJournals=[];
        foreach($journals as $journal) {
            if ((int)$journal->lines < 2 ||
                SmsMoney::cents((string)$journal->debits)!==SmsMoney::cents((string)$journal->credits))
                $badJournals[]=$journal->institution_id.':'.$journal->id;
        }
        $check('POSTED_JOURNAL_BALANCE',$badJournals?'FAIL':'PASS',count($badJournals),$badJournals);

        $sourceDuplicates=$tenant(DB::table('ledger_journals'))
            ->whereNotNull('source_reference')->select('institution_id','source_type','source_reference')
            ->groupBy('institution_id','source_type','source_reference')
            ->havingRaw('COUNT(*) > 1')->get()->map(fn($r)=>$r->institution_id.':'.$r->source_type.':'.$r->source_reference)->all();
        $check('JOURNAL_SOURCE_DUPLICATES',$sourceDuplicates?'FAIL':'PASS',count($sourceDuplicates),$sourceDuplicates);

        $crossTenant = $tenant(DB::table('payment_allocations as a'),'a.institution_id')
            ->join('student_payments as p','p.id','=','a.student_payment_id')
            ->join('student_invoices as i','i.id','=','a.student_invoice_id')
            ->where(fn($q)=>$q->whereColumn('a.institution_id','<>','p.institution_id')
                ->orWhereColumn('a.institution_id','<>','i.institution_id')
                ->orWhereColumn('p.student_invoice_id','<>','i.id'))
            ->select('a.id')->pluck('a.id')->all();
        $check('PAYMENT_TENANT_AND_INVOICE_LINK',$crossTenant?'FAIL':'PASS',count($crossTenant),$crossTenant);

        $payrollSlips=$tenant(DB::table('payslips'))->get();
        $badPayroll=[];
        foreach($payrollSlips as $slip) {
            $items=DB::table('payslip_items')->where('institution_id',$slip->institution_id)
                ->where('payslip_id',$slip->id)->get()->all();
            try {
                $calculated=SmsPayrollMath::totals($items);
                if($calculated['gross']!==SmsMoney::cents((string)$slip->gross_amount)
                  ||$calculated['deductions']!==SmsMoney::cents((string)$slip->deduction_amount)
                  ||$calculated['net']!==SmsMoney::cents((string)$slip->net_amount))
                    $badPayroll[]=$slip->institution_id.':'.$slip->id;
            } catch(\Throwable $e) {
                $badPayroll[]=$slip->institution_id.':'.$slip->id;
            }
        }
        $check('PAYROLL_ITEM_RECONCILIATION',$badPayroll?'FAIL':'PASS',count($badPayroll),$badPayroll);
        $fail=count(array_filter($checks,fn($r)=>$r['status']==='FAIL'));
        $warn=count(array_filter($checks,fn($r)=>$r['status']==='WARN'));
        return ['status'=>$fail?'FAIL':($warn?'WARN':'PASS'),'institution_id'=>$institutionId,
            'totals'=>['invoices'=>$invoice->count(),'posted_journals'=>$journals->count(),'payslips'=>$payrollSlips->count(),
                'failed_checks'=>$fail,'warnings'=>$warn], 'checks'=>$checks];
    }
}
