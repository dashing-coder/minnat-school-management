# CampusSphere ERP — QA runbook (English)

1. Make a dated backup of the CURRENT Laravel project and MariaDB database, and verify restore can work.
2. Do not share your existing project ZIP externally: it includes `.env` (real APP_KEY) and `.git`.
3. Do **not** import a fresh demo SQL dump or re-run `SmsFullDemoSeeder` against your current database; it has a valid administrator and institution membership. `SmsExtendedDemoSeeder` also explicitly requires a different three-tenant baseline.
4. Open phpMyAdmin, select the intended `scm-system` database, and use its SQL tab to execute `diagnostics/READ_ONLY_DATABASE_CHECKS.sql` in a local development/staging environment. Its queries are SELECT-only.
5. In the actual Laravel project folder run `php artisan config:clear`, `php artisan migrate:status`, `php artisan sms:qa --json`, and `php artisan route:list`. Save output without secrets.
6. Run `php artisan test` on a **separate** configured test database, with PHP extensions `mbstring`, `dom`, `xmlwriter`, `pdo_mysql` (and other Laravel-required extensions) present. Confirm `RefreshDatabase` is not pointed to the working database.
7. Test user roles separately: admin, teacher, accountant, student, parent, and campus-restricted user. Check marks submission, refund approval separation, sensitive exports and tenant isolation.
8. Record results as Pass / Fail / Blocked, retain screenshots/IDs for defects. No production signoff until critical findings are resolved.

Recommended first fix: clean distributable archive, seed compatible DATA in a new isolated test DB, repair/disable dormant API tests, tighten finance/marks/exports, then end-to-end QA.
