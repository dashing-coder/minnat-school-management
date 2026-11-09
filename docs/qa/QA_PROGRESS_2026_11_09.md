# CampusSphere ERP — Functional QA Progress and Staging Acceptance Plan
**Date:** November 9, 2026  
**Scope:** Laravel 12 application; 20 ERP modules; 32 declared guided workflows  
**Basis:** Latest available `CampusSphere_ERP_UIUX_Final_QA_Staging_Source_2026-11-06.zip` and bundled demo fixtures; uploaded `scm-system.sql` is an older pre-seeding snapshot and not a current live database export.

## Results completed in this environment

| Evidence | Result | What the result does NOT prove |
|---|---|---|
| PHP syntax checks (`php -l`) | 99/99 files passed | Laravel controllers are functionally correct |
| UI source checks | 10/10 passed | UI works in live desktop/mobile browsers |
| Bundled fixture audit | 12/12 passed after targeted fixture corrections | The **user's** currently running database is reconciled |
| PHP helper smoke checks | Passed | Payment, payroll, SMS, and biometric end-to-end integration |
| Defined module catalog | 20 modules | All module workflows complete |
| Defined workflow catalog | 32 workflow definitions | Each workflow passes business-user UAT |
| Laravel PHPUnit / MySQL functional suite | NOT EXECUTED | Requires a separate MySQL/MariaDB staging and dedicated test database |
| Browser responsive & accessibility QA | NOT EXECUTED | Requires real browser/device verification |
| Backup/restore drill, pilot UAT, production launch | NOT EXECUTED | Cannot be done without access/authorization to external systems |

### Concrete fixture issues found and corrected (fresh demo seeds only)

1. College and Madrasha sample `exam_papers.full_marks` were **0.00** despite positive marks (91 and 83); set both paper maxima to 100 and pass marks to 33.
2. Two demo `exam_marks.status` values were `active`, which is not the approval state used by the result workflow; corrected to `approved`. Their result records remain **draft** unless results are published.
3. Baseline School demo payslip had a 1,000 deduction on the header but no matching deduction item. Added a fictional withholding-liability chart-of-accounts entry and matching 1,000 deduction item.
4. Three baseline payments were marked `active` despite having corresponding posted payment journals; updated to `posted` to align with reconciliation logic.
5. Non-school demo payroll runs/payslips were marked `active` instead of the expected `draft`; aligned their fixture state to `draft`.
6. `SmsFullDemoSeeder` now respects the *local demo-only* school administrator credentials explicitly requested by the user. It does **not** alter any existing login; all other demo accounts still have randomly generated passwords.

All modifications to fixtures and seeders affect only **future fresh demonstration database seeding**. **DO NOT** rerun `SmsFullDemoSeeder` on an existing populated database. This update does not modify the user's currently working MySQL database or known admin login.

## Run live staging QA safely (Windows)

1. Back up the working Laravel source and database; create a **separate** staging project directory.
2. Import a **copy** of the working database into a separate database, such as `campussphere_staging`. Update the staging project's `.env` to point ONLY to this database (retain existing DB_HOST and DB_PORT, if local MySQL uses 3307). Keep `CACHE_STORE=file` and `SESSION_DRIVER=file`.
3. Merge the patch into the staging project (only the specified files; DO NOT overwrite `.env`, `vendor/`, or the live SQL database).
4. Open PowerShell in the staging root. Run read-only QA:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1
   ```

   The script refuses to run unless `.env` has a **staging/test-named** database. Some checks (notably the production readiness gate) may intentionally report incomplete sign-offs as failures; document these as release blockers.

5. For tests that use `RefreshDatabase`, create a **separate, disposable** local MySQL database named `campussphere_test`, copy staging `.env` to `.env.testing`, and set `APP_ENV=testing`, `DB_CONNECTION=mysql`, `DB_HOST=127.0.0.1`, `DB_DATABASE=campussphere_test`. Confirm `phpunit.xml` uses this identical test database. These tests may **DROP/RECREATE DATA IN `campussphere_test`**. Never point the test database at `scm-system` or `campussphere_staging`.
6. Then run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1 -RunDatabaseTests
   ```

7. Execute `qa/FINAL_FUNCTIONAL_UX_CHECKLIST.csv` manually using administrator, teacher, parent/student, accountant, and a campus-restricted account. Record evidence, tester, date, and results.
8. Perform an isolated backup-and-restore drill against a **disposable** database, not the working ERP. Pilot users must sign off before production.

## Required promotion gates

- No unresolved P0 security or data-loss findings; institution/campus isolation demonstrated with actual accounts.
- All MySQL-backed feature tests passed against a dedicated testing database; rejected or flaky cases triaged.
- Fee payments, refunds, invoice allocations, general ledger, and payroll liabilities reconciled.
- Backup restoration validated with row counts and sample record checks; rollback tested.
- Mobile navigation, keyboard access, layouts, attendance, exams, reporting and specialized modules checked in a real browser.
- External integrations remain **simulators** until verified against provider sandboxes, with real credentials stored outside source control.
- School, College, and Madrasha pilot representatives sign the acceptance log; production release has explicit authorization.

## Local demo credentials policy

For **local testing only**: `admin.school@example.test` / `SchoolAdmin@2026`. Do not use a shared fixed password in production; change it to a unique secret and enable appropriate security controls before external access.

## Limits

This environment has PHP CLI but lacks required PDO MySQL, mbstring, XML/DOM and Composer tooling; it cannot connect to the user's Windows MySQL server at `127.0.0.1:3307` or operate a browser against that localhost site. Consequently, a complete live QA pass, user acceptance and production deployment must remain **not verified / not performed**, irrespective of offline checks.
