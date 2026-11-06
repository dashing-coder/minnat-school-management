# Staging Installation & Rollback Guide (Windows/XAMPP)

## First: preserve the currently working installation

1. Make a copy of your working Laravel folder and keep its `.env` PRIVATE. Do not upload it or place it in a shareable ZIP.
2. Back up your actual `scm-system` MariaDB database from phpMyAdmin (Export > SQL > Custom, structure + data) or using a MariaDB client with `mysqldump --single-transaction` and password prompt. **Confirm** the backup restores into a separate test database before changing working data.
3. Copy the working project and import the backup into a separate **staging database**. Set the staging copy's `.env` to that database. Never run demo seeding against the original production or real-user database.
4. Apply the PATCH-ONLY ZIP by merging its project-relative files into **staging**. Do not replace the working `.env` or overwrite a real database. Back up modified files first.
5. From your staging project directory, with PHP 8.2+ and extensions (`mbstring`, `dom`, `xmlwriter`, `pdo_mysql`, `openssl`, `fileinfo`), run:

```powershell
composer install
php artisan config:clear
php artisan migrate:status
php artisan migrate --pretend
php artisan migrate
php artisan sms:qa
php artisan sms:integrations:check
php artisan route:list --path=api
php artisan test
```

If any command fails, **do not continue to production**. Note that `migrate --pretend` may display generated SQL; manually review proposed schema changes, especially the unique journal source index.

## School-only sample data (optional; local/staging only)

Only when your copied database has **one active `SCHDEMO` institution and no students, employees, exams, invoices, journals or payments**:

1. Set `APP_ENV=local` and `SMS_ALLOW_SCHOOL_DEMO_SEED=true` in **staging `.env`**.
2. Run `php artisan config:clear` and `php artisan db:seed --class=SmsSchoolSafeDemoSeeder`.
3. The seeder is additive, uses a transaction, does not change users/roles/passwords, and aborts if business tables are populated. It creates fictitious school-only records. It **does not** generate a Madrasha/College demo in this existing single-school database.
4. Set `SMS_ALLOW_SCHOOL_DEMO_SEED=false` immediately, then `php artisan config:clear` and `php artisan sms:qa`.

Do not also run `SmsFullDemoSeeder`, `SmsExtendedDemoSeeder` or import the earlier rich SQL dump into this copy.

## Windows QA runner

From the staging project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA.ps1
```

This runs only read-only diagnostics/tests and fails if any check returns nonzero. It does not migrate, deploy or seed.

## Manual UAT requirements

Use `qa/UAT_EXECUTION.csv`: account for institutional admin, teacher, accountant, student and parent roles; test the flows and negative/unauthorized cases. Record screenshots, executor, expected/actual results and sign-off. Pay special attention to refund separation, cross-tenant access, accounting debits/credits, published marks immutability, payroll payout evidence and real restore rehearsal.

## Rollback

- **Before migration:** restore the copied application files and staging database backup.
- **After migration:** if a release fails, restore the complete **pre-release database backup** into the isolated staging environment; reverting only PHP files may break schema compatibility. Coordinate any production rollback with database and app maintenance to avoid lost or duplicated transactions.
- Don't run `migrate:fresh`, `db:wipe` or `migrate:rollback` against a populated installation unless a migration-specific, reviewed rollback plan exists.

## Production go/no-go gate

**BLOCK** unless full PHPUnit suite, role/tenant UAT, student privacy, real ledger reconciliation, tested backup restore, external service credentials/security (if used), TLS, secret management, APP_DEBUG=false, monitoring, incident response and authorized client approval are all documented as passing. Production deployment has not been performed here.
