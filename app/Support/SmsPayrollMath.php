<?php

declare(strict_types=1);

namespace App\Support;

use InvalidArgumentException;

/** Pure, deterministic BDT/2-decimal payroll calculations. Does not calculate statutory tax. */
final class SmsPayrollMath
{
    /** @param iterable<array|object> $items */
    public static function totals(iterable $items): array
    {
        $gross = 0; $deduction = 0; $withheld = []; $earningCount = 0;
        foreach ($items as $raw) {
            $item = (array) $raw;
            $amount = SmsMoney::cents((string) ($item['amount'] ?? ''));
            if ($amount <= 0) throw new InvalidArgumentException('Payroll items must be positive.');
            $type = $item['item_type'] ?? '';
            if ($type === 'earning') { $gross += $amount; ++$earningCount; continue; }
            if ($type !== 'deduction') throw new InvalidArgumentException('Unknown payroll item type.');
            $accountId = (int) ($item['liability_account_id'] ?? 0);
            if ($accountId < 1) throw new InvalidArgumentException('Every deduction must reference its withholding liability account.');
            $withheld[$accountId] = ($withheld[$accountId] ?? 0) + $amount;
            $deduction += $amount;
        }
        if ($earningCount === 0 || $gross <= 0) throw new InvalidArgumentException('Payroll requires at least one earning.');
        if ($deduction >= $gross) throw new InvalidArgumentException('Deductions must be less than gross salary.');
        ksort($withheld, SORT_NUMERIC);
        return ['gross' => $gross, 'deductions' => $deduction, 'net' => $gross - $deduction, 'withholdings' => $withheld];
    }
}
