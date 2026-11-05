<?php
namespace App\Http\Middleware;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;
final class EnsureCurrentInstitution {
    public function handle(Request $request, Closure $next): Response {
        $id=(int)$request->session()->get('sms_institution_id',0);
        if ($id<1) return redirect()->route('institution.choose');
        $membership=DB::table('institution_memberships as m')
            ->join('institutions as i','i.id','=','m.institution_id')
            ->select('m.*','i.name as institution_name','i.type as institution_type','i.currency as institution_currency')
            ->where('m.user_id',$request->user()->id)->where('m.institution_id',$id)
            ->where('m.status','active')->where('i.status','active')->whereNull('i.deleted_at')->first();
        if (!$membership) { $request->session()->forget('sms_institution_id'); return redirect()->route('institution.choose'); }
        $permissionKeys=DB::table('membership_roles as mr')
            ->join('institution_role_permissions as rp','rp.role_id','=','mr.role_id')
            ->join('sms_permissions as p','p.id','=','rp.permission_id')
            ->where('mr.institution_id',$id)->where('mr.membership_id',$membership->id)
            ->distinct()->pluck('p.key')->all();
        $request->attributes->set('sms_membership',$membership);
        $request->attributes->set('sms_permissions',$permissionKeys);
        $request->attributes->set('sms_institution_id',$id);
        \Illuminate\Support\Facades\View::share('activeInstitution',$membership);
        \Illuminate\Support\Facades\View::share('activePermissions',$permissionKeys);
        return $next($request);
    }
}
