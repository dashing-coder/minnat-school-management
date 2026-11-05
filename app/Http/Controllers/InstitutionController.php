<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
final class InstitutionController {
    public function choose(Request $request) {
        $institutions=DB::table('institution_memberships as m')
            ->join('institutions as i','i.id','=','m.institution_id')
            ->where('m.user_id',$request->user()->id)->where('m.status','active')
            ->where('i.status','active')->whereNull('i.deleted_at')
            ->select('i.id','i.name','i.code','i.type')->orderBy('i.name')->get();
        return view('auth.institutions',compact('institutions'));
    }
    public function select(Request $request) {
        $validated=$request->validate(['institution_id'=>['required','integer']]);
        $allowed=DB::table('institution_memberships as m')
           ->join('institutions as i','i.id','=','m.institution_id')
           ->where('m.user_id',$request->user()->id)
           ->where('m.institution_id',$validated['institution_id'])
           ->where('m.status','active')->where('i.status','active')->whereNull('i.deleted_at')->exists();
        abort_unless($allowed,403);
        $request->session()->put('sms_institution_id',(int)$validated['institution_id']);
        $request->session()->regenerate();
        return redirect()->route('dashboard');
    }
}
