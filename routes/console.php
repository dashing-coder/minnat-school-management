<?php

use App\Support\SmsQualityAudit;
use Illuminate\Support\Facades\Artisan;

Artisan::command('sms:about', function () {
    $this->info('CampusSphere ERP — Laravel 12 development baseline');
});

Artisan::command('sms:qa {--json : Machine-readable JSON output}', function () {
    $result = SmsQualityAudit::run();
    if ($this->option('json')) {
        $this->line(json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
    } else {
        $this->info('CampusSphere: read-only database and module QA');
        foreach ($result['checks'] as $check) {
            $this->line(sprintf('[%s] %s — %s', $check['status'], $check['id'], $check['message']));
        }
        $this->line(sprintf('Summary: %d PASS / %d WARN / %d FAIL',
            $result['pass'], $result['warn'], $result['fail']));
        $this->warn('Register availability is NOT end-to-end workflow verification.');
    }
    return $result['fail'] ? 1 : 0;
})->purpose('Read-only QA for all ERP modules, migrations, finance and authentication configuration');

Artisan::command('sms:integrations:check {--json : Print JSON}', function () {
    $result=\App\Support\SmsIntegrationDiagnostics::run();
    if ($this->option('json')) $this->line(json_encode($result,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES));
    else foreach ($result as $check) $this->line(sprintf('[%s] %s — %s',$check['status'],$check['id'],$check['message']));
    return count(array_filter($result,fn($x)=>$x['status']==='FAIL')) ? 1:0;
})->purpose('Read-only provider configuration and outbox health inventory; no external calls');


// Read-only reconciliation; excludes refunds not yet approved and never modifies the ledger.
Artisan::command('sms:finance:reconcile {--institution= : Optional institution ID} {--json : Output JSON}',function () {
    $id=$this->option('institution');
    if($id!==null && (!ctype_digit((string)$id) || (int)$id<1)) {
        $this->error('Institution must be a positive numeric ID.');return 2;
    }
    $report=\App\Support\SmsFinanceReconciliation::run($id===null?null:(int)$id);
    if($this->option('json')) $this->line(json_encode($report,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES));
    else {
        $this->info('CampusSphere read-only financial reconciliation: '.$report['status']);
        foreach($report['checks'] as $c) $this->line(sprintf('[%s] %s — %s exceptions', $c['status'],$c['check'],$c['exceptions']));
    }
    return $report['status']==='FAIL'?1:($report['status']==='WARN'?2:0);
})->purpose('Read-only invoice, allocation, ledger, tenant and payroll reconciliation');


Artisan::command('sms:biometric:register {--institution= : Institution ID} {--campus= : Campus ID} {--code= : Device code} {--activate : Enable local demo device}',function(){
    if(!app()->environment(['local','testing'])){$this->error('Local/testing only');return 2;}
    $id=filter_var($this->option('institution'),FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);
    $campus=filter_var($this->option('campus'),FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);
    $code=(string)$this->option('code');
    if(!$id||!$campus||!preg_match('/^[A-Za-z0-9_-]{3,80}$/D',$code)){$this->error('Invalid institution/campus/device code');return 2;}
    if(!\Illuminate\Support\Facades\DB::table('campuses')->where('institution_id',$id)->where('id',$campus)->exists()){
        $this->error('Campus not found in institution');return 1;
    }
    \Illuminate\Support\Facades\DB::table('biometric_devices')->updateOrInsert(
        ['institution_id'=>$id,'device_code'=>$code],
        ['campus_id'=>$campus,'name'=>'Local pilot device '.$code,'is_active'=>(bool)$this->option('activate'),
            'updated_at'=>now()]);
    $this->warn('Local demo device registered. No external device connected.');return 0;
});
Artisan::command('sms:biometric:import {path : CSV path under storage/app/private/biometric-imports} {--institution= : Institution ID} {--device= : Registered code} {--commit : Import validated rows}',function(){
    $id=filter_var($this->option('institution'),FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);
    if(!$id){$this->error('Provide a valid institution ID');return 2;}
    try{$report=\App\Support\SmsBiometricImport::run((int)$id,(string)$this->option('device'),$this->argument('path'),(bool)$this->option('commit'));
        $this->line(json_encode($report,JSON_PRETTY_PRINT));return 0;
    }catch(\Throwable $e){$this->error($e->getMessage());return 1;}
})->purpose('Local CSV-only biometric attendance pilot; dry-run unless --commit');

Artisan::command('sms:notifications:simulate {--institution= : Institution ID} {--commit : Mark queued demo notifications as simulated}',function(){
    if(!app()->environment(['local','testing'])){$this->error('Local/testing only');return 2;}
    $id=filter_var($this->option('institution'),FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);
    if(!$id){$this->error('Provide an institution ID');return 2;}
    $q=\Illuminate\Support\Facades\DB::table('notification_deliveries')
        ->where('institution_id',$id)->where('status','queued')->whereIn('channel',['sms','whatsapp']);
    $count=$q->count();
    if(!$this->option('commit')){$this->line($count.' messages pending simulation (no messages sent).');return 0;}
    $changed=$q->update(['status'=>'simulated','updated_at'=>now()]);
    $this->warn($changed.' messages marked SIMULATED; zero SMS or WhatsApp messages sent.');return 0;
})->purpose('Local notification simulation; NEVER contacts external SMS/WhatsApp services');


Artisan::command('sms:release:check {--json : Print JSON} {--production : Check production sign-off requirements}',function(){
    $report=\App\Support\SmsReleaseGate::run((bool)$this->option('production'));
    if($this->option('json'))$this->line(json_encode($report,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES));
    else {
        foreach($report['checks'] as $c)$this->line('['.$c['status'].'] '.$c['check'].' — '.$c['detail']);
        $this->warn($report['warning']);
    }
    return $report['ready']?0:1;
})->purpose('Read-only production readiness gate; does not deploy');
