<?php

namespace Tests\Unit;

use App\Support\SmsDemoGatewaySignature;
use PHPUnit\Framework\TestCase;

final class SmsDemoGatewaySignatureTest extends TestCase
{
    public function test_valid_signature_only_within_five_minutes(): void
    {
        $secret=str_repeat('A',64);
        $body='{"event_id":"event-1","status":"paid"}';
        $timestamp='1794020000';
        $sig=SmsDemoGatewaySignature::sign($timestamp,$body,$secret);
        self::assertTrue(SmsDemoGatewaySignature::verify($timestamp,$body,$sig,$secret,1794020000));
        self::assertFalse(SmsDemoGatewaySignature::verify($timestamp,$body,$sig,$secret,1794020400));
        self::assertFalse(SmsDemoGatewaySignature::verify($timestamp,$body.'x',$sig,$secret,1794020000));
        self::assertFalse(SmsDemoGatewaySignature::verify($timestamp,$body,$sig,'short',1794020000));
    }
}
