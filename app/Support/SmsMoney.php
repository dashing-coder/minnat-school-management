<?php
namespace App\Support;

use InvalidArgumentException;

/** Avoid IEEE-754 rounding in institutional money calculations. */
final class SmsMoney
{
    public static function cents(string|int|float $amount): int
    {
        $s=trim((string)$amount);
        if (!preg_match('/^\d{1,12}(?:\.\d{1,2})?$/D',$s)) throw new InvalidArgumentException('Invalid money amount.');
        [$whole,$fraction]=array_pad(explode('.',$s,2),2,'');
        $n=((int)$whole)*100+(int)str_pad($fraction,2,'0');
        if ($n<0) throw new InvalidArgumentException('Invalid money amount.');
        return $n;
    }
    public static function decimal(int $cents): string
    {
        $negative=$cents<0?'-':''; $cents=abs($cents);
        return $negative.intdiv($cents,100).'.'.str_pad((string)($cents%100),2,'0',STR_PAD_LEFT);
    }
}
