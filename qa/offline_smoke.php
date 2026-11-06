<?php
/** Standalone smoke for pure helpers only; no Laravel, DB or HTTP execution. */
require __DIR__.'/../app/Support/SmsMoney.php';
require __DIR__.'/../app/Support/SmsPayrollMath.php';
require __DIR__.'/../app/Support/SmsBiometricCsv.php';
require __DIR__.'/../app/Support/SmsDemoGatewaySignature.php';
use App\Support\SmsPayrollMath;
use App\Support\SmsDemoGatewaySignature;
use App\Support\SmsBiometricCsv;
$result=SmsPayrollMath::totals([
    ['item_type'=>'earning','amount'=>'12000.00'],
    ['item_type'=>'earning','amount'=>'225.75'],
    ['item_type'=>'deduction','amount'=>'125.50','liability_account_id'=>4],
]);
if($result['gross']!==1222575||$result['deductions']!==12550||$result['net']!==1210025)throw new RuntimeException('Payroll amounts invalid');
$body='{"a":"b"}';$stamp='1794000000';$secret=str_repeat('m',64);
$sig=SmsDemoGatewaySignature::sign($stamp,$body,$secret);
if(!SmsDemoGatewaySignature::verify($stamp,$body,$sig,$secret,1794000000))throw new RuntimeException('Valid HMAC rejected');
if(SmsDemoGatewaySignature::verify($stamp,$body.'x',$sig,$secret,1794000000))throw new RuntimeException('Tampering accepted');
$row=['external_event_id'=>'dev-1','student_id'=>'20','attendance_session_id'=>'1','status'=>'present','occurred_at'=>'2026-11-06 08:00:00'];
if(SmsBiometricCsv::parse($row)['student_id']!==20)throw new RuntimeException('Valid biometric row rejected');
echo "PASS: payroll cents, demo HMAC authenticity and CSV validation. Laravel/MySQL/E2E NOT tested.\n";
