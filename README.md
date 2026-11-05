# CampusSphere — Rich Sample Database for Laravel ERP

**Release:** November 5, 2026  
**Compatible with:** The previously delivered CampusSphere expanded Laravel 12 + MySQL 8 source package  
**Scope:** School, College and Madrasha demo institutions; synthetic records only.

This package provides **1,723 additional fictional linked records** to complement the previous **602-record** seed dataset. The combined **fresh demo SQL** contains **2,325 rows across 120 database tables**. Records added cover 41 functional tables, including enrollment, attendance, exams, fees, accounting, payroll drafts, library, stock, hostel, transport and Hifz. It is *sample content*, not an indication that all ERP software functions are complete.

## Choose ONE path — do not mix

### A. RECOMMENDED: Add sample data to your already working Laravel database

Your previous local CampusSphere install used `scm-system` on MySQL port `3307`, and `admin.school@example.test` was working. **Use this additive method.** It does not modify existing user passwords, application code, roles, or existing rows, and never clears the database.

1. **Back up** the working `scm-system` database and Laravel project.
2. Confirm your project has the three demonstration institutions with codes `SCHDEMO`, `COLDEMO`, `MADDEMO` and that the original demo seeder has run. If your database contains actual institutional records or additional institutions, **STOP**; the seeder will refuse to run.
3. Copy `database/seeders/SmsExtendedDemoSeeder.php` into your Laravel project's `database/seeders/` directory. Do **not** replace your existing `.env` or original seeders.
4. In your local `.env`, temporarily add:

```dotenv
APP_ENV=local
SMS_ALLOW_RICH_DEMO_SEED=true
```

5. From PowerShell in the project folder containing `artisan`:

```powershell
php artisan config:clear
php artisan migrate:status
php artisan db:seed --class=SmsExtendedDemoSeeder
```

6. **Remove `SMS_ALLOW_RICH_DEMO_SEED=true`** immediately after seeding (or change it to `false`). Keep your existing `CACHE_STORE=file` and `SESSION_DRIVER=file` settings unchanged.
7. Run `php artisan sms:qa`, then load dashboard and registers. Run the read-only queries from `database/sql/CHECK_RICH_DEMO.sql` using phpMyAdmin if desired.

**Safety guardrails:** Only local/testing environment, explicit opt-in, exact three known demonstration tenant codes, baseline admin present, migrations/tables verified, and no prior `SCH-EX-*`, `COL-EX-*`, `MAD-EX-*` students. All inserts run in one transaction and are rolled back if the seeding fails. Re-running after successful insertion reports that records already exist. The seeder intentionally never accesses or changes `users.password`.

### B. Fresh Laravel installation (new, empty database)

For a **new clean local database only** with the CampusSphere source installed:

```powershell
php artisan migrate
# First, set SMS_ALLOW_DEMO_SEED=true in your local .env
php artisan db:seed --class=SmsFullDemoSeeder
# Disable SMS_ALLOW_DEMO_SEED and enable SMS_ALLOW_RICH_DEMO_SEED=true
php artisan db:seed --class=SmsExtendedDemoSeeder
# Disable SMS_ALLOW_RICH_DEMO_SEED again
```

The base seeder prints strong random login passwords once. The second seeder adds linked data **without changing those passwords**. The `SmsFullDemoSeeder.php` and its JSON fixture are included as a reference in this ZIP; on your existing application, use its own original seeder if present.

### C. phpMyAdmin / standalone MySQL import (ONLY a new empty database)

The ZIP contains `database/sql/SMS_ERP_MYSQL8_FRESH_RICH_DEMO.sql` with 120 `CREATE TABLE` definitions plus 2,325 sample records. Create a **separate new, empty database** (e.g. `campussphere_rich_demo`) and import this file into it.

**Never import the full SQL into your existing `scm-system` database.** It will collide with existing tables and is not a patch. This raw SQL import doesn't populate Laravel's `migrations` table, so **do not** run `php artisan migrate` on the same imported schema. It is intended for database exploration; for a working Laravel application, choose A or B.

Raw SQL users receive bcrypt hashes for unknown random passwords; you will need to set a local password through Laravel if you want to authenticate. Prefer the Laravel seeders instead.

## New sample record summary

| Data group | Additional rows |
|---|---:|
| Students / guardians / relationships / documents / enrollment | 324 |
| Admission applications | 24 |
| Attendance sessions + student attendance | 375 |
| Examinations, papers, marks, results | 150 |
| Finance: fee heads, invoices, lines, payments, allocations, journals and lines | 603 |
| Staff, payroll drafts and attendance | 69 |
| Library (books, copies, loans) | 33 |
| Inventory and stock movement | 27 |
| Hostel (rooms, beds, allocations) | 33 |
| Transport (stops, student assignments) | 18 |
| Donors, donations, scholarship awards and notices | 27 |
| Madrasha Hifz enrollment, progress and assessment | 40 |
| **TOTAL** | **1,723** |

The package includes 24 newly enrolled students per school/college/madrasha (72 in total), five sample attendance days per institution, varied absence/late statuses, one extra 100-mark exam per institution, paid/partially paid/unpaid tuition invoices, balanced invoice/payment ledger journals, draft payroll, inventory movements, and Hifz progress for 8 fictional students.

**Financial demo behavior:** Sample tuition invoices use their own fee head and generate balanced posted journal entries, with allocated payments equal to invoice paid totals. Draft payroll, scholarship awards, donation receipts, and boarding/transport fees do **not** automatically post extra general-ledger transactions; those accounting workflows need separate application QA.

## Included files

- `database/seeders/SmsExtendedDemoSeeder.php` — **additive** seeder for the already-populated demo database.
- `database/seeders/SmsFullDemoSeeder.php` — original baseline full seeder (reference for fresh installs).
- `database/seeders/data/sms_demo_fixtures.json` — original 602-row baseline JSON (reference).
- `database/sql/SMS_ERP_MYSQL8_FRESH_RICH_DEMO.sql` — **fresh empty database only**, schema + rich data.
- `database/sql/CHECK_RICH_DEMO.sql` — read-only dashboard/finance/relationship verification queries.
- `docs/SAMPLE_DATA_PREVIEW.json` — representative sample rows (no passwords).
- `docs/OFFLINE_VALIDATION_REPORT.json` — offline referential, key, money and stock checks.
- `docs/ROW_COUNTS.json` — table-wise row counts in the fresh rich example.
- `docs/INSTALLATION_BANGLA.md` — বাংলা ইনস্টলেশন গাইড।

## Verification performed and limitations

The seeder passed PHP 8.4 syntax validation, and an **offline mocked seeder run** generated 1,723 added rows. The assembled dataset passed duplicate-key checks, **262 MySQL foreign-key definitions**, invoice/payment allocation reconciliation, journal balance checks, library/hostel status checks, stock non-negativity, and payroll arithmetic. ZIP integrity is checked at packaging time.

**Actual `php artisan db:seed` execution in Laravel/MySQL and browser QA were NOT performed in this environment.** Make a database backup, apply to your local demo only, and review the command output before relying on the records. No real student names, phone numbers, email addresses or financial accounts are supplied.
