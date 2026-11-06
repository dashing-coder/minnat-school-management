<?php

namespace Tests\Unit;

use App\Support\SmsPayrollMath;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

final class SmsPayrollMathTest extends TestCase
{
    public function test_exact_gross_deduction_net_and_liability_accounts(): void
    {
        $result = SmsPayrollMath::totals([
            ['item_type'=>'earning','amount'=>'18000.00'],
            ['item_type'=>'earning','amount'=>'1200.25'],
            ['item_type'=>'deduction','amount'=>'150.10','liability_account_id'=>8],
            ['item_type'=>'deduction','amount'=>'49.90','liability_account_id'=>8],
            ['item_type'=>'deduction','amount'=>'100.00','liability_account_id'=>9],
        ]);
        self::assertSame(1920025,$result['gross']);
        self::assertSame(30000,$result['deductions']);
        self::assertSame(1890025,$result['net']);
        self::assertSame([8=>20000,9=>10000],$result['withholdings']);
    }
    public function test_missing_liability_account_is_rejected(): void
    {
        $this->expectException(InvalidArgumentException::class);
        SmsPayrollMath::totals([
            ['item_type'=>'earning','amount'=>'300.00'],
            ['item_type'=>'deduction','amount'=>'10.00']
        ]);
    }
    public function test_deductions_exceeding_gross_are_rejected(): void
    {
        $this->expectException(InvalidArgumentException::class);
        SmsPayrollMath::totals([
            ['item_type'=>'earning','amount'=>'300.00'],
            ['item_type'=>'deduction','amount'=>'301.00','liability_account_id'=>5]
        ]);
    }
}
