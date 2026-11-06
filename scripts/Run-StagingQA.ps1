# Read-only QA checks for a manually prepared and backed-up STAGING installation.
# Runs no migrations, seeders, network requests or deployment actions.
$ErrorActionPreference = 'Stop'
if (!(Test-Path '.\artisan')) { Write-Error 'Run inside a Laravel project root with artisan'; exit 2 }
$checks = @(
    @('artisan', 'about'),
    @('artisan', 'migrate:status'),
    @('artisan', 'sms:qa'),
    @('artisan', 'sms:integrations:check'),
    @('artisan', 'route:list', '--path=api'),
    @('artisan', 'test')
)
$failed = 0
foreach($argsList in $checks) {
    Write-Host ("`n> php " + ($argsList -join ' ')) -ForegroundColor Cyan
    & php @argsList
    if ($LASTEXITCODE -ne 0) { Write-Warning "FAILED: php $($argsList -join ' ')"; $failed++ }
}
if ($failed -gt 0) { Write-Error "$failed staging checks failed. BLOCK deployment."; exit 1 }
Write-Host 'All scripted checks returned success. Manual UAT and real integration tests are STILL required.' -ForegroundColor Green
exit 0
