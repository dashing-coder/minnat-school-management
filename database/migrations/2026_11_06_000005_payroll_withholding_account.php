<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('payslip_items', function (Blueprint $table): void {
            $table->unsignedBigInteger('liability_account_id')->nullable()->after('item_type');
            $table->index(['institution_id', 'liability_account_id'], 'payslip_items_liability_lookup');
            $table->foreign(['institution_id', 'liability_account_id'], 'payslip_items_tenant_liability_fk')
                ->references(['institution_id', 'id'])->on('chart_of_accounts');
        });
    }
    public function down(): void
    {
        Schema::table('payslip_items', function (Blueprint $table): void {
            $table->dropForeign('payslip_items_tenant_liability_fk');
            $table->dropIndex('payslip_items_liability_lookup');
            $table->dropColumn('liability_account_id');
        });
    }
};
