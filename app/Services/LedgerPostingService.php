<?php
namespace App\Services;

use App\Support\SmsAccess;
use App\Support\SmsAudit;
use App\Support\SmsMoney;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Posting engine: only balanced, positive and institution-owned account lines.
 * Caller MUST wrap posting and its business-document update in a DB transaction.
 */
final class LedgerPostingService
{
    public function post(string $sourceType,string $sourceReference,string $description,string $on,array $lines): int
    {
        $tenant=SmsAccess::institutionId();
        $closed=DB::table('financial_period_closings as f')
            ->join('academic_sessions as a',function($join) { $join->on('a.id','=','f.academic_session_id')->on('a.institution_id','=','f.institution_id'); })
            ->where('f.institution_id',$tenant)->where('f.status','closed')
            ->whereDate('a.starts_on','<=',$on)->whereDate('a.ends_on','>=',$on)->exists();
        if($closed) throw ValidationException::withMessages(['date'=>'This accounting period is closed.']);
        $debit=0;$credit=0;
        if(count($lines)<2)throw ValidationException::withMessages(['amount'=>'Journal needs at least two lines.']);
        foreach($lines as $line) {
            $account=DB::table('chart_of_accounts')->where('institution_id',$tenant)->where('id',$line['account_id'])->where('is_active',1)->first();
            if(!$account)throw ValidationException::withMessages(['account_id'=>'Invalid or inactive account.']);
            $d=SmsMoney::cents($line['debit']); $c=SmsMoney::cents($line['credit']);
            if (($d>0 && $c>0)||($d===0 && $c===0)) throw ValidationException::withMessages(['amount'=>'Every journal line must contain one debit or one credit.']);
            $debit+=$d;$credit+=$c;
        }
        if ($debit<1 || $debit!==$credit)throw ValidationException::withMessages(['amount'=>'Journal debit and credit must be equal and positive.']);
        // Lock a *present* parent row; locking a nonexistent journal is not a
        // race barrier on all DB isolation levels. The unique DB key is the
        // final guarantee under concurrent POST requests.
        if (trim($sourceType)==='' || trim($sourceReference)==='') {
            throw ValidationException::withMessages(['reference_no'=>'A stable posting source is required.']);
        }
        DB::table('institutions')->where('id',$tenant)->lockForUpdate()->first();
        $existing=DB::table('ledger_journals')->where('institution_id',$tenant)->where('source_type',$sourceType)->where('source_reference',$sourceReference)->lockForUpdate()->first();
        if($existing)throw ValidationException::withMessages(['reference_no'=>'This transaction has already been posted.']);
        $id=DB::table('ledger_journals')->insertGetId([
            'institution_id'=>$tenant,'journal_no'=>'J-'.strtoupper(substr(bin2hex(random_bytes(6)),0,12)),
            'posted_on'=>$on,'source_type'=>$sourceType,'source_reference'=>$sourceReference,
            'description'=>$description,'status'=>'posted','created_at'=>now(),'updated_at'=>now()
        ]);
        foreach($lines as $line) {
            DB::table('ledger_lines')->insert([
                'institution_id'=>$tenant,'ledger_journal_id'=>$id,'account_id'=>$line['account_id'],
                'debit'=>$line['debit'],'credit'=>$line['credit'],'created_at'=>now(),'updated_at'=>now()
            ]);
        }
        SmsAudit::record('ledger.post','ledger_journals',$id,['source'=>$sourceType]);
        return $id;
    }
}
