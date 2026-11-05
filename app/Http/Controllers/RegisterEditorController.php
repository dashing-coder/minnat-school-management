<?php
namespace App\Http\Controllers;

use App\Support\EditableRegisters;
use App\Support\ModuleCatalog;
use App\Support\SmsAccess;
use App\Support\SmsAudit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\Rule;

/**
 * Constrained CRUD for explicit, non-transactional reference tables only.
 * Ledger, payments, published marks, payroll postings, audit/security and other
 * transactional entities are deliberately not editable here.
 */
final class RegisterEditorController
{
    private const PARENT_TABLES = [
        'campus_id'=>'campuses','academic_session_id'=>'academic_sessions',
        'academic_term_id'=>'academic_terms','department_id'=>'academic_departments',
        'program_id'=>'academic_programs','class_level_id'=>'class_levels',
        'class_section_id'=>'class_sections','subject_id'=>'subjects',
        'class_subject_id'=>'class_subjects','student_id'=>'students',
        'guardian_id'=>'guardians','employee_id'=>'employees',
        'grading_scale_id'=>'grading_scales','revenue_account_id'=>'chart_of_accounts',
        'account_id'=>'chart_of_accounts','fee_head_id'=>'fee_heads',
        'fee_plan_id'=>'fee_plans','library_book_id'=>'library_books',
        'vehicle_id'=>'vehicles','hostel_id'=>'hostels','hostel_room_id'=>'hostel_rooms',
        'inventory_item_id'=>'inventory_items','supplier_id'=>'suppliers',
        'donor_id'=>'donors','donation_fund_id'=>'donation_funds',
        'hifz_group_id'=>'hifz_groups','scholarship_id'=>'scholarships',
        'transport_route_id'=>'transport_routes',
    ];

    public static function writePermission(string $slug, string $table): string
    {
        return match ($slug) {
            'students' => 'students.update',
            'admissions' => 'admissions.manage',
            'academics' => 'academics.manage',
            'exams' => 'results.approve',
            'finance' => in_array($table, ['fee_heads','fee_plans','fee_plan_lines','payment_methods'], true) ? 'fees.adjust' : 'accounting.post',
            'hr' => 'payroll.process',
            'communication' => 'institutions.manage',
            'library' => 'library.manage',
            'residential' => 'hostel.manage',
            'inventory' => 'inventory.manage',
            'institutions' => $table === 'campuses' ? 'campuses.manage' : 'institutions.manage',
            'hifz' => 'institutions.manage',
            'scholarship' => 'donations.manage',
            'certificates' => 'institutions.manage',
            'campus' => 'campuses.manage',
            default => 'institutions.manage',
        };
    }

    public static function canEdit(string $slug, string $table): bool
    {
        return ModuleCatalog::includesTable($slug, $table)
            && EditableRegisters::fields($table) !== null
            && SmsAccess::has(self::writePermission($slug,$table));
    }

    private function authorizeRecord(string $slug, string $table): array
    {
        $module = ModuleCatalog::find($slug);
        abort_unless($module && ModuleCatalog::includesTable($slug, $table), 404);
        SmsAccess::require($module['permission']);
        abort_unless(EditableRegisters::fields($table) !== null, 404);
        SmsAccess::require(self::writePermission($slug, $table));
        abort_unless(Schema::hasTable($table),404);
        return EditableRegisters::fields($table);
    }

    private function options(array $fields): array
    {
        $options=[];
        foreach ($fields as $name => $meta) {
            if (!isset(self::PARENT_TABLES[$name])) continue;
            $parent=self::PARENT_TABLES[$name];
            if (!Schema::hasTable($parent)) continue;
            if ($parent === 'campuses') {
                $rows=SmsAccess::allowedCampuses();
            } else {
                $rows=SmsAccess::scopedQuery($parent)->orderBy('id')->limit(700)->get();
            }
            $options[$name]=$rows->map(function($r) {
                $label=$r->name ?? $r->title ?? $r->code ?? $r->employee_no ?? $r->admission_no ?? $r->sku ?? ('Record #'.$r->id);
                return ['id'=>(int)$r->id,'label'=>(string)$label.' (#'.$r->id.')'];
            })->all();
        }
        return $options;
    }

    private function validateInput(Request $request,array $fields,?int $id=null,string $table=''): array
    {
        $rules=[];
        foreach ($fields as $name => $meta) {
            $type=$meta['type']; $nullable=(bool)$meta['nullable'];
            $r=[$nullable ? 'nullable' : 'required'];
            if (isset(self::PARENT_TABLES[$name])) {
                $parent=self::PARENT_TABLES[$name];
                $r[]='integer';
                $validIds=$parent === 'campuses'
                    ? SmsAccess::allowedCampuses()->pluck('id')->all()
                    : SmsAccess::scopedQuery($parent)->pluck('id')->all();
                $r[]=Rule::in($validIds);
            } elseif (in_array($type,['integer','unsignedInteger','unsignedBigInteger'],true)) {
                $r[]='integer';
                if($type!=='integer')$r[]='min:0';
            } elseif ($type==='decimal') {
                $r[]='numeric'; $r[]='between:0,999999999999.99';
            } elseif ($type==='boolean') {
                $r=['required','boolean'];
            } elseif ($type==='date') {
                $r[]='date_format:Y-m-d';
            } elseif (in_array($type,['dateTime','time'],true)) {
                $r[]='date';
            } else {
                $r[]='string';
                $r[]='max:'.min(65000,max(1,(int)$meta['max']));
            }
            if (in_array($name,['code','sku','barcode','asset_tag','employee_no'],true) && $table) {
                $r[]=Rule::unique($table,$name)->where('institution_id',SmsAccess::institutionId())->ignore($id);
            }
            $rules[$name]=$r;
        }
        $data=$request->validate($rules);
        foreach($data as $field=>$value) {
            if($value === '')$data[$field]=null;
        }
        return $data;
    }

    public function create(string $slug,string $table)
    {
        $fields=$this->authorizeRecord($slug,$table);
        $options=$this->options($fields); $record=null;
        return view('modules.edit',compact('slug','table','fields','options','record'));
    }
    public function edit(string $slug,string $table,int $id)
    {
        $fields=$this->authorizeRecord($slug,$table);
        $record=SmsAccess::scopedQuery($table)->where($table.'.id',$id)->first();
        abort_unless($record,404);
        $options=$this->options($fields);
        return view('modules.edit',compact('slug','table','fields','options','record'));
    }
    public function store(Request $request,string $slug,string $table)
    {
        $fields=$this->authorizeRecord($slug,$table);
        $data=$this->validateInput($request,$fields,null,$table);
        DB::transaction(function() use($table,$data) {
            $id=DB::table($table)->insertGetId(array_merge($data,['institution_id'=>SmsAccess::institutionId(),'created_at'=>now(),'updated_at'=>now()]));
            SmsAudit::record('register.create',$table,$id);
        });
        return redirect()->route('module.records',[$slug,$table])->with('success','Record created.');
    }
    public function update(Request $request,string $slug,string $table,int $id)
    {
        $fields=$this->authorizeRecord($slug,$table);
        $old=SmsAccess::scopedQuery($table)->where($table.'.id',$id)->first();
        abort_unless($old,404);
        $data=$this->validateInput($request,$fields,$id,$table);
        if($table==='chart_of_accounts') {
            $posted=DB::table('ledger_lines')->where('institution_id',SmsAccess::institutionId())->where('account_id',$id)->exists();
            if($posted && (($data['code']??$old->code)!==$old->code || ($data['account_type']??$old->account_type)!==$old->account_type ||
                (array_key_exists('is_active',$data) && !(bool)$data['is_active']))) {
                throw \Illuminate\Validation\ValidationException::withMessages(['account_type'=>'An account with ledger activity cannot be reclassified, recoded or deactivated.']);
            }
        }
        DB::transaction(function() use($table,$id,$data) {
            SmsAccess::scopedQuery($table)->where($table.'.id',$id)->update(array_merge($data,['updated_at'=>now()]));
            SmsAudit::record('register.update',$table,$id);
        });
        return redirect()->route('module.records',[$slug,$table])->with('success','Record updated.');
    }
}
