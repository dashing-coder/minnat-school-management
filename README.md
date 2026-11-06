# CampusSphere SCM — **Working sample data**, not merely empty database tables

This package is tailored to the user's uploaded `minnat-school-management.zip` Laravel project and `scm-system.sql` MariaDB export (126 tables). Their SQL dump had **one school and 38 permissions but zero student/academic/financial records**. The previous source ZIPs did **not** automatically seed their local MariaDB database. That is why modules repeatedly appeared empty.

## DOWNLOAD CONTENTS

- `database/seeders/SmsScmFullSampleSeeder.php` — **recommended**: adds the official 602-record original demo fixture, preserves existing School admin membership and roles, remaps the differing institution/user/role/membership IDs, then runs the included rich extension for 72 additional fictitious students and related records. It changes *only the local demo school administrator* password to `SchoolAdmin@2026` as requested.
- `database/seeders/SmsExtendedDemoSeeder.php` — rich additional records for all three demo institutions.
- `database/seeders/SmsDemoFinancialReferenceRepairSeeder.php` — corrects known fixture accounting references and library/hostel demo statuses.
- `database/seeders/data/sms_demo_fixtures.json` — actual 602-record baseline.
- `database/sql/SCM_FRESH_126_TABLES_WITH_DEMO_DATA.sql` — separate **fresh database only** SQL installer with 126 tables and the baseline 602 demonstration records. Do not import into your existing database. It does not include the 72-user rich extension, which is available via Laravel seeding.
- `verification/VERIFY_SAMPLE_DATA.sql` — read-only SQL checks.

## OPTION A — KEEP YOUR WORKING LOCAL DATABASE (RECOMMENDED)

**1. Back up `scm-system` using phpMyAdmin Export before doing anything.** Only use a copy of your *empty demo* database; never seed an actual school database.

**2. Extract this ZIP.** Copy its `database/seeders` folder into your Laravel project, keeping the folder layout. Do not replace `.env`, other Laravel source files, or the MySQL DB itself. This assumes you've applied the 2026-11-06 release candidate; otherwise copy the bundled companion seeders too (already included).

**3.** In your **local/staging** Laravel `.env` (not production), add these lines (one instance each):

```env
APP_ENV=local
SMS_ALLOW_SCM_FULL_SAMPLE=true
SMS_ALLOW_RICH_DEMO_SEED=true
SMS_ALLOW_DEMO_REPAIR=true
SESSION_DRIVER=file
CACHE_STORE=file
```

Keep your existing DB connection settings, such as `DB_DATABASE=scm-system` and `DB_PORT=3307`, unchanged **only if you are sure this database contains fictional demo data and no real records**.

**4.** In PowerShell/CMD inside the Laravel project directory (the folder with `artisan`):

```powershell
php artisan config:clear
php artisan migrate:status
php artisan db:seed --class=SmsScmFullSampleSeeder
php artisan sms:qa
php artisan sms:finance:reconcile --json
```

You should see populated institutions **SCHDEMO, COLDEMO, MADDEMO**, with **75 students total** if the complete extension runs, invoices, payments, exam marks, attendance and Hifz entries. The seeder refuses a partially populated database and performs a transactional rollback on exceptions. **Do not run the seeder twice.**

**5.** Turn all three `SMS_ALLOW_*` flags back to `false`, run `php artisan config:clear`, and sign out/sign in again.

**Local demonstration administrator:** `admin.school@example.test` / `SchoolAdmin@2026`.

This is intentionally fixed for local demonstration **only**. Immediately change it to a unique strong password before publishing/deploying this application.

## OPTION B — SEPARATE FRESH DEMO DATABASE USING phpMyAdmin (126 TABLES + 602 RECORDS)

This is for users who want a one-click SQL import instead of running the Laravel seeder.

1. Create a **new empty database** such as `scm_demo_fresh` in phpMyAdmin. Do **not** choose your working `scm-system` DB.
2. Select the new DB > Import > `SCM_FRESH_126_TABLES_WITH_DEMO_DATA.sql`.
3. In a **copy** of the Laravel project change only `DB_DATABASE=scm_demo_fresh`, keeping the correct host, port and credentials. Run `php artisan config:clear`.
4. Login with `admin.school@example.test` / `SchoolAdmin@2026`.
5. This SQL contains the initial **602** fixture records (3 students, one per institution), not the expanded 75-student set. **Do not run `SmsScmFullSampleSeeder` after importing this file**: it is exclusively for the empty **single-school** `scm-system` baseline. To enrich the new database, use:

```powershell
# only in a local/staging demo instance:
# .env: APP_ENV=local ; SMS_ALLOW_RICH_DEMO_SEED=true
php artisan config:clear
php artisan db:seed --class=SmsExtendedDemoSeeder
```

This adds 72 fictitious students (75 total) and related records. Disable `SMS_ALLOW_RICH_DEMO_SEED` afterward.

## CHECK THAT YOUR DATA ACTUALLY EXISTS

In **phpMyAdmin > selected DB > SQL**, run `verification/VERIFY_SAMPLE_DATA.sql`. Also verify in Tinker:

```php
DB::connection()->getDatabaseName();
DB::table('institutions')->count();
DB::table('students')->count();
DB::table('student_invoices')->count();
DB::table('exam_marks')->count();
```

If the SQL says 75 students but the dashboard is still empty, the website may be connected to a different database, the wrong institution may be selected, or session/cache config needs clearing. **Do not run the seeders repeatedly**.

## SAFETY & VALIDATION

- No credentials other than the requested school demo login are shared. The fresh SQL uses bcrypt hashes, never plaintext passwords.
- This does not load real student data or access the user's actual local MariaDB database.
- The patch contains only migrations-compatible **seeder assets**, not full replacement source code.
- PHP syntax, fixture/SQL shape, ZIP integrity, and offline foreign-key projection were checked. **Live MySQL import and full Laravel seeding have NOT been run here**; use backup/staging first and report runtime errors if they occur.
