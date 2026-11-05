<?php

declare(strict_types=1);

namespace Tests\Feature\Sms;

use App\Models\Campus;
use App\Models\Institution;
use App\Models\User;
use Database\Seeders\SmsPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TenantIsolationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_cannot_open_another_institutions_context(): void
    {
        $user = User::factory()->create();
        $institutionA = $this->createInstitution('school-a');
        $institutionB = $this->createInstitution('school-b');
        $membershipId = $this->addActiveMember($institutionA, $user, true);
        $this->allowPermission($institutionA, $membershipId, 'dashboard.view');

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/institutions/school-a/context')
            ->assertOk()
            ->assertJsonPath('data.institution.name', 'school-a');
        $this->getJson('/api/v1/institutions/school-b/context')->assertForbidden();
    }

    public function test_campus_list_only_contains_authorized_campuses(): void
    {
        $user = User::factory()->create();
        $institution = $this->createInstitution('madrasha-one');
        $membershipId = $this->addActiveMember($institution, $user, false);
        $this->allowPermission($institution, $membershipId, 'campuses.view');

        $campusA = Campus::query()->create([
            'institution_id' => $institution->id, 'code' => 'NORTH', 'name' => 'North Campus',
        ]);
        Campus::query()->create([
            'institution_id' => $institution->id, 'code' => 'SOUTH', 'name' => 'South Campus',
        ]);

        DB::table('membership_campuses')->insert([
            'institution_id' => $institution->id,
            'membership_id' => $membershipId,
            'campus_id' => $campusA->id,
        ]);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/institutions/madrasha-one/campuses')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.code', 'NORTH');
    }

    public function test_active_member_without_required_permission_is_denied(): void
    {
        $user = User::factory()->create();
        $institution = $this->createInstitution('college-one');
        $this->addActiveMember($institution, $user, true);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/institutions/college-one/campuses')->assertForbidden();
    }

    private function createInstitution(string $slug): Institution
    {
        return Institution::query()->create([
            'code' => strtoupper(str_replace('-', '_', $slug)),
            'slug' => $slug,
            'name' => $slug,
            'type' => 'school',
            'status' => 'active',
        ]);
    }

    private function addActiveMember(Institution $institution, User $user, bool $allCampuses): int
    {
        return (int) DB::table('institution_memberships')->insertGetId([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'status' => 'active',
            'can_access_all_campuses' => $allCampuses,
        ]);
    }

    private function allowPermission(Institution $institution, int $membershipId, string $permission): void
    {
        $this->seed(SmsPermissionSeeder::class);
        $roleId = DB::table('institution_roles')->insertGetId([
            'institution_id' => $institution->id,
            'key' => 'test-role',
            'name' => 'Test Role',
        ]);
        $permissionId = DB::table('sms_permissions')->where('key', $permission)->value('id');
        DB::table('institution_role_permissions')->insert([
            'role_id' => $roleId,
            'permission_id' => $permissionId,
        ]);
        DB::table('membership_roles')->insert([
            'institution_id' => $institution->id,
            'membership_id' => $membershipId,
            'role_id' => $roleId,
        ]);
    }
}
