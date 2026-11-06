<?php

namespace Tests\Unit;

use App\Support\SmsBiometricCsv;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

final class SmsBiometricCsvTest extends TestCase
{
    public function test_accepts_valid_local_event(): void
    {
        $row=['external_event_id'=>'A_1','student_id'=>'2','attendance_session_id'=>'7',
              'status'=>'present','occurred_at'=>'2026-11-06 08:07:00'];
        self::assertSame(2,SmsBiometricCsv::parse($row)['student_id']);
    }
    public function test_rejects_untrusted_absent_marks(): void
    {
        $this->expectException(InvalidArgumentException::class);
        SmsBiometricCsv::parse(['external_event_id'=>'A_1','student_id'=>'2','attendance_session_id'=>'7',
              'status'=>'absent','occurred_at'=>'2026-11-06 08:07:00']);
    }
}
