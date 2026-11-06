<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Support\SmsDemoGatewaySignature;
use App\Support\SmsMoney;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Never treats a provider notice as proof of settlement or posts real money. */
final class DemoPaymentWebhookController
{
    public function receive(Request $request)
    {
        abort_unless(app()->environment(['local','testing']) && config('sms_integrations.demo_provider_enabled'),404);
        $raw=$request->getContent();
        abort_if(strlen($raw)>8192,413);
        $secret=(string)config('sms_integrations.demo_webhook_secret');
        abort_unless(SmsDemoGatewaySignature::verify(
            (string)$request->header('X-SMS-Timestamp',''),$raw,
            (string)$request->header('X-SMS-Signature',''),$secret,time()),401);
        $payload=json_decode($raw,true);
        abort_unless(is_array($payload),400);
        $v=\Illuminate\Support\Facades\Validator::make($payload,[
            'event_id'=>['required','string','max:90','regex:/^[a-zA-Z0-9_-]+$/'],
            'reference'=>['required','string','max:80'],
            'amount'=>['required','regex:/^\\d{1,12}(\\.\\d{1,2})?$/'],
            'status'=>['required','in:paid,failed']
        ]);
        if($v->fails())return response()->json(['error'=>'Invalid payload'],422);
        $out=DB::transaction(function()use($payload,$raw) {
            $existing=DB::table('payment_gateway_events')->where('provider','demo')
                ->where('event_id',$payload['event_id'])->lockForUpdate()->first();
            if($existing)return ['duplicate'=>true,'status'=>$existing->event_status];
            $intent=DB::table('payment_gateway_intents')->where('external_reference',$payload['reference'])
                ->lockForUpdate()->first();
            if(!$intent || $intent->status!=='pending' || strtotime((string)$intent->expires_at)<time()
               ||SmsMoney::cents((string)$intent->amount)!==SmsMoney::cents((string)$payload['amount'])) {
                // Do not echo details about invoice or institution existence to callers.
                return ['invalid'=>true];
            }
            $status=$payload['status']==='paid'?'verified_pending_posting':'rejected';
            DB::table('payment_gateway_intents')->where('id',$intent->id)
                ->update(['status'=>$status,'updated_at'=>now()]);
            DB::table('payment_gateway_events')->insert([
                'institution_id'=>$intent->institution_id,'payment_gateway_intent_id'=>$intent->id,
                'provider'=>'demo','event_id'=>$payload['event_id'],
                'payload_sha256'=>hash('sha256',$raw),'event_status'=>$status,
                'created_at'=>now(),'updated_at'=>now()
            ]);
            return ['duplicate'=>false,'status'=>$status];
        },3);
        if(!empty($out['invalid']))return response()->json(['error'=>'Unrecognized or expired intent'],422);
        return response()->json($out);
    }
}
