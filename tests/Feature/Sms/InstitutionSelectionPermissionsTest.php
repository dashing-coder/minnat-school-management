<?php

declare(strict_types=1);

namespace Tests\Feature\Sms;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class InstitutionSelectionPermissionsTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_cannot_select_an_unassigned_or_suspended_institution(): void
    {
        $user = User::factory()->create();
        $a = DB::table('institutions')->insertGetId([
            'code' => 'QA_A', 'slug' => 'qa-a', 'name' => 'Authorized School',
            'type' => 'school', 'status' => 'active',
        ]);
        $b = DB::table('institutions')->insertGetId([
            'code' => 'QA_B', 'slug' => 'qa-b', 'name' => 'Other Institution',
            'type' => 'college', 'status' => 'active',
        ]);
        DB::table('institution_memberships')->insert([
            'institution_id' => $a, 'user_id' => $user->id, 'status' => 'active',
            'can_access_all_campuses' => 1,
        ]);
        $this->actingAs($user);
        $this->get('/choose-institution')->assertOk()
            ->assertSee('Authorized School')->assertDontSee('Other Institution');
        $this->post('/choose-institution', ['institution_id' => $b])->assertForbidden();
        self::assertNull(session('sms_institution_id'));
        $this->post('/choose-institution', ['institution_id' => $a])->assertRedirect('/dashboard');
        self::assertSame($a, session('sms_institution_id'));
        DB::table('institutions')->where('id', $a)->update(['status' => 'suspended']);
        $this->post('/choose-institution', ['institution_id' => $a])->assertForbidden();
    }
}
