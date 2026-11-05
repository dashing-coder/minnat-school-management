# CampusSphere — Laravel School, College & Madrasha ERP

**Expanded Laravel application source package · November 5, 2026**

> **Development release, NOT a fully completed/verified production ERP.** The package implements a substantial number of authenticated screens and core workflows, but it has not been executed against a live MySQL/Laravel installation in this packaging environment. Do not use with real student, health, payroll, donor or financial records until all relevant security and acceptance tests pass.

## Technology & delivery

- Laravel 12 / PHP 8.2+, MySQL 8+, Blade, responsive CSS, vanilla JS.
- 20 module interfaces; 50 explicitly approved master-data registers support create/edit, while the remaining high-risk transactional registers remain read-only.
- **27 explicit operational workflows**, including admissions and offers, enrollment/promotion, conflict-aware timetable creation, marks and result publishing, fees with balanced ledger journals, payments, requested/approved refunds, basic bank matching, draft payroll, library loans, Hifz progress, inventory movements, donor receipts, certificate issuance, hostel/transport assignments and leave management.
- Eight operational reports, read-only certificate authenticity check, and local-only user provisioning and role assignment.
- 120 MySQL tables defined via existing migrations, fictional sample records for three institutions, read-only QA command, source/logic tests and offline static validation.
- Dependencies are **not bundled** (no `vendor/`). Run `composer install` to obtain Laravel packages on your own computer.

**What remains unfinished:** student application uploads, payments via live gateways, SMS/WhatsApp, biometric/RFID device sync, full HR payroll benefits/tax/disbursement, comprehensive LMS, rich guardian/student mobile portals, fully automated fee plans, government board integrations, internationalization, formal fund accounting restrictions, complete reconciliation/closing controls, multi-branch edge cases, and full system/browser/production QA. See `docs/PHASE_COMPLETION_MATRIX.md`.

## Fresh Windows installation

1. Install PHP 8.2+ and Composer, MySQL 8+, and ensure the PHP MySQL/PDO, OpenSSL, mbstring, XML and required Laravel extensions are enabled.
2. Extract ZIP and open PowerShell in the directory with `artisan` and `composer.json`.
3. Create a fresh, empty MySQL database, for example `campussphere_local`.
4. Run:

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
```

5. Edit `.env`. Set `APP_ENV=local`, correct `DB_HOST`, `DB_PORT` (your local setup used **3307**), `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `CACHE_STORE=file`, `SESSION_DRIVER=file`, `QUEUE_CONNECTION=sync`.
6. Run migrations and only then seed the empty database:

```powershell
php artisan migrate
# Before seeding, set SMS_ALLOW_DEMO_SEED=true in .env
php artisan db:seed --class=SmsFullDemoSeeder
# Save the randomly generated account passwords printed ONCE.
# Then set SMS_ALLOW_DEMO_SEED=false again.
php artisan serve
```

7. Open `http://127.0.0.1:8000/login`. Use the demo school administrator email `admin.school@example.test` and the password **printed by your own seeder**.

**Important:** The sample passwords are random; there is no default admin password. Never combine raw SQL imports with Laravel migrations/seeders in the same database.

## Safest upgrade of your **already working** Laravel site

You previously reported successful login and file-based sessions/cache. **Do not overwrite that working installation or its `.env`**. Use the separate `CampusSphere_ERP_Expanded_PATCH_ONLY.zip` containing only the changed source and documentation.

1. Back up **all** project files and your MySQL database.
2. Extract the patch elsewhere; compare its changed files to yours and merge any existing customizations.
3. Leave your existing `.env` intact, including `CACHE_STORE=file` and `SESSION_DRIVER=file`.
4. These application changes do not intentionally run database resets; apply them to the existing schema from the prior CampusSphere project.
5. Clear config and inspect runtime data:

```powershell
php artisan config:clear
php artisan migrate:status
php artisan sms:qa
php artisan route:list
php artisan test
```

6. Optional **demo-only reference correction** for old fictional seed data (see below) if testing fee invoicing, library return or hostel assignments.
7. Restart `php artisan serve` and test every workflow against a database copy before using the real installation.

### Opt-in repair of old local demonstration fixtures

Old demo data accidentally marked the student receivables account inactive, linked fee heads to receivables rather than income, linked bank accounts to receivables, and used inconsistent occupied/issued statuses. The **new fixture JSON** corrects these for fresh installations. For existing **fictional demo** databases only, you may opt in to a repair:

```powershell
# Only on local fake demo data; back up the database first.
# In .env set SMS_ALLOW_DEMO_REPAIR=true, then:
php artisan db:seed --class=SmsDemoFinancialReferenceRepairSeeder
# Remove SMS_ALLOW_DEMO_REPAIR=true after completion.
```

**DO NOT run this repair against real institutional records.** It is guarded by `APP_ENV=local|testing` and the explicit opt-in flag.

## QA and trust boundary

- Run `python qa/validate_package.py` for offline syntax, schema mappings and fictional fixture assertions.
- Run `php artisan sms:qa` and `php artisan test` within a functioning Laravel/MySQL installation.
- The source package's static QA does **not** establish that the full app starts, that new migrations run, that payment/report flows reconcile under load, or that tenant authorization survives adversarial testing.
- Master-data CRUD requires an explicit allowlist and permission checks; published grades, ledger lines, audit logs and payments cannot be edited through generic register forms.
- Financial workflows are simplified. Verify Chart of Accounts mapping; account references, refund controls, and transactions using realistic test cases before production.
- Public certificate verification shares only limited metadata and uses randomized token URLs. Authentication still requires further security and privacy audit.

## Guides

- `docs/PHASE_COMPLETION_MATRIX.md` — 18-phase implementation/validation status
- `docs/FEATURE_STATUS.md` — previous baseline feature inventory
- `docs/OPERATIONS_GUIDE.md` — guided operations and permissions
- `docs/INSTALLATION_BANGLA.md` — previous Bangla setup guide
- `docs/QA_AUDIT_REPORT.md` — prior QA source review
- `qa/OFFLINE_EXPANDED_VALIDATION.json` — this release's source verification

The old standalone SQL snapshots under `database/sql/` were produced for an earlier demo and are **not** the recommended Laravel installation method; they may not match the corrected fixture JSON. Prefer migrations + the guarded Laravel seeder on a blank database.
