# CampusSphere — fail-closed verification of 3 outstanding QA gates.
# Run ONLY from an isolated staging CLONE. Does not migrate, seed, deploy or back up.
# Example: powershell -ExecutionPolicy Bypass -File .\scripts\Run-Final-ThreeGate-QA.ps1 -RunBrowser
# Optional -RunPhpunit resets only a configured, different disposable *_test DB.
param([switch]$RunPhpunit, [switch]$RunBrowser, [switch]$CheckPilot)
$ErrorActionPreference = 'Stop'
if (!(Test-Path '.\artisan')) { throw 'Run this script from a Laravel project root (artisan missing).' }

# Must verify Laravel's EFFECTIVE config, not just a potentially stale .env value.
Write-Host '=== Gate 1: Laravel/MySQL effective staging config ===' -ForegroundColor Cyan
& php scripts/qa_runtime_preflight.php --mode=staging
if ($LASTEXITCODE -ne 0) { throw 'Staging configuration blocked. Do not run tests or browser tests.' }

# Only SELECT/status QA commands. This script never executes artisan migrate or db:seed.
$checks = @(
  @('artisan','migrate:status'),
  @('artisan','sms:qa'),
  @('artisan','sms:finance:reconcile','--json'),
  @('artisan','sms:integrations:check'),
  @('artisan','route:list','--path=api')
)
$failed = 0
foreach ($parts in $checks) {
  Write-Host ("`n> php " + ($parts -join ' ')) -ForegroundColor Cyan
  & php @parts
  if ($LASTEXITCODE -ne 0) { Write-Warning "FAILED: $($parts -join ' ')"; $failed++ }
}

if ($RunPhpunit) {
  # Existing runner requires a separate .env.testing DB and checks phpunit.xml.
  Write-Host "`n=== PHPUnit on disposable test database ===" -ForegroundColor Yellow
  & powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1 -RunDatabaseTests
  if ($LASTEXITCODE -ne 0) { $failed++ }
} else {
  Write-Warning 'PHPUnit NOT RUN; add -RunPhpunit only after preparing a disposable test DB.'
}

if ($RunBrowser) {
  Write-Host "`n=== Gate 2: Local staging browser tests ===" -ForegroundColor Cyan
  if ([string]::IsNullOrWhiteSpace($env:QA_ADMIN_PASSWORD)) {
    throw 'Set QA_ADMIN_PASSWORD in this local terminal; never put it in source code.'
  }
  if (!(Test-Path '.\node_modules\@playwright\test')) {
    throw 'Playwright dependencies missing; run npm install and npx playwright install chromium.'
  }
  $target = if ($env:QA_BASE_URL) {$env:QA_BASE_URL} else {'http://127.0.0.1:8001'}
  if ($target -notmatch '^http://(127\.0\.0\.1|localhost)(:\d+)?/?$') {
    throw 'QA_BASE_URL must be a local staging URL, e.g. http://127.0.0.1:8001.'
  }
  # Delete prior authenticated state to avoid accepting a stale session.
  if (Test-Path '.\qa\.auth\admin.json') { Remove-Item '.\qa\.auth\admin.json' -Force }
  & npm run qa:browser
  if ($LASTEXITCODE -ne 0) { $failed++ }
} else {
  Write-Warning 'Real browser tests NOT RUN; start a local staging Laravel server and add -RunBrowser.'
}

if ($CheckPilot) {
  Write-Host "`n=== Gate 3: Human pilot sign-off audit ===" -ForegroundColor Cyan
  & python scripts/qa_pilot_gate.py --check
  if ($LASTEXITCODE -ne 0) { $failed++ }
} else {
  Write-Warning 'Human pilot UAT remains NOT RUN; initialize with python scripts/qa_pilot_gate.py --init.'
}

if (!$RunPhpunit -or !$RunBrowser -or !$CheckPilot) {
  Write-Host 'INCOMPLETE: All three gates must be executed to qualify for acceptance. Use -RunPhpunit -RunBrowser -CheckPilot.' -ForegroundColor Yellow
  $failed++
}
if ($failed -ne 0) {
  Write-Host "BLOCKED: $failed check group(s) failed. No production deployment was performed." -ForegroundColor Red
  exit 1
}
Write-Host 'All three test runners completed without reported blockers. Real-user signoffs, backup restore and production approval must still be independently confirmed.' -ForegroundColor Green
exit 0
