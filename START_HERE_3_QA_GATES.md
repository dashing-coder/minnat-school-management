# CampusSphere ERP — Runtime, Browser and Pilot QA Pack

Created from the **Nov 9 Laravel staging package**; to be merged into an isolated staging copy, **not over the working production database**.

## What's addressed

- **Runtime QA:** effective Laravel/MySQL staging configuration preflight; added disposable MySQL PHPUnit HTTP journey tests; updated CI job to run migrations, PHPUnit, seed fictional school records and exercise browser smoke checks. Staging QA runner no longer wrongly fails solely because production go-live checks cannot pass in `APP_ENV=local`.
- **Browser QA:** Playwright Chromium browser tests for desktop, tablet, mobile, login, institution selection, students, admissions, academics, finance and UI/keyboard behavior. Authentication state and QA results are ignored by Git.
- **Human Pilot UAT:** 22 evidence-ready scenarios, role-based sign-off template, and a fail-closed Python approval checker. Real testers must perform the tests and sign off.

## Mandatory next step on your local Windows PC

Read [`docs/qa/THREE_GATE_EXECUTION_NOV09.md`](docs/qa/THREE_GATE_EXECUTION_NOV09.md) (or [`docs/qa/BANGLA_THREE_GATE_GUIDE.md`](docs/qa/BANGLA_THREE_GATE_GUIDE.md)) and use **a separate staging project and database**. Configure a second disposable database named `campussphere_test` for PHPUnit. The protected working `scm-system` DB must never be used for `RefreshDatabase`.

```powershell
# Must be executed in staging Laravel root, with Composer dependencies already installed
php scripts/qa_runtime_preflight.php --mode=staging
powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1 -RunDatabaseTests

# Browser tests: start staging with php artisan serve --port=8001 in a separate window
npm install
npx playwright install chromium
$env:QA_BASE_URL='http://127.0.0.1:8001'
$env:QA_ADMIN_EMAIL='admin.school@example.test'
$env:QA_ADMIN_PASSWORD='SchoolAdmin@2026'
npm run qa:browser

# Human sign-off is a separate gate
python scripts/qa_pilot_gate.py --init
python scripts/qa_pilot_gate.py --check
```

**No actual local Windows database, live browser, or human pilot was available to this package execution environment.** Check statuses in `docs/qa/THREE_GATE_VALIDATION_REPORT.json`. Do not label these pending gates as completed. Fixed demo credentials are *only* appropriate for local fictitious sample data and must be changed before production.
