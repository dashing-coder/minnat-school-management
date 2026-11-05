<?php
namespace App\Http\Controllers;
use App\Support\SmsAccess;
use Illuminate\Support\Facades\DB;
final class PortalController {
    public function index() {
        $userId=auth()->id();
        $ownStudent=SmsAccess::scopedQuery('students')->where('user_id',$userId)->get();
        $parentIds=SmsAccess::scopedQuery('guardians')->where('user_id',$userId)->pluck('id');
        $childIds=SmsAccess::scopedQuery('student_guardians')->whereIn('guardian_id',$parentIds)->pluck('student_id');
        $children=SmsAccess::scopedQuery('students')->whereIn('id',$childIds)->get();
        return view('portal',compact('ownStudent','children'));
    }
}
