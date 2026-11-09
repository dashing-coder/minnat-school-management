# CampusSphere — Final Functional QA & UI/UX Improvement Release (2026-11-06)

This is a **staging-only source update**, NOT a completed production certification. Built on the latest CampusSphere November 6 Laravel release candidate, based on the user's original `minnat-school-management.zip` / `scm-system.sql` audit.

## Changes

- Accessible responsive navigation: skip link, ARIA state, overlay, Escape-to-close, keyboard focus management, permitted-module search.
- Dashboard: progressbar semantics, improved contrast and responsive stat cards.
- Student directory: labeled search, clear filter, accessible table and empty state.
- Student & workflow editors: explicit labels, error announcements, double-submit prevention.
- Attendance: choose a real open session, search actual enrolled students by name/admission number; server validates institution, active enrollment, active session and writes an audit event. Student IDs no longer need to be typed manually.
- Critical **test database protection**: `Tests\TestCase` refuses to boot if database name does not clearly indicate a test/CI database. `RefreshDatabase` can otherwise wipe operational rows.
- New Laravel feature tests for student lifecycle, permitted attendance and forbidden access; a 38-case manual QA/UAT matrix.

## INSTALLATION — preserve your working database and demo login

**Use a backup/staging copy, not your functioning production/local primary app.** The patch contains no SQL export, no .env, no password reset and no seeding commands. It **will not modify your existing data** unless you manually run application workflows.

1. Back up the source tree and the database. Clone to a separate staging folder and use a separately named staging database.
2. Apply the PATCH ZIP retaining the folder layout, or use the full clean source package for a fresh staging tree.
3. Keep your original `.env` on your existing installation; configure staging separately. This update does not change `admin.school@example.test` or `SchoolAdmin@2026` local-demo credentials.
4. `php artisan config:clear` then `php artisan view:clear` in staging.
5. `php scripts/qa_ui_source.php` — safe, no DB access; `php -l` on changed files.
6. Load dashboard, student directory, and `/attendance/mark` on desktop/tablet/mobile. Run manual items in `qa/FINAL_FUNCTIONAL_UX_CHECKLIST.csv`.

### FULL Laravel automated tests — DANGER: use a DIFFERENT database

Never run `php artisan test` against `scm-system` or any live database. Tests using `RefreshDatabase` destroy and recreate tables. The patch adds a runtime guard to reject database names without an explicit `_test`, `_testing` or `_ci` suffix.

Create an **empty** database named `campussphere_test` (not a copy of live records). In the **staging** project root add `.env.testing` with:

```ini
APP_ENV=testing
APP_KEY=base64:REPLACE_WITH_GENERATED_TEST_APP_KEY
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3307
DB_DATABASE=campussphere_test
DB_USERNAME=root
DB_PASSWORD=
SESSION_DRIVER=array
CACHE_STORE=array
QUEUE_CONNECTION=sync
```

Use your actual local DB username/password in `.env.testing`. Generate a separate testing key using `php artisan key:generate --show` and put it into this file. Run `php artisan config:clear` and then `php artisan test` **only after verifying the DB target**, e.g. `php artisan about --env=testing` and `php artisan tinker --env=testing` → `DB::connection()->getDatabaseName()` must say `campussphere_test`.

### Run integration checks (read-only) on STAGING

```bash
php artisan sms:qa
php artisan sms:finance:reconcile --json
php artisan sms:integrations:check
php artisan route:list
```

## Test scope & limitations

Offline PHP syntax/source checks can be done here. Composer/vendor dependencies and PDO MySQL are not present in this environment; we **did not run the Laravel suite or browser/mobile tests**. The 38-case checklist includes items that require human testers, real integrations, backups, finance approval and production credentials. All are UNTESTED until signed off. A working local demo does not itself constitute a production-ready ERP.

Note: fixed demonstration credentials must NEVER be used in production. Do not ship `.env` or private keys.
