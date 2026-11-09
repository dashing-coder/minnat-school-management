<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * Fictional local test dataset. NEVER use this seeder with real institutions.
 * Seed an empty DB only. MySQL full demo SQL is an alternative, not an additional step.
 */
final class SmsFullDemoSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment(['local', 'testing'])) {
            throw new RuntimeException('Demo seeding is forbidden outside local/testing environments.');
        }
        if (! filter_var(env('SMS_ALLOW_DEMO_SEED', false), FILTER_VALIDATE_BOOLEAN)) {
            throw new RuntimeException('Set SMS_ALLOW_DEMO_SEED=true in your LOCAL .env to opt in.');
        }
        if (DB::table('users')->exists() || DB::table('institutions')->exists()) {
            throw new RuntimeException('Use a fresh empty test database for demo seeding.');
        }

        $file = database_path('seeders/data/sms_demo_fixtures.json');
        if (! is_file($file)) {
            throw new RuntimeException('Demo fixtures file is missing.');
        }
        $data = json_decode((string) file_get_contents($file), true, 512, JSON_THROW_ON_ERROR);
        $passwords = [];

        DB::transaction(function () use ($data, &$passwords): void {
            foreach ($data as $table => $rows) {
                if ($table === 'users') {
                    foreach ($rows as &$user) {
                        $password = $user['email'] === 'admin.school@example.test'
                            ? 'SchoolAdmin@2026' : Str::random(28);
                        $passwords[$user['email']] = $password;
                        $user['password'] = Hash::make($password);
                    }
                    unset($user);
                }
                foreach (array_chunk($rows, 100) as $batch) {
                    DB::table($table)->insert($batch);
                }
            }
        }, 3);

        // Local demo-only credentials; never use the fixed school admin password in production.
        // CI/testing logs can be shared with contributors: never print credentials there.
        if (! app()->environment('testing')) {
            $this->command?->warn('DEMO ACCOUNTS ONLY — school admin uses the requested local password; others are generated:');
            foreach ($passwords as $email => $password) {
                $this->command?->line($email . ' : ' . $password);
            }
            $this->command?->warn('Disable SMS_ALLOW_DEMO_SEED after setup. Never expose these credentials.');
        }
    }
}
