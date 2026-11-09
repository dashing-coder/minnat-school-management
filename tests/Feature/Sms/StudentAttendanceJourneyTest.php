<?php

declare(strict_types=1);
namespace Tests\Feature\Sms;

use App\Models\User;
use Database\Seeders\SmsPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class StudentAttendanceJourneyTest extends TestCase
{
    use RefreshDatabase;

    private function institution(string $key): array
    {
        $id = DB::table('institutions')->insertGetId([
            'code'=>$key,'slug'=>strtolower($key),'name'=>'School '.$key,
            'type'=>'school','status'=>'active','timezone'=>'Asia/Dhaka','locale'=>'en','currency'=>'BDT',
        ]);
        $campus = DB::table('campuses')->insertGetId([
            'institution_id'=>$id,'code'=>'MAIN','name'=>'Main Campus','is_main'=>1,'is_active'=>1,
        ]);
        return [$id,$campus];
    }

    private function permissionedUser(int $institutionId, array $permissions): User
    {
        $this->seed(SmsPermissionSeeder::class);
        $user = User::factory()->create();
        $membershipId = DB::table('institution_memberships')->insertGetId([
            'institution_id'=>$institutionId,'user_id'=>$user->id,
            'status'=>'active','can_access_all_campuses'=>1,
        ]);
        $role = DB::table('institution_roles')->insertGetId([
            'institution_id'=>$institutionId,'key'=>'qa','name'=>'QA Test Role','is_system'=>0,
        ]);
        DB::table('membership_roles')->insert([
            'institution_id'=>$institutionId,'membership_id'=>$membershipId,'role_id'=>$role,
        ]);
        foreach ($permissions as $key) {
            $permissionId = DB::table('sms_permissions')->where('key',$key)->value('id');
            self::assertNotNull($permissionId, "Permission {$key} must exist");
            DB::table('institution_role_permissions')->insert(['role_id'=>$role,'permission_id'=>$permissionId]);
        }
        $this->actingAs($user)->withSession(['sms_institution_id'=>$institutionId]);
        return $user;
    }

    private function student(int $institutionId, int $campus, string $name): int
    {
        return DB::table('students')->insertGetId([
            'institution_id'=>$institutionId,'campus_id'=>$campus,
            'admission_no'=>$name,'name'=>$name,'status'=>'active',
        ]);
    }

    public function test_student_creation_is_validated_and_audited(): void
    {
        [$institution,$campus] = $this->institution('STUDENT_QA');
        $this->permissionedUser($institution,['students.view','students.create']);
        $this->post('/students',['name'=>'Test Child','admission_no'=>'A-001',
            'campus_id'=>$campus,'status'=>'active'])->assertRedirect('/students');
        self::assertSame(1,DB::table('students')->where('institution_id',$institution)->count());
        self::assertSame(1,DB::table('sms_audit_logs')->where('institution_id',$institution)
            ->where('action','students.create')->count());
        $this->post('/students',['name'=>'Test Child 2','admission_no'=>'A-001',
            'campus_id'=>$campus,'status'=>'active'])->assertSessionHasErrors('admission_no');
        self::assertSame(1,DB::table('students')->where('institution_id',$institution)->count());
    }

    public function test_attendance_picker_only_lists_active_section_students_from_active_tenant(): void
    {
        [$a,$campusA] = $this->institution('SCHOOL_A');
        [$b,$campusB] = $this->institution('SCHOOL_B');
        $studentA = $this->student($a,$campusA,'A-CHILD');
        $this->student($b,$campusB,'B-CHILD');
        $otherSectionStudent = $this->student($a,$campusA,'OTHER-SECTION');
        $level = DB::table('class_levels')->insertGetId(['institution_id'=>$a,'code'=>'G1','name'=>'Grade 1','sequence'=>1]);
        $section = DB::table('class_sections')->insertGetId([
            'institution_id'=>$a,'campus_id'=>$campusA,'class_level_id'=>$level,
            'code'=>'A','name'=>'A','shift'=>'day',
        ]);
        $otherSection = DB::table('class_sections')->insertGetId([
            'institution_id'=>$a,'campus_id'=>$campusA,'class_level_id'=>$level,
            'code'=>'B','name'=>'B','shift'=>'day',
        ]);
        $session = DB::table('attendance_sessions')->insertGetId([
            'institution_id'=>$a,'class_section_id'=>$section,
            'attendance_on'=>date('Y-m-d'),'period_code'=>'daily','status'=>'open',
        ]);
        $academic = DB::table('academic_sessions')->insertGetId([
            'institution_id'=>$a,'code'=>'2026','name'=>'2026',
            'starts_on'=>'2026-01-01','ends_on'=>'2026-12-31','status'=>'active',
        ]);
        foreach ([[$studentA,$section],[$otherSectionStudent,$otherSection]] as [$student,$classSection]) {
            DB::table('enrollments')->insert([
                'institution_id'=>$a,'student_id'=>$student,'academic_session_id'=>$academic,
                'class_section_id'=>$classSection,'roll_no'=>(string)$student,'status'=>'active',
            ]);
        }
        $this->permissionedUser($a,['attendance.record']);
        $this->get('/attendance/mark?attendance_session_id='.$session)
            ->assertOk()->assertSee('A-CHILD')->assertDontSee('B-CHILD')->assertDontSee('OTHER-SECTION');
        $this->post('/attendance/mark',[
            'attendance_session_id'=>$session,'student_id'=>$studentA,'status'=>'present',
        ])->assertRedirect('/attendance/mark?attendance_session_id='.$session);
        self::assertSame(1, DB::table('student_attendance')->where('institution_id',$a)->count());
        $this->post('/attendance/mark',[
            'attendance_session_id'=>$session,'student_id'=>$otherSectionStudent,'status'=>'present',
        ])->assertStatus(422);
        self::assertSame(1, DB::table('student_attendance')->where('institution_id',$a)->count());
    }

    public function test_non_privileged_user_cannot_access_student_or_attendance_editor(): void
    {
        [$a] = $this->institution('ACCESS_TEST');
        $this->permissionedUser($a,['dashboard.view']);
        $this->get('/students')->assertForbidden();
        $this->get('/attendance/mark')->assertForbidden();
    }
}
