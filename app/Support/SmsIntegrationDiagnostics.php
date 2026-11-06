<?php
namespace App\Support;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/** Read-only integration health inventory. NEVER outputs provider credentials. */
final class SmsIntegrationDiagnostics
{
    public static function run(): array
    {
        $checks=[];
        $add=static function(string $id,string $status,string $message)use(&$checks): void {
            $checks[]=['id'=>$id,'status'=>$status,'message'=>$message];
        };
        try {
            DB::connection()->getPdo();
        } catch (\Throwable $e) {
            $add('DATABASE','FAIL','Cannot inspect integrations without a working configured database/driver.');
            return $checks;
        }
        foreach(['integration_connections','integration_logs','notification_deliveries','sms_outbox_events'] as $table) {
            $add('TABLE_'.strtoupper($table),Schema::hasTable($table)?'PASS':'FAIL',
                Schema::hasTable($table)?'Table present':'Table missing');
        }
        if (Schema::hasTable('integration_connections')) {
            $rows=DB::table('integration_connections')->select('institution_id','category','provider','status')->get();
            $add('CONNECTIONS','INFO',$rows->count().' provider configurations (only names and status shown)');
            foreach($rows as $row) $add('PROVIDER_'.$row->institution_id.'_'.preg_replace('/[^A-Z0-9_]/i','_',($row->provider)),
                $row->status==='active'?'WARN':'INFO',
                'Institution #'.$row->institution_id.' / '.$row->category.' / '.$row->provider.' / '.$row->status.
                '; provider credentials and actual delivery NOT verified');
        }
        if (Schema::hasTable('notification_deliveries')) {
            $counts=DB::table('notification_deliveries')->selectRaw('status, COUNT(*) AS count')->groupBy('status')->pluck('count','status')->all();
            $add('DELIVERIES','INFO','Notification delivery statuses: '.json_encode($counts));
        }
        if (Schema::hasTable('sms_outbox_events')) {
            $pending=DB::table('sms_outbox_events')->whereIn('status',['pending','failed'])->count();
            $add('OUTBOX',$pending?'WARN':'PASS',$pending.' pending/failed outbox events');
        }
        $add('EXTERNAL_VERIFICATION','WARN','No SMS/WhatsApp/payment/biometric live delivery or callback tests performed here.');
        return $checks;
    }
}
