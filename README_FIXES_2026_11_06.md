# CampusSphere School / College / Madrasha Laravel ERP — Staging Hardening Update

This project is a **sanitized source-code update of the user's uploaded `minnat-school-management.zip`**. It targets the uploaded `scm-system.sql` schema but does not include that database, private `.env`, `.git`, `vendor`, SQLite data or logs.

**Start here:** [Fixes and remaining work](docs/release/SCM_FIXES_AND_REMAINING_WORK.md) · [Staging install/rollback](docs/release/STAGING_INSTALL_AND_ROLLBACK.md) · [Manual UAT checklist](qa/UAT_EXECUTION.csv)

**Deliverables in this release:** 20 module definitions, 30 guided workflow definitions (3 newly added), limited same-origin authenticated JSON API, secure CSV restrictions, teacher-assignment check for marks, fail-closed approval checks, a guarded journal source uniqueness migration, additive **SCHDEMO-only** local sample seeder, payroll accounting posting/record-only disbursement, fee plan billing, eight exportable operational reports, improved read-only accounting QA, read-only integration status command, UAT checklist and Windows QA runner.

**No live website deployment was performed.** Production gateway/SMS/biometric connectors, complete payroll deductions, real bank disbursement, full institutional UAT and production approval are NOT complete. This source update is for staging verification, not live deployment.

## Quick QA (run in a backed-up staging copy)

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

The new `SmsSchoolSafeDemoSeeder` can add **fictional school-only records** to a clean, single-SCHDEMO local/staging copy; it does not alter existing credentials or roles. See the staging guide before enabling it.
