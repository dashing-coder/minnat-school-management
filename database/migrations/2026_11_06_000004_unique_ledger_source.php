<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        $duplicates=DB::table('ledger_journals')
            ->select('institution_id','source_type','source_reference')
            ->whereNotNull('source_reference')
            ->groupBy('institution_id','source_type','source_reference')
            ->havingRaw('COUNT(*) > 1')->limit(1)->exists();
        if ($duplicates) {
            throw new \RuntimeException('Duplicate ledger source references exist. Audit and reconcile manually before applying uniqueness.');
        }
        Schema::table('ledger_journals',function(Blueprint $table): void {
            $table->unique(['institution_id','source_type','source_reference'],'sms_ledger_source_unique');
        });
    }
    public function down(): void
    {
        Schema::table('ledger_journals',function(Blueprint $table): void {
            $table->dropUnique('sms_ledger_source_unique');
        });
    }
};
