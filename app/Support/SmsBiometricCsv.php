<?php

declare(strict_types=1);

namespace App\Support;

use DateTimeImmutable;
use InvalidArgumentException;

/** Accept only named students and existing attendance sessions. No raw biometric data. */
final class SmsBiometricCsv
{
    public const HEADERS = ['external_event_id','student_id','attendance_session_id','status','occurred_at'];

    public static function parse(array $row): array
    {
        if(array_keys($row)!==self::HEADERS) throw new InvalidArgumentException('CSV column header mismatch.');
        $event=(string)$row['external_event_id'];
        if(!preg_match('/^[A-Za-z0-9_-]{1,100}$/D',$event)) throw new InvalidArgumentException('Invalid event ID.');
        foreach(['student_id','attendance_session_id'] as $key)
            if(!ctype_digit((string)$row[$key])||(int)$row[$key]<1)
                throw new InvalidArgumentException('Invalid '.$key.'.');
        if(!in_array($row['status'],['present','late'],true))
            throw new InvalidArgumentException('Hardware may only import present/late events.');
        $when=DateTimeImmutable::createFromFormat('!Y-m-d H:i:s',(string)$row['occurred_at']);
        if(!$when||$when->format('Y-m-d H:i:s')!==$row['occurred_at'])
            throw new InvalidArgumentException('occurred_at must be YYYY-MM-DD HH:MM:SS in institution local time.');
        return ['external_event_id'=>$event,'student_id'=>(int)$row['student_id'],
            'attendance_session_id'=>(int)$row['attendance_session_id'],
            'status'=>$row['status'],'occurred_at'=>$row['occurred_at']];
    }
}
