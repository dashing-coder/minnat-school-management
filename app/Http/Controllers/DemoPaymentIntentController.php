<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Support\SmsAccess;
use App\Support\SmsMoney;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/** Intents are local simulator records; they do not collect real payments. */
final class DemoPaymentIntentController
{
    public function store(Request $request)
    {
        abort_unless(app()->environment(['local','testing']) && config('sms_integrations.demo_provider_enabled'),404);
        SmsAccess::require('fees.collect');
        abort_unless((int)SmsAccess::membership()->can_access_all_campuses === 1,403);
        $d=$request->validate(['student_invoice_id'=>['required','integer','min:1'],
            'amount'=>['required','string','regex:/^\d{1,12}(\.\d{1,2})?$/']]);
        $intent=DB::transaction(function()use($d){
            $invoice=SmsAccess::scopedQuery('student_invoices')->where('id',(int)$d['student_invoice_id'])
                ->lockForUpdate()->first();
            if(!$invoice)throw ValidationException::withMessages(['student_invoice_id'=>'Invoice not found.']);
            $amount=SmsMoney::cents((string)$d['amount']);
            $due=SmsMoney::cents((string)$invoice->total_amount)-SmsMoney::cents((string)$invoice->paid_amount);
            if($amount<1||$amount>$due)throw ValidationException::withMessages(['amount'=>'Amount exceeds outstanding invoice balance.']);
            $existing=DB::table('payment_gateway_intents')->where('institution_id',SmsAccess::institutionId())
                ->where('student_invoice_id',$invoice->id)->whereIn('status',['pending','verified_pending_posting'])
                ->where('expires_at','>',now())->exists();
            if($existing)throw ValidationException::withMessages(['student_invoice_id'=>'An active simulation intent exists.']);
            $ref='DEMO-'.strtoupper(bin2hex(random_bytes(12)));
            DB::table('payment_gateway_intents')->insert([
                'institution_id'=>SmsAccess::institutionId(),'student_invoice_id'=>$invoice->id,
                'external_reference'=>$ref,'amount'=>SmsMoney::decimal($amount),
                'status'=>'pending','expires_at'=>now()->addMinutes(15),
                'created_at'=>now(),'updated_at'=>now()
            ]);
            return ['reference'=>$ref,'amount'=>SmsMoney::decimal($amount)];
        });
        return response()->json(['data'=>$intent,'simulated'=>true,
            'notice'=>'No money was collected. A verified webhook only flags manual reconciliation; it does not post invoices.'],201);
    }
}
