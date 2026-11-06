<?php

declare(strict_types=1);

namespace App\Support;

use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/** File-based, local pilot importer. Never overwrites teacher-marked attendance. */
final class SmsBiometricImport
{
    public static function run(int $institutionId,string $deviceCode,string $csvPath,bool $commit): array
    {
        if(!app()->environment(['local','testing'])) throw new InvalidArgumentException('File import is local/testing only.');
        $base=storage_path('app/private/biometric-imports');
        $resolved=realpath($csvPath);$baseReal=realpath($base);
        if(!$resolved||!$baseReal||!str_starts_with($resolved,$baseReal.DIRECTORY_SEPARATOR)
            ||!is_file($resolved)||strtolower(pathinfo($resolved,PATHINFO_EXTENSION))!=='csv'
            ||filesize($resolved)>2_000_000)
            throw new InvalidArgumentException('Place an under-2MB CSV inside storage/app/private/biometric-imports.');
        $device=DB::table('biometric_devices')->where('institution_id',$institutionId)
            ->where('device_code',$deviceCode)->where('is_active',1)->first();
        if(!$device) throw new InvalidArgumentException('No authorized active demo device for institution.');
        $handle=fopen($resolved,'rb');if(!$handle)throw new InvalidArgumentException('CSV not readable.');
        try{
            $headers=fgetcsv($handle);
            if($headers!==SmsBiometricCsv::HEADERS)throw new InvalidArgumentException('Unexpected CSV header.');
            $rows=[];$line=1;$seen=[];
            while(($raw=fgetcsv($handle))!==false){
                ++$line;
                if($line>5001)throw new InvalidArgumentException('Maximum 5,000 rows per import.');
                if(count($raw)!==5)throw new InvalidArgumentException('Invalid column count at line '.$line);
                $parsed=SmsBiometricCsv::parse(array_combine($headers,$raw));
                if(isset($seen[$parsed['external_event_id']]))throw new InvalidArgumentException('Repeated event ID at line '.$line);
                $seen[$parsed['external_event_id']]=true;$rows[]=$parsed;
            }
        }finally{fclose($handle);}
        // Validate the *entire* file before committing any event.
        $checked=[]; $already=0;
        foreach($rows as $row){
            $s=DB::table('students')->where('institution_id',$institutionId)
                ->where('id',$row['student_id'])->where('campus_id',$device->campus_id)->first();
            $session=DB::table('attendance_sessions as a')->join('class_sections as c',function($j){
                $j->on('c.id','=','a.class_section_id')->on('c.institution_id','=','a.institution_id');
            })->where('a.institution_id',$institutionId)->where('a.id',$row['attendance_session_id'])
                ->where('c.campus_id',$device->campus_id)->select('a.*')->first();
            if(!$s||!$session||$session->status!=='open'
                ||substr($row['occurred_at'],0,10)!==$session->attendance_on)
                throw new InvalidArgumentException('Student/session/campus/date mismatch for event '.$row['external_event_id']);
            $enrolled=DB::table('enrollments')->where('institution_id',$institutionId)
                ->where('student_id',$s->id)->where('class_section_id',$session->class_section_id)
                ->where('status','active')->exists();
            if(!$enrolled)throw new InvalidArgumentException('Student is not actively enrolled for event '.$row['external_event_id']);
            $exists=DB::table('biometric_import_events')->where('biometric_device_id',$device->id)
                ->where('external_event_id',$row['external_event_id'])->exists();
            $present=DB::table('student_attendance')->where('institution_id',$institutionId)
                ->where('attendance_session_id',$session->id)->where('student_id',$s->id)->exists();
            if($exists||$present){++$already;continue;}
            $checked[]=$row;
        }
        if(!$commit)return ['mode'=>'DRY_RUN','records'=>count($rows),'ready'=>count($checked),'duplicates_or_existing'=>$already];
        DB::transaction(function()use($checked,$institutionId,$device){
            DB::table('institutions')->where('id',$institutionId)->lockForUpdate()->first();
            foreach($checked as $row){
                // No updates to existing manual entries, even under import races.
                $existing=DB::table('student_attendance')->where('institution_id',$institutionId)
                    ->where('attendance_session_id',$row['attendance_session_id'])->where('student_id',$row['student_id'])->exists();
                if($existing)throw new InvalidArgumentException('Attendance changed during preview. Retry import.');
                DB::table('student_attendance')->insert([
                    'institution_id'=>$institutionId,'attendance_session_id'=>$row['attendance_session_id'],
                    'student_id'=>$row['student_id'],'status'=>$row['status'],'minutes_late'=>0,
                    'created_at'=>now(),'updated_at'=>now(),
                ]);
                DB::table('biometric_import_events')->insert([
                    'institution_id'=>$institutionId,'biometric_device_id'=>$device->id,
                    'external_event_id'=>$row['external_event_id'],'student_id'=>$row['student_id'],
                    'attendance_session_id'=>$row['attendance_session_id'],'result'=>'imported',
                    'occurred_at'=>$row['occurred_at'],'created_at'=>now(),'updated_at'=>now(),
                ]);
            }
        },3);
        return ['mode'=>'COMMITTED','records'=>count($rows),'inserted'=>count($checked),'duplicates_or_existing'=>$already];
    }
}
