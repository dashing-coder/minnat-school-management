<?php

declare(strict_types=1);

namespace App\Support;

use Illuminate\Support\Facades\DB;

/** Read-only gate; only the authorized operator can perform a real deployment. */
final class SmsReleaseGate
{
    public static function run(bool $production = false): array
    {
        $checks=[];
        $add=static function(string $key,bool $ok,string $detail)use(&$checks){
            $checks[]=['check'=>$key,'status'=>$ok?'PASS':'BLOCK','detail'=>$detail];
        };
        $add('APPLICATION_KEY',is_string(config('app.key'))&&strlen(config('app.key'))>=32,'APP_KEY configured');
        $add('DEBUG_OFF',config('app.debug')===false,'APP_DEBUG must be false');
        $add('HTTPS_URL',str_starts_with((string)config('app.url'),'https://'),'APP_URL must be HTTPS');
        $add('DEMO_GATEWAY_DISABLED',!config('sms_integrations.demo_provider_enabled'),'Disable local demo payment simulator');
        $add('QUEUE_NON_SYNC',config('queue.default')!=='sync','Use monitored background queue workers');
        $add('APP_ENV_PRODUCTION',app()->environment('production'),'APP_ENV=production');
        $okDb=true;try{DB::connection()->getPdo();}catch(\Throwable){$okDb=false;}
        $add('DATABASE_CONNECTION',$okDb,'Configured database reachable');
        $evidence=storage_path('app/private/release-approval.json');
        $data=is_file($evidence)?json_decode((string)file_get_contents($evidence),true):null;
        $evidenceKeys=['pilot_accepted','backup_restore_verified','finance_reconciled','tenant_tests_passed','integration_tests_passed'];
        foreach($evidenceKeys as $key)
            $add('APPROVAL_'.strtoupper($key),is_array($data)&&($data[$key]??null)===true,
                'Requires recorded, independently reviewed evidence in storage/app/private/release-approval.json');
        $add('SIGNOFF_IDENTITY',is_array($data)&&trim((string)($data['approved_by']??''))!=='' && trim((string)($data['approved_at']??''))!=='',
            'Named approval and timestamp required');
        $fail=count(array_filter($checks,fn($c)=>$c['status']==='BLOCK'));
        return ['release'=>$production?'PRODUCTION_PREFLIGHT':'READ_ONLY_PREFLIGHT','ready'=>$fail===0,
            'blockers'=>$fail,'checks'=>$checks,
            'warning'=>'Evidence flags are operator assertions, NOT independent proof. No deployment, migrations, backup, or network calls were executed.'];
    }
}
