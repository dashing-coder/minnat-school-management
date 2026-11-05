<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\Campus;
use App\Models\Institution;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Throwable;

final class SmsBootstrapInstitution extends Command
{
    protected $signature = 'sms:bootstrap-institution
        {code : Institution code (uppercase letters/digits/underscore/hyphen)}
        {slug : URL slug}
        {name : Full institution name}
        {adminEmail : Email address of an EXISTING verified Laravel user}
        {--type=school : school|college|madrasha|mixed}
        {--campus=Main Campus : Initial campus name}';

    protected $description = 'Provision a new institution, initial campus and limited institution administrator (server console only).';

    public function handle(): int
    {
        $code = (string) $this->argument('code');
        $slug = (string) $this->argument('slug');
        $name = trim((string) $this->argument('name'));
        $adminEmail = trim((string) $this->argument('adminEmail'));
        $type = (string) $this->option('type');
        $campusName = trim((string) $this->option('campus'));

        if (!preg_match('/^[A-Z0-9_-]{2,32}$/', $code)
            || !preg_match('/^[a-z0-9]+(?:-[a-z0-9]+)*$/', $slug)
            || strlen($slug) > 100
            || $name === '' || strlen($name) > 200
            || $campusName === '' || strlen($campusName) > 160
            || !in_array($type, ['school', 'college', 'madrasha', 'mixed'], true)) {
            $this->error('Invalid institution details. Check code/slug/length/type/campus name.');
            return self::FAILURE;
        }

        $admin = User::query()->where('email', $adminEmail)->first();
        if ($admin === null || $admin->email_verified_at === null) {
            $this->error('An existing, email-verified user is required. Create and verify the user first.');
            return self::FAILURE;
        }

        if (Institution::query()->withTrashed()->where('code', $code)->orWhere('slug', $slug)->exists()) {
            $this->error('Institution code or slug already exists.');
            return self::FAILURE;
        }

        $adminPermissions = [
            'dashboard.view', 'institutions.manage', 'campuses.view', 'campuses.manage',
            'memberships.view', 'memberships.manage', 'roles.manage', 'audit.view',
        ];
        $permissionIds = DB::table('sms_permissions')
            ->whereIn('key', $adminPermissions)->pluck('id', 'key');
        if ($permissionIds->count() !== count($adminPermissions)) {
            $this->error('Permission catalog is incomplete. Run SmsPermissionSeeder before bootstrapping.');
            return self::FAILURE;
        }

        $this->warn("Will create {$name} ({$type}) and grant limited institution administration to {$adminEmail}.");
        if (!$this->confirm('Proceed? Review the email owner carefully.', false)) {
            $this->info('Cancelled; no changes made.');
            return self::FAILURE;
        }

        try {
            DB::transaction(function () use ($code, $slug, $name, $type, $campusName, $admin, $permissionIds): void {
                $institution = Institution::query()->create([
                    'code' => $code, 'slug' => $slug, 'name' => $name,
                    'type' => $type, 'status' => 'active',
                ]);
                Campus::query()->create([
                    'institution_id' => $institution->id,
                    'code' => 'MAIN', 'name' => $campusName,
                    'is_main' => true, 'is_active' => true,
                ]);
                $membershipId = DB::table('institution_memberships')->insertGetId([
                    'institution_id' => $institution->id,
                    'user_id' => $admin->id,
                    'status' => 'active',
                    'can_access_all_campuses' => true,
                    'joined_at' => now(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                $roleId = DB::table('institution_roles')->insertGetId([
                    'institution_id' => $institution->id,
                    'key' => 'institution_admin',
                    'name' => 'Institution Administrator',
                    'is_system' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                foreach ($permissionIds as $permissionId) {
                    DB::table('institution_role_permissions')->insert([
                        'role_id' => $roleId,
                        'permission_id' => $permissionId,
                    ]);
                }
                DB::table('membership_roles')->insert([
                    'institution_id' => $institution->id,
                    'membership_id' => $membershipId,
                    'role_id' => $roleId,
                ]);
                DB::table('sms_audit_logs')->insert([
                    'institution_id' => $institution->id,
                    'actor_user_id' => null, // Console operator is not automatically the target user.
                    'action' => 'institution.bootstrap',
                    'resource_type' => 'institution',
                    'resource_id' => (string) $institution->id,
                    'metadata' => json_encode(['source' => 'server_console', 'initial_admin_user_id' => $admin->id], JSON_THROW_ON_ERROR),
                    'created_at' => now(),
                ]);
            });
        } catch (Throwable $e) {
            $this->error('Provisioning failed and the database transaction was rolled back. Check secured server logs.');
            report($e);
            return self::FAILURE;
        }

        $this->info('Institution and limited administrator provisioned successfully.');
        return self::SUCCESS;
    }
}
