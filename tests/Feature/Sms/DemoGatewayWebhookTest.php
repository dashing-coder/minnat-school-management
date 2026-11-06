<?php

namespace Tests\Feature\Sms;

use App\Support\SmsDemoGatewaySignature;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class DemoGatewayWebhookTest extends TestCase
{
    use RefreshDatabase;

    public function test_signed_webhook_is_idempotent_and_never_posts_money(): void
    {
        config()->set('sms_integrations.demo_provider_enabled',true);
        config()->set('sms_integrations.demo_webhook_secret',str_repeat('z',64));
        $institution=DB::table('institutions')->insertGetId([
            'code'=>'DEMO','slug'=>'demo','name'=>'Demo','type'=>'school','status'=>'active'
        ]);
        $campus=DB::table('campuses')->insertGetId([
            'institution_id'=>$institution,'code'=>'A','name'=>'A'
        ]);
        $student=DB::table('students')->insertGetId([
            'institution_id'=>$institution,'campus_id'=>$campus,'admission_no'=>'1','name'=>'Test Student'
        ]);
        $invoice=DB::table('student_invoices')->insertGetId([
            'institution_id'=>$institution,'student_id'=>$student,'invoice_no'=>'TEST-1',
            'issued_on'=>'2026-11-06','due_on'=>'2026-11-30','total_amount'=>'200.00','paid_amount'=>'0.00','status'=>'unpaid'
        ]);
        $reference='DEMO-TEST-INTENT';
        $intent=DB::table('payment_gateway_intents')->insertGetId([
            'institution_id'=>$institution,'student_invoice_id'=>$invoice,
            'external_reference'=>$reference,'amount'=>'100.00','status'=>'pending',
            'expires_at'=>now()->addMinutes(15)
        ]);
        $raw=json_encode(['event_id'=>'evt-test-01','reference'=>$reference,'amount'=>'100.00','status'=>'paid']);
        $stamp=(string)time();
        $sig=SmsDemoGatewaySignature::sign($stamp,$raw,str_repeat('z',64));
        foreach([false,true] as $duplicate){
            $this->call('POST','/api/webhooks/demo-payments',[],[],[],[
                'HTTP_X_SMS_TIMESTAMP'=>$stamp,'HTTP_X_SMS_SIGNATURE'=>$sig,
                'CONTENT_TYPE'=>'application/json'
            ],$raw)->assertOk()->assertJsonPath('duplicate',$duplicate);
        }
        self::assertSame(1,DB::table('payment_gateway_events')->count());
        self::assertSame('verified_pending_posting',DB::table('payment_gateway_intents')->where('id',$intent)->value('status'));
        self::assertSame('0.00',number_format((float)DB::table('student_invoices')->where('id',$invoice)->value('paid_amount'),2,'.',''));
        self::assertSame(0,DB::table('ledger_journals')->count());
    }

    public function test_unsigned_webhook_is_rejected(): void
    {
        config()->set('sms_integrations.demo_provider_enabled',true);
        config()->set('sms_integrations.demo_webhook_secret',str_repeat('z',64));
        $this->postJson('/api/webhooks/demo-payments',['status'=>'paid'])->assertUnauthorized();
    }
}
