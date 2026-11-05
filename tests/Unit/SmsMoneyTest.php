<?php
namespace Tests\Unit;
use App\Support\SmsMoney;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

final class SmsMoneyTest extends TestCase
{
    public function test_decimal_conversion_is_exact(): void
    {
        self::assertSame(12340,SmsMoney::cents('123.40'));
        self::assertSame(1,SmsMoney::cents('0.01'));
        self::assertSame('123.40',SmsMoney::decimal(12340));
        self::assertSame('-1.01',SmsMoney::decimal(-101));
    }
    public function test_unsafe_precision_is_rejected(): void
    {
        $this->expectException(InvalidArgumentException::class);
        SmsMoney::cents('12.345');
    }
    public function test_scientific_notation_is_rejected(): void
    {
        $this->expectException(InvalidArgumentException::class);
        SmsMoney::cents('1e6');
    }
}
