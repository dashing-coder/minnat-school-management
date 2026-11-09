# CampusSphere ERP — Three Pending QA Gates (Executable Verification Pack)

**Scope:** Laravel 12 / MySQL–MariaDB; the supplied CampusSphere Nov 9 staging source and 20 planned ERP modules.  
**Purpose:** Make the pending runtime, browser, and human pilot checks executable with traceable evidence.  
**Important distinction:** Preparing a test and running a test are different. Neither a simulated browser nor a blank UAT checklist is evidence of a live pass.

## Gate 1 — Laravel / MySQL Runtime

Before beginning, **back up the working website and database**. Do not test against `scm-system`. Prepare two **separate** database copies:

- `campussphere_staging`: copy with fictional demo data for read-only runtime and browser checks.
- `campussphere_test`: disposable empty database for PHPUnit `RefreshDatabase`; its tables will be recreated.

The staging Laravel project must use its own `.env`, which points to `campussphere_staging` at your actual MariaDB host/port (previously `127.0.0.1:3307`). Use `APP_ENV=local`, `CACHE_STORE=file`, and `SESSION_DRIVER=file` on staging. Preserve your working installation and existing credentials.

Create `.env.testing` in the staging project with `APP_ENV=testing`, `DB_CONNECTION=mysql`, `DB_HOST=127.0.0.1`, your local `DB_PORT`, `DB_DATABASE=campussphere_test`, and the corresponding DB credentials. `phpunit.xml` also references `campussphere_test`. **Never use the production database as a testing target.**

From Windows PowerShell in the **staging project root**:

```powershell
composer install
php artisan config:clear
php scripts/qa_runtime_preflight.php --mode=staging
php artisan migrate:status
php artisan sms:qa
php artisan sms:finance:reconcile --json
php artisan sms:integrations:check
php artisan route:list --path=api
```

**Only after** verifying the separate disposable `campussphere_test` connection, execute:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1 -RunDatabaseTests
```

The existing safe runner checks `.env.testing`, the database name, the local host, and `phpunit.xml`. `RefreshDatabase` may create/drop **only** disposable test-database tables. The runtime preflight reads **effective Laravel configuration**, not just raw `.env` text. Gate 1 passes only if MySQL connects, migrations are consistent, mandatory tests pass, and financial/tenant checks show no uninvestigated discrepancies. An empty dataset does **not** establish successful financial reconciliation.

## Gate 2 — Real browser functional checks

On the same isolated staging project and **after it contains demo records**:

```powershell
php artisan serve --host=127.0.0.1 --port=8001
```

Open a **second** PowerShell window from the same project root:

```powershell
npm install
npx playwright install chromium
$env:QA_BASE_URL = 'http://127.0.0.1:8001'
$env:QA_ADMIN_EMAIL = 'admin.school@example.test'
$env:QA_ADMIN_PASSWORD = 'SchoolAdmin@2026'  # LOCAL/FAKE demo only
npm run qa:browser
```

The browser suite tests real Chromium rendering and navigation at **desktop, tablet, and mobile sizes**: guest redirects; admin login; selected institution; authorized dashboard; student directory/search; admissions, academics and finance pages; keyboard navigation; sidebar filtering; mobile drawer; and global overflow. It **never writes students, money, grades or payroll**. The login setup creates a private authenticated cookie file under `qa/.auth/`; remove this folder when finished. That folder and `qa-results/` are gitignored; never share their contents publicly.

If browser tests fail, inspect `qa-results/browser-results.json`, fix the failing application page or permission/fixture issue, and rerun. The suite has no external browser access to your local Windows instance from this response.

## Gate 3 — Human pilot UAT

Create a fresh evidence checklist:

```powershell
python scripts/qa_pilot_gate.py --init
```

Invite actual authorized **School Admin, Teacher, Admissions Officer, Accountant, HR/Payroll Officer, Parent/Student, Security Reviewer, IT/Operations** testers to exercise the **22 cases** in `qa-results/pilot/cases.csv` using the *staging system* and separate role accounts. Record status, evidence reference, tester, date and any defect. Do **not** give all roles the school administrator password. An authorized responsible party must then complete `qa-results/pilot/signoff.json` with per-role signoff, actual restore drill, P0 defect count, security review and approval.

Check the evidence gate:

```powershell
python scripts/qa_pilot_gate.py --check
```

The gate correctly returns `BLOCKED` until real people execute and sign off the tests. Filling the CSV or JSON with fabricated evidence does not constitute approval. **No live pilot can be completed by code alone.**

## One-command local staging audit

The optional PowerShell wrapper verifies runtime, and can additionally run PHPUnit, browser QA and inspect pilot evidence:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Run-Final-ThreeGate-QA.ps1 -RunPhpunit -RunBrowser -CheckPilot
```

It does **not** seed, migrate, deploy or run an external payment/SMS/biometric transaction. Do not run this against the working ERP. A failed or missing gate blocks the production release.

## Gate status at preparation time

| Gate | Artifact created | Verification completed in this package environment | Required to mark PASS |
|---|---|---|---|
| Laravel/MySQL runtime | Effective-config preflight, PHPUnit HTTP journey tests, safe wrapper, CI recipe | PHP syntax/source checks only; unavailable Laravel extensions/dependencies and no local staging DB | Execute & pass commands against Windows staging + disposable test DB |
| Browser functional | Playwright Chromium tests for desktop/tablet/mobile + CI workflow | JS syntax checks only; container blocks browser navigation, and Windows staging URL is not reachable here | Pass actual Chromium session on `127.0.0.1:8001`, review failures |
| Pilot UAT | 22-role case checklist, signoff template, fail-closed evidence checker | UAT gate tested in synthetic blocked-state scenarios; no actual human pilot | Signed, evidence-backed pass by authorized school staff |

**Do not mark the system production-ready before all three gates pass, plus an independently verified database restore, payment/SMS/biometric provider sandbox checks when applicable, and management approval.**
