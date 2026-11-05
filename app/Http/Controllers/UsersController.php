<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Support\SmsAccess;
use App\Support\SmsAudit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/** Controlled local demo user provisioning and tenant role assignment. */
final class UsersController
{
    private function authorizeAdmin(): void
    {
        SmsAccess::require('memberships.manage');
        SmsAccess::require('roles.manage');
        abort_unless((int)SmsAccess::membership()->can_access_all_campuses===1,403);
    }
    public function index()
    {
        $this->authorizeAdmin();$tenant=SmsAccess::institutionId();
        $members=DB::table('institution_memberships as m')->join('users as u','u.id','=','m.user_id')
            ->where('m.institution_id',$tenant)->select('m.id','m.user_id','m.status','m.can_access_all_campuses','u.name','u.email')
            ->orderBy('u.name')->paginate(30);
        $roles=DB::table('institution_roles')->where('institution_id',$tenant)->orderBy('name')->get();
        return view('users.index',compact('members','roles'));
    }
    public function store(Request $request)
    {
        $this->authorizeAdmin();
        // Local demos only. Real deployments need secure invitation and verified onboarding.
        abort_unless(app()->environment(['local','testing']),403,'User provisioning requires a verified invitation workflow in production.');
        $tenant=SmsAccess::institutionId();
        $data=$request->validate([
            'name'=>['required','string','min:2','max:190'],
            'email'=>['required','email','max:190',Rule::unique('users','email')],
            'role_id'=>['required','integer',Rule::exists('institution_roles','id')->where('institution_id',$tenant)],
        ]);
        $password=Str::random(28);
        DB::transaction(function()use($tenant,$data,$password){
            $user=User::create(['name'=>$data['name'],'email'=>$data['email'],'password'=>Hash::make($password)]);
            $membership=DB::table('institution_memberships')->insertGetId([
                'institution_id'=>$tenant,'user_id'=>$user->id,'status'=>'active','can_access_all_campuses'=>1,
                'joined_at'=>now(),'created_at'=>now(),'updated_at'=>now()
            ]);
            DB::table('membership_roles')->insert(['institution_id'=>$tenant,'membership_id'=>$membership,
                'role_id'=>$data['role_id'],'created_at'=>now()]);
            SmsAudit::record('membership.create','institution_memberships',$membership);
        });
        // Flash is only for this response and must not be included in logs, URLs or email.
        return redirect()->route('users.index')->with('success','Demo user created.')
            ->with('demo_credentials',['email'=>$data['email'],'password'=>$password]);
    }
    public function assign(Request $request,int $membershipId)
    {
        $this->authorizeAdmin();$tenant=SmsAccess::institutionId();
        $member=DB::table('institution_memberships')->where('institution_id',$tenant)->where('id',$membershipId)->first();
        abort_unless($member,404);
        abort_if((int)$member->user_id === (int)$request->user()->id,403,'Cannot modify your own roles.');
        $data=$request->validate([
            'role_id'=>['required','integer',Rule::exists('institution_roles','id')->where('institution_id',$tenant)],
        ]);
        DB::transaction(function()use($tenant,$member,$data){
            DB::table('membership_roles')->where('institution_id',$tenant)->where('membership_id',$member->id)->delete();
            DB::table('membership_roles')->insert(['institution_id'=>$tenant,'membership_id'=>$member->id,
                'role_id'=>$data['role_id'],'created_at'=>now()]);
            SmsAudit::record('membership.role.change','institution_memberships',$member->id);
        });
        return redirect()->route('users.index')->with('success','Institution role updated.');
    }
}
