<?php
namespace App\Http\Controllers;
use App\Support\SmsAccess;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
final class StudentController {
    public function index(Request $request) {
        SmsAccess::require('students.view');
        $q=SmsAccess::scopedQuery('students');
        if($request->filled('search')) {
            $s=trim($request->string('search')->toString());
            $q->where(fn($x)=>$x->where('name','like','%'.$s.'%')->orWhere('admission_no','like','%'.$s.'%'));
        }
        $students=$q->orderByDesc('id')->paginate(15)->withQueryString();
        return view('students.index',compact('students'));
    }
    public function create() {
        SmsAccess::require('students.create'); $student=null; $campuses=SmsAccess::allowedCampuses();
        return view('students.form',compact('student','campuses'));
    }
    public function edit(int $id) {
        SmsAccess::require('students.update'); $student=SmsAccess::scopedQuery('students')->where('id',$id)->first(); abort_unless($student,404);
        $campuses=SmsAccess::allowedCampuses(); return view('students.form',compact('student','campuses'));
    }
    private function valid(Request $request,?int $id=null): array {
        $institutionId=SmsAccess::institutionId();
        return $request->validate([
            'name'=>['required','string','min:2','max:180'],
            'admission_no'=>['required','string','max:40',Rule::unique('students','admission_no')->where('institution_id',$institutionId)->ignore($id)],
            'campus_id'=>['required','integer',Rule::in(SmsAccess::allowedCampuses()->pluck('id')->all())],
            'gender'=>['nullable',Rule::in(['male','female','other'])],
            'birth_date'=>['nullable','date','before:today'],
            'blood_group'=>['nullable','string','max:8'],
            'status'=>['required',Rule::in(['active','inactive','graduated','transferred','withdrawn'])],
        ]);
    }
    public function store(Request $request) {
        SmsAccess::require('students.create'); $data=$this->valid($request); $data['institution_id']=SmsAccess::institutionId();
        DB::transaction(function()use($request,$data) {
            $id=DB::table('students')->insertGetId(array_merge($data,['created_at'=>now(),'updated_at'=>now()]));
            DB::table('sms_audit_logs')->insert(['institution_id'=>SmsAccess::institutionId(),'actor_user_id'=>$request->user()->id,'action'=>'students.create','resource_type'=>'students','resource_id'=>(string)$id,'created_at'=>now()]);
        });
        return redirect()->route('students.index')->with('success','Student created successfully.');
    }
    public function update(Request $request,int $id) {
        SmsAccess::require('students.update');
        $student=SmsAccess::scopedQuery('students')->where('id',$id)->first(); abort_unless($student,404);
        $data=$this->valid($request,$id);
        DB::transaction(function()use($request,$data,$id) {
            SmsAccess::scopedQuery('students')->where('id',$id)->update(array_merge($data,['updated_at'=>now()]));
            DB::table('sms_audit_logs')->insert(['institution_id'=>SmsAccess::institutionId(),'actor_user_id'=>$request->user()->id,'action'=>'students.update','resource_type'=>'students','resource_id'=>(string)$id,'created_at'=>now()]);
        });
        return redirect()->route('students.index')->with('success','Student updated successfully.');
    }
}
