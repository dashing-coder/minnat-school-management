# CampusSphere safe staging QA runner — PowerShell 5.1+.
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1
# To run DESTRUCTIVE-to-test-DB PHPUnit RefreshDatabase tests, opt in:
# powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1 -RunDatabaseTests
param([switch]$RunDatabaseTests)
$ErrorActionPreference = 'Stop'
if (!(Test-Path '.\artisan')) { throw 'Run this from the Laravel project directory (artisan must be present).' }
function EnvValue([string]$path,[string]$name) {
    if (!(Test-Path $path)) { return $null }
    $line = Get-Content $path | Where-Object { $_ -match ('^\s*' + [regex]::Escape($name) + '\s*=') } | Select-Object -Last 1
    if (!$line) { return $null }
    return (($line -split '=',2)[1].Trim().Trim('"').Trim("'"))
}
$database = EnvValue '.env' 'DB_DATABASE'
if (!$database -or $database -notmatch '(staging|stage|_test|_testing|_ci)') {
    throw "Refusing live-DB inspection: DB_DATABASE '$database' is not explicitly named for staging/testing. Clone the project/database first."
}
if ($database -in @('scm-system','campussphere_local','production')) { throw 'Refusing the working/production database.' }
Write-Host "Staging database label: $database" -ForegroundColor Cyan
$checks=@(
    @('scripts/qa_demo_fixture.php'),
    @('scripts/qa_ui_source.php'),
    @('artisan','migrate:status'),
    @('artisan','sms:qa'),
    @('artisan','sms:finance:reconcile'),
    @('artisan','sms:integrations:check'),
    @('artisan','route:list','--path=api')
)
$failures=0
foreach($argsList in $checks) {
    Write-Host ("`n> php " + ($argsList -join ' ')) -ForegroundColor Cyan
    & php @argsList
    if ($LASTEXITCODE -ne 0) { Write-Warning ("CHECK DID NOT PASS: " + ($argsList -join ' ')); $failures++ }
}
if($RunDatabaseTests) {
    $testDatabase=EnvValue '.env.testing' 'DB_DATABASE'
    if (!(Test-Path '.env.testing')) { throw 'Create .env.testing for a dedicated TEST clone before running RefreshDatabase tests.' }
    if (!$testDatabase -or $testDatabase -notmatch '(^|[_-])(test|testing|ci)([_-]|$)' -or $testDatabase -eq $database) {
        throw "Unsafe test DB_DATABASE '$testDatabase'; must be a dedicated, different *_test / *_ci database."
    }
    $testHost = EnvValue '.env.testing' 'DB_HOST'
    if ($testHost -notin @('127.0.0.1','localhost')) { throw 'Refusing remote test DB host. Use a local disposable DB for this QA runner.' }
    $testConnection = EnvValue '.env.testing' 'DB_CONNECTION'
    if ($testConnection -ne 'mysql') { throw 'Set DB_CONNECTION=mysql in your local .env.testing.' }
    if (!(Test-Path 'phpunit.xml')) { throw 'phpunit.xml is missing.' }
    $declared = [regex]::Match((Get-Content 'phpunit.xml' -Raw), '<env name="DB_DATABASE" value="([^"]+)"')
    if ($declared.Success -and $declared.Groups[1].Value -ne $testDatabase) {
        throw "phpunit.xml points at '$($declared.Groups[1].Value)', while .env.testing points at '$testDatabase'. Set both to the same disposable test database."
    }
    if (!(Test-Path '.\vendor\autoload.php')) { throw 'Composer dependencies missing; run composer install in staging.' }
    Write-Host "`nTESTS MAY RESET TABLES IN '$testDatabase', never in '$database'" -ForegroundColor Yellow
    & php artisan test
    if ($LASTEXITCODE -ne 0) { $failures++ }
} else {
    Write-Host "`nPHPUnit not run: specify -RunDatabaseTests after configuring a disposable .env.testing database." -ForegroundColor Yellow
}
if($failures) { Write-Warning "$failures checks need investigation. NOT READY FOR PRODUCTION."; exit 1 }
Write-Host 'Staging checks succeeded. Production-only release checks are intentionally excluded: they cannot pass in a local staging environment.' -ForegroundColor Green
Write-Host 'Browser QA, signed human UAT, restore drill and go-live approval remain separate requirements.' -ForegroundColor Yellow
exit 0
