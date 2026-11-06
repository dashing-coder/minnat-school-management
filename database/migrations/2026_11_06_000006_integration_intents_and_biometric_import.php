<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('payment_gateway_intents',function(Blueprint $t): void {
            $t->id();$t->foreignId('institution_id')->constrained();
            $t->unsignedBigInteger('student_invoice_id');
            $t->string('external_reference',80)->unique();
            $t->decimal('amount',14,2);$t->string('status',32)->default('pending');
            $t->timestamp('expires_at');$t->timestamps();
            $t->foreign(['institution_id','student_invoice_id'],'pgi_invoice_tenant_fk')
                ->references(['institution_id','id'])->on('student_invoices');
            $t->unique(['institution_id','id']);
        });
        Schema::create('payment_gateway_events',function(Blueprint $t): void {
            $t->id();$t->foreignId('institution_id')->constrained();
            $t->foreignId('payment_gateway_intent_id')->constrained('payment_gateway_intents');
            $t->string('provider',30);$t->string('event_id',90);
            $t->string('payload_sha256',64);$t->string('event_status',32);
            $t->timestamps();$t->unique(['provider','event_id']);
        });
        Schema::create('biometric_devices',function(Blueprint $t): void {
            $t->id();$t->foreignId('institution_id')->constrained();
            $t->unsignedBigInteger('campus_id');$t->string('device_code',80);
            $t->string('name',140);$t->boolean('is_active')->default(false);$t->timestamps();
            $t->foreign(['institution_id','campus_id'],'bio_device_campus_tenant_fk')
                ->references(['institution_id','id'])->on('campuses');
            $t->unique(['institution_id','device_code']);
        });
        Schema::create('biometric_import_events',function(Blueprint $t): void {
            $t->id();$t->foreignId('institution_id')->constrained();
            $t->foreignId('biometric_device_id')->constrained();
            $t->string('external_event_id',100);$t->unsignedBigInteger('student_id');
            $t->unsignedBigInteger('attendance_session_id');$t->string('result',30);
            $t->timestamp('occurred_at');$t->timestamps();
            $t->unique(['biometric_device_id','external_event_id'],'bio_event_unique');
            $t->foreign(['institution_id','student_id'],'bio_student_tenant_fk')
                ->references(['institution_id','id'])->on('students');
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('biometric_import_events');
        Schema::dropIfExists('biometric_devices');
        Schema::dropIfExists('payment_gateway_events');
        Schema::dropIfExists('payment_gateway_intents');
    }
};
