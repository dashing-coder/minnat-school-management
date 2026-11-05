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
