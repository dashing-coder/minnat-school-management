<?php

declare(strict_types=1);

namespace Tests\Feature\Sms;

use Database\Seeders\SmsFullDemoSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * End-to-end HTTP requests via Laravel's test client on a disposable *_test / *_ci DB.
 * RefreshDatabase never runs on scm-system because Tests\TestCase blocks it.
 */
final class DemoSchoolHttpJourneyTest extends TestCase
{
    use RefreshDatabase;

    public function test_demo_seed_has_students_and_admin_can_select_school_and_load_modules(): void
    {
        $old = getenv('SMS_ALLOW_DEMO_SEED');
        putenv('SMS_ALLOW_DEMO_SEED=true');
        $_ENV['SMS_ALLOW_DEMO_SEED'] = 'true';
        try {
            $this->seed(SmsFullDemoSeeder::class);
        } finally {
            if ($old === false) {
                putenv('SMS_ALLOW_DEMO_SEED');
                unset($_ENV['SMS_ALLOW_DEMO_SEED']);
            } else {
                putenv('SMS_ALLOW_DEMO_SEED=' . $old);
                $_ENV['SMS_ALLOW_DEMO_SEED'] = $old;
            }
        }

        $school = DB::table('institutions')->where('code', 'SCHDEMO')->first();
        self::assertNotNull($school);
        self::assertGreaterThan(0, DB::table('students')->where('institution_id', $school->id)->count());
        self::assertGreaterThan(0, DB::table('student_invoices')->where('institution_id', $school->id)->count());
        self::assertTrue(Auth::validate([
            'email' => 'admin.school@example.test',
            'password' => 'SchoolAdmin@2026',
        ]));

        $this->post('/login', [
            'email' => 'admin.school@example.test',
            'password' => 'SchoolAdmin@2026',
        ])->assertRedirect('/choose-institution');
        $this->get('/choose-institution')->assertOk()->assertSee('Sunrise Model School');
        $this->post('/choose-institution', ['institution_id' => $school->id])
            ->assertRedirect('/dashboard');
        $this->get('/dashboard')->assertOk()->assertSee('Sunrise Model School');
        $this->get('/students')->assertOk()->assertSee('Registered Students');
        $this->get('/modules/admissions')->assertOk();
        $this->get('/modules/academics')->assertOk();
        $this->get('/modules/finance')->assertOk();
    }
}
