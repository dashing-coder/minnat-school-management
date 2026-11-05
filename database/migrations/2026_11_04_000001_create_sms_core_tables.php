<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Assumes the standard Laravel users table already exists.
        Schema::create('institutions', function (Blueprint $table): void {
            $table->id();
            $table->string('code', 32)->unique();
            $table->string('slug', 100)->unique();
            $table->string('name', 200);
            $table->enum('type', ['school', 'college', 'madrasha', 'mixed']);
            $table->enum('status', ['draft', 'active', 'suspended'])->default('draft');
            $table->string('timezone', 64)->default('Asia/Dhaka');
            $table->string('locale', 8)->default('bn');
            $table->char('currency', 3)->default('BDT');
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('campuses', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 32);
            $table->string('name', 160);
            $table->boolean('is_main')->default(false);
            $table->boolean('is_active')->default(true);
            $table->text('address')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'code']);
            $table->unique(['institution_id', 'id']); // Composite tenant FK target.
        });

        Schema::create('institution_memberships', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->enum('status', ['invited', 'active', 'suspended', 'revoked'])->default('invited');
            $table->boolean('can_access_all_campuses')->default(false);
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'user_id']);
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('membership_campuses', function (Blueprint $table): void {
            $table->unsignedBigInteger('institution_id');
            $table->unsignedBigInteger('membership_id');
            $table->unsignedBigInteger('campus_id');
            $table->timestamp('created_at')->useCurrent();
            $table->primary(['institution_id', 'membership_id', 'campus_id'], 'membership_campuses_pk');
            $table->foreign(['institution_id', 'membership_id'], 'mc_membership_fk')
                ->references(['institution_id', 'id'])->on('institution_memberships')->cascadeOnDelete();
            $table->foreign(['institution_id', 'campus_id'], 'mc_campus_fk')
                ->references(['institution_id', 'id'])->on('campuses')->cascadeOnDelete();
        });

        Schema::create('institution_roles', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('key', 80);
            $table->string('name', 120);
            $table->boolean('is_system')->default(false);
            $table->timestamps();
            $table->unique(['institution_id', 'key']);
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('sms_permissions', function (Blueprint $table): void {
            $table->id();
            $table->string('key', 120)->unique();
            $table->string('module', 80);
            $table->string('label', 160);
            $table->timestamps();
        });

        Schema::create('institution_role_permissions', function (Blueprint $table): void {
            $table->foreignId('role_id')->constrained('institution_roles')->cascadeOnDelete();
            $table->foreignId('permission_id')->constrained('sms_permissions')->cascadeOnDelete();
            $table->primary(['role_id', 'permission_id'], 'ir_permission_pk');
        });

        Schema::create('membership_roles', function (Blueprint $table): void {
            $table->unsignedBigInteger('institution_id');
            $table->unsignedBigInteger('membership_id');
            $table->unsignedBigInteger('role_id');
            $table->timestamp('created_at')->useCurrent();
            $table->primary(['institution_id', 'membership_id', 'role_id'], 'membership_roles_pk');
            $table->foreign(['institution_id', 'membership_id'], 'mr_membership_fk')
                ->references(['institution_id', 'id'])->on('institution_memberships')->cascadeOnDelete();
            $table->foreign(['institution_id', 'role_id'], 'mr_role_fk')
                ->references(['institution_id', 'id'])->on('institution_roles')->cascadeOnDelete();
        });

        Schema::create('platform_admin_users', function (Blueprint $table): void {
            $table->foreignId('user_id')->primary()->constrained('users')->cascadeOnDelete();
            $table->foreignId('granted_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('created_at')->useCurrent();
        });

        Schema::create('institution_module_settings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('module_key', 80);
            $table->boolean('enabled')->default(false);
            $table->json('options')->nullable();
            $table->timestamps();
            $table->unique(['institution_id', 'module_key']);
        });

        Schema::create('academic_sessions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('code', 32);
            $table->string('name', 100);
            $table->date('starts_on');
            $table->date('ends_on');
            $table->enum('status', ['planned', 'active', 'closed'])->default('planned');
            $table->timestamps();
            $table->unique(['institution_id', 'code']);
            $table->unique(['institution_id', 'id']);
        });

        Schema::create('sms_audit_logs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->nullable()->constrained('institutions')->restrictOnDelete();
            $table->foreignId('actor_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('action', 100);
            $table->string('resource_type', 120);
            $table->string('resource_id', 80)->nullable();
            $table->json('before_data')->nullable();
            $table->json('after_data')->nullable();
            $table->json('metadata')->nullable();
            $table->ipAddress('ip_address')->nullable();
            $table->string('request_id', 40)->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->index(['institution_id', 'created_at']);
            $table->index(['resource_type', 'resource_id']);
        });

        Schema::create('sms_idempotency_records', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('operation', 60);
            $table->string('idempotency_key', 160);
            $table->char('request_sha256', 64);
            $table->enum('status', ['processing', 'completed', 'failed'])->default('processing');
            $table->unsignedSmallInteger('response_status')->nullable();
            $table->json('response_body')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();
            $table->unique(['institution_id', 'operation', 'idempotency_key'], 'sms_idempotency_unique');
            $table->index(['status', 'expires_at']);
        });

        Schema::create('sms_outbox_events', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('institution_id')->constrained('institutions')->restrictOnDelete();
            $table->string('event_type', 120);
            $table->string('aggregate_type', 100);
            $table->string('aggregate_id', 80);
            $table->json('payload');
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->unsignedSmallInteger('attempts')->default(0);
            $table->timestamp('available_at')->useCurrent();
            $table->timestamp('processed_at')->nullable();
            $table->timestamps();
            $table->index(['status', 'available_at']);
            $table->index(['institution_id', 'aggregate_type', 'aggregate_id'], 'sms_outbox_aggregate_idx');
        });
    }

    public function down(): void
    {
        // Reverse in dependency-safe order. No automatic destructive operation in production.
        Schema::dropIfExists('sms_outbox_events');
        Schema::dropIfExists('sms_idempotency_records');
        Schema::dropIfExists('sms_audit_logs');
        Schema::dropIfExists('academic_sessions');
        Schema::dropIfExists('institution_module_settings');
        Schema::dropIfExists('platform_admin_users');
        Schema::dropIfExists('membership_roles');
        Schema::dropIfExists('institution_role_permissions');
        Schema::dropIfExists('sms_permissions');
        Schema::dropIfExists('institution_roles');
        Schema::dropIfExists('membership_campuses');
        Schema::dropIfExists('institution_memberships');
        Schema::dropIfExists('campuses');
        Schema::dropIfExists('institutions');
    }
};
