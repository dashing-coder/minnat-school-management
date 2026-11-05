<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

/** Local demo-only opt-in repair of known legacy fake-data account mappings. */
final class SmsDemoFinancialReferenceRepairSeeder extends Seeder
{
    public function run(): void
    {
        if (!app()->environment(['local','testing']) || !filter_var(env('SMS_ALLOW_DEMO_REPAIR',false),FILTER_VALIDATE_BOOLEAN))
            throw new RuntimeException('Demo repair requires local/testing environment and SMS_ALLOW_DEMO_REPAIR=true.');
        DB::transaction(function() {
            foreach(['SCHDEMO','COLDEMO','MADDEMO'] as $code) {
                $inst=DB::table('institutions')->where('code',$code)->first();
                if(!$inst)continue;
                $ar=DB::table('chart_of_accounts')->where('institution_id',$inst->id)->where('code','1100')->first();
                $revenue=DB::table('chart_of_accounts')->where('institution_id',$inst->id)->where('code','4100')->where('account_type','income')->first();
                if(!$ar||!$revenue)continue;
                DB::table('chart_of_accounts')->where('id',$ar->id)->where('institution_id',$inst->id)->update(['is_active'=>1,'updated_at'=>now()]);
                DB::table('fee_heads')->where('institution_id',$inst->id)->where('code','TUITION')->update(['revenue_account_id'=>$revenue->id,'updated_at'=>now()]);
                DB::table('fee_heads')->where('institution_id',$inst->id)->where('code','HIFZ')->update(['revenue_account_id'=>$revenue->id,'updated_at'=>now()]);
                $cash=DB::table('chart_of_accounts')->where('institution_id',$inst->id)->where('code','1000')->where('account_type','asset')->first();
                if($cash)DB::table('bank_accounts')->where('institution_id',$inst->id)->update(['account_id'=>$cash->id,'updated_at'=>now()]);
                DB::table('library_loans')->where('institution_id',$inst->id)->where('status','active')->update(['status'=>'issued','updated_at'=>now()]);
                DB::table('library_copies')->where('institution_id',$inst->id)
                    ->whereIn('id',DB::table('library_loans')->where('institution_id',$inst->id)->where('status','issued')->select('library_copy_id'))
                    ->update(['status'=>'issued','updated_at'=>now()]);
                DB::table('hostel_beds')->where('institution_id',$inst->id)
                    ->whereIn('id',DB::table('hostel_allocations')->where('institution_id',$inst->id)->where('status','active')->select('hostel_bed_id'))
                    ->update(['status'=>'occupied','updated_at'=>now()]);
            }
        });
    }
}
