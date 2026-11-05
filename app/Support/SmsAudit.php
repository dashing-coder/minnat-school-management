<?php
namespace App\Support;

use Illuminate\Support\Facades\DB;

final class SmsAudit
{
    public static function record(string $action, string $table, int|string $id, array $details = []): void
    {
        DB::table('sms_audit_logs')->insert([
            'institution_id' => SmsAccess::institutionId(),
            'actor_user_id' => auth()->id(),
            'action' => $action,
            'resource_type' => $table,
            'resource_id' => (string) $id,
            'metadata' => $details ? json_encode($details, JSON_THROW_ON_ERROR) : null,
            'ip_address' => request()->ip(),
            'created_at' => now(),
        ]);
    }
}
