<?php

declare(strict_types=1);

namespace App\Support;

/** A demo-only signed webhook format. NOT a real bKash, Nagad or Rocket signature scheme. */
final class SmsDemoGatewaySignature
{
    public static function sign(string $timestamp,string $rawBody,string $secret): string
    {
        return hash_hmac('sha256',$timestamp.'.'.$rawBody,$secret);
    }
    public static function verify(string $timestamp,string $rawBody,string $signature,string $secret,int $now): bool
    {
        if($secret===''||strlen($secret)<32||!ctype_digit($timestamp)||strlen($timestamp)>11
          ||abs($now-(int)$timestamp)>300||!preg_match('/^[a-f0-9]{64}$/Di',$signature)) return false;
        return hash_equals(self::sign($timestamp,$rawBody,$secret),strtolower($signature));
    }
}
