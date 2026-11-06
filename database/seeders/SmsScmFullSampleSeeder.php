<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * Local/test ONLY. Seed real fixture rows into the provided single-school,
 * otherwise-empty scm-system database, remapping already-present IDs.
 * Existing user accounts, the school admin role and membership are retained.
 * Everything is wrapped in one transaction, including the rich extension.
 * Do NOT execute against operational or production data.
 */
final class SmsScmFullSampleSeeder extends Seeder
{
    private const ADMIN_EMAIL = 'admin.school@example.test';
    private const ADMIN_DEMO_PASSWORD = 'SchoolAdmin@2026';
    private array $institutionIds = [];
    private array $userIds = [];
    private array $roleIds = [];
    private array $membershipIds = [];
    private array $permissionIds = [];
    private int $inserted = 0;

    public function run(): void
    {
        if (!app()->environment(['local', 'testing']) ||
            !filter_var(env('SMS_ALLOW_SCM_FULL_SAMPLE', false), FILTER_VALIDATE_BOOLEAN) ||
            !filter_var(env('SMS_ALLOW_RICH_DEMO_SEED', false), FILTER_VALIDATE_BOOLEAN) ||
            !filter_var(env('SMS_ALLOW_DEMO_REPAIR', false), FILTER_VALIDATE_BOOLEAN)) {
            throw new RuntimeException('Refused: set APP_ENV=local and all 3 SMS_ALLOW_* flags listed in README on a dedicated demo DB.');
        }

        $file = database_path('seeders/data/sms_demo_fixtures.json');
        if (!is_file($file)) {
            throw new RuntimeException('Missing database/seeders/data/sms_demo_fixtures.json.');
        }
        $fixtures = json_decode((string) file_get_contents($file), true, 512, JSON_THROW_ON_ERROR);
        foreach (array_keys($fixtures) as $table) {
            if (!Schema::hasTable($table)) {
                throw new RuntimeException('Missing required table '.$table.'; run migrations before demo seeding.');
            }
        }

        $institutions = DB::table('institutions')->get();
        if ($institutions->count() !== 1 || $institutions->first()->code !== 'SCHDEMO' ||
            $institutions->first()->status !== 'active' || $institutions->first()->deleted_at !== null) {
            throw new RuntimeException('Expected exactly one active SCHDEMO demo institution. No changes made.');
        }
        $admin = DB::table('users')->where('email', self::ADMIN_EMAIL)->first();
        if (!$admin) {
            throw new RuntimeException('Current demo admin email not found; this patch will not replace an unknown user.');
        }
        if (!DB::table('institution_memberships')->where('user_id', $admin->id)
            ->where('institution_id', $institutions->first()->id)->where('status','active')->exists()) {
            throw new RuntimeException('School admin active membership is missing. Fix membership before seeding.');
        }
        // Strictly avoid inserting into a partially populated or live campus.
        // Every table with fixture business data must be empty, except known
        // authentication, membership and permission tables.
        $allowExisting = [
            'users','institutions','institution_memberships','institution_roles',
            'membership_roles','membership_campuses','sms_permissions','institution_role_permissions',
        ];
        foreach ($fixtures as $table => $rows) {
            if (!in_array($table, $allowExisting, true) && DB::table($table)->exists()) {
                throw new RuntimeException("Refused: {$table} already has data. Use an empty STAGING copy or a fresh demo DB.");
            }
        }

        // Importing the original SQL first, followed by this seeder, is also
        // forbidden: it would duplicate sample records.
        DB::transaction(function () use ($fixtures, $institutions, $admin): void {
            $this->institutionIds[1] = (int) $institutions->first()->id;
            $this->userIds[1] = (int) $admin->id;

            foreach ($fixtures['users'] as $row) {
                $old = (int) $row['id'];
                $existing = DB::table('users')->where('email', $row['email'])->first();
                if ($existing) {
                    $this->userIds[$old] = (int) $existing->id;
                    continue;
                }
                if ($old === 1) {
                    throw new RuntimeException('Demo administrator missing.');
                }
                $this->userIds[$old] = (int) DB::table('users')->insertGetId([
                    'name'=>$row['name'], 'email'=>$row['email'],
                    'email_verified_at'=>now(), 'password'=>Hash::make(Str::random(36)),
                    'created_at'=>now(), 'updated_at'=>now(),
                ]);
                $this->inserted++;
            }

            // IDs in the original fresh-install demo fixture are NOT the same
            // as IDs in your actual exported database (SCHDEMO was id=2).
            foreach ($fixtures['institutions'] as $row) {
                $old = (int) $row['id'];
                if ($row['code'] === 'SCHDEMO') continue;
                unset($row['id']);
                $this->institutionIds[$old] = (int) DB::table('institutions')->insertGetId($row);
                $this->inserted++;
            }

            // Permissions are global; look up by key, not numeric ID.
            foreach ($fixtures['sms_permissions'] as $row) {
                $old = (int) $row['id'];
                $existing = DB::table('sms_permissions')->where('key',$row['key'])->first();
                if (!$existing) {
                    unset($row['id']);
                    $this->permissionIds[$old] = (int) DB::table('sms_permissions')->insertGetId($row);
                    $this->inserted++;
                } else {
                    $this->permissionIds[$old] = (int) $existing->id;
                }
            }

            foreach ($fixtures as $table => $rows) {
                if (in_array($table, ['users','institutions','sms_permissions'], true)) continue;
                foreach ($rows as $row) {
                    if (array_key_exists('institution_id', $row)) {
                        $oldInstitution = (int) $row['institution_id'];
                        if (!isset($this->institutionIds[$oldInstitution])) {
                            throw new RuntimeException("Unknown tenant reference in {$table}.");
                        }
                        $row['institution_id'] = $this->institutionIds[$oldInstitution];
                    }
                    foreach (['user_id','sender_user_id','recipient_user_id',
                              'booked_by_user_id','approved_by_user_id','actor_user_id'] as $userKey) {
                        if (array_key_exists($userKey,$row) && $row[$userKey] !== null) {
                            $row[$userKey] = $this->userIds[(int) $row[$userKey]]
                                ?? throw new RuntimeException("Unmapped user ID in {$table}.");
                        }
                    }
                    if ($table === 'institution_roles') {
                        $old = (int) $row['id'];
                        $existing = DB::table($table)->where('institution_id',$row['institution_id'])
                            ->where('key',$row['key'])->first();
                        if ($existing) {
                            $this->roleIds[$old] = (int) $existing->id;
                        } else {
                            unset($row['id']);
                            $this->roleIds[$old] = (int) DB::table($table)->insertGetId($row);
                            $this->inserted++;
                        }
                        continue;
                    }
                    if ($table === 'institution_memberships') {
                        $old = (int) $row['id'];
                        $existing = DB::table($table)->where('institution_id',$row['institution_id'])
                            ->where('user_id',$row['user_id'])->first();
                        if ($existing) {
                            if ($existing->status !== 'active') {
                                throw new RuntimeException('Existing membership is not active; refusing to override.');
                            }
                            $this->membershipIds[$old] = (int) $existing->id;
                        } else {
                            unset($row['id']);
                            $this->membershipIds[$old] = (int) DB::table($table)->insertGetId($row);
                            $this->inserted++;
                        }
                        continue;
                    }
                    if (in_array($table, ['membership_roles','membership_campuses'], true)) {
                        $row['membership_id'] = $this->membershipIds[(int) $row['membership_id']]
                            ?? throw new RuntimeException("Unmapped membership in {$table}");
                        if (array_key_exists('role_id',$row)) {
                            $row['role_id'] = $this->roleIds[(int) $row['role_id']]
                                ?? throw new RuntimeException('Unmapped membership role');
                        }
                        $this->inserted += DB::table($table)->insertOrIgnore($row) ? 1 : 0;
                        continue;
                    }
                    if ($table === 'institution_role_permissions') {
                        $row['role_id'] = $this->roleIds[(int) $row['role_id']]
                            ?? throw new RuntimeException('Unmapped permission role');
                        $row['permission_id'] = $this->permissionIds[(int) $row['permission_id']]
                            ?? throw new RuntimeException('Unmapped permission');
                        // Existing school administrator permissions are preserved.
                        DB::table($table)->insertOrIgnore($row);
                        continue;
                    }
                    // All remaining fixture tables were proven empty above;
                    // preserve primary keys to maintain linked FK references.
                    DB::table($table)->insert($row);
                    $this->inserted++;
                }
            }

            // Correct known legacy fixture reference/status inconsistencies.
            $this->call(SmsDemoFinancialReferenceRepairSeeder::class);

            // Rich extension adds 72 students, linked invoices/payments,
            // exam/attendance, Hifz, library, transport, and many other rows.
            $this->call(SmsExtendedDemoSeeder::class);

            // Exactly as requested: fixed LOCAL-DEMO admin credentials.
            DB::table('users')->where('id', $admin->id)->update([
                'password'=>Hash::make(self::ADMIN_DEMO_PASSWORD),
                'email_verified_at'=>now(), 'updated_at'=>now(),
            ]);
            $currentHash = DB::table('users')->where('id',$admin->id)->value('password');
            if (!Hash::check(self::ADMIN_DEMO_PASSWORD, $currentHash)) {
                throw new RuntimeException('Administrator password hash verification failed.');
            }
            $this->verifyData();
        }, 1);

        $this->command?->info('SUCCESS: 3 fictitious demo institutions populated.');
        $this->command?->line('Login: admin.school@example.test | SchoolAdmin@2026 (LOCAL DEMO ONLY)');
        $this->command?->line('Students: '.DB::table('students')->count());
        $this->command?->line('Invoices: '.DB::table('student_invoices')->count());
        $this->command?->line('Attendance: '.DB::table('student_attendance')->count());
        $this->command?->warn('Set SMS_ALLOW_SCM_FULL_SAMPLE=false, SMS_ALLOW_RICH_DEMO_SEED=false, SMS_ALLOW_DEMO_REPAIR=false.');
    }

    private function verifyData(): void
    {
        if (DB::table('institutions')->count() !== 3 || DB::table('students')->count() < 75) {
            throw new RuntimeException('Sample-count verification failed. Transaction will roll back.');
        }
        $badJournals = DB::table('ledger_journals as j')
            ->leftJoin('ledger_lines as l', function ($join) {
                $join->on('j.id','=','l.ledger_journal_id')
                    ->on('j.institution_id','=','l.institution_id');
            })
            ->groupBy('j.id','j.institution_id')
            ->havingRaw('COUNT(l.id) < 2 OR ABS(COALESCE(SUM(l.debit),0) - COALESCE(SUM(l.credit),0)) > 0.009')
            ->count();
        if ($badJournals) throw new RuntimeException('Unbalanced or incomplete journal detected. Transaction rolled back.');
    }
}
