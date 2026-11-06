<?php

namespace Tests\Feature\Sms;

use App\Models\User;
use Database\Seeders\SmsPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class StudentTenantBoundaryTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_list_and_update_never_cross_institution_boundary(): void
    {
        $this->seed(SmsPermissionSeeder::class);
        $user=User::factory()->create();
        $a=$this->setupInstitution('ALPHA');
        $b=$this->setupInstitution('BRAVO');
        $aStudent=$this->addStudent($a,'A-FIRST');
        $bStudent=$this->addStudent($b,'B-SECRET');
        $membershipId=DB::table('institution_memberships')->insertGetId([
            'institution_id'=>$a,'user_id'=>$user->id,'status'=>'active','can_access_all_campuses'=>1
        ]);
        $roleId=DB::table('institution_roles')->insertGetId([
            'institution_id'=>$a,'key'=>'admin','name'=>'Administrator','is_system'=>1
        ]);
        DB::table('membership_roles')->insert([
            'institution_id'=>$a,'membership_id'=>$membershipId,'role_id'=>$roleId
        ]);
        foreach(['students.view','students.update'] as $permission){
            DB::table('institution_role_permissions')->insert([
                'role_id'=>$roleId,'permission_id'=>DB::table('sms_permissions')->where('key',$permission)->value('id')
            ]);
        }
        $this->actingAs($user)->withSession(['sms_institution_id'=>$a]);
        $this->get('/students')->assertOk()->assertSee('A-FIRST')->assertDontSee('B-SECRET');
        $this->get('/students/'.$bStudent.'/edit')->assertNotFound();
        $this->put('/students/'.$bStudent,[
            'name'=>'Unauthorized','admission_no'=>'B-SECRET',
            'campus_id'=>DB::table('students')->where('id',$aStudent)->value('campus_id'),
            'status'=>'active'
        ])->assertNotFound();
        self::assertSame('B-SECRET',DB::table('students')->where('id',$bStudent)->value('name'));
    }
    private function setupInstitution(string $code): int
    {
        return DB::table('institutions')->insertGetId([
            'code'=>$code,'slug'=>strtolower($code),'name'=>$code,
            'type'=>'school','status'=>'active','timezone'=>'Asia/Dhaka','locale'=>'en','currency'=>'BDT'
        ]);
    }
    private function addStudent(int $institutionId,string $name): int
    {
        $campus=DB::table('campuses')->insertGetId([
            'institution_id'=>$institutionId,'code'=>'MAIN','name'=>'Main','is_main'=>1,'is_active'=>1
        ]);
        return DB::table('students')->insertGetId([
            'institution_id'=>$institutionId,'campus_id'=>$campus,
            'admission_no'=>$name,'name'=>$name,'status'=>'active'
        ]);
    }
}
