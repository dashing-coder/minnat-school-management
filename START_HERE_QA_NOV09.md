# CampusSphere ERP — QA Stage Update (November 9, 2026)

This package advances the **testing and sample-data reconciliation** stage. It is **not** a production-ready certification or a live MySQL test result.

- **Full source**: Laravel project baseline updated with offline QA tools, tests, and corrected *future fresh-seeding* demo fixtures.
- **Patch only**: the five changed source/test files plus QA documentation and evidence. Merge only into a **backed-up staging copy** of the ERP. Do **not** replace your `.env` file or import a fresh SQL dump over your functioning database.
- **Do not re-run `SmsFullDemoSeeder` on existing records**. It refuses an already populated database; fixture corrections affect only *new, empty demo databases*.
- Local demo admin credentials requested by user: `admin.school@example.test` / `SchoolAdmin@2026`. Use a different secret in production.

## Run dependency-free checks now

```powershell
php scripts/qa_demo_fixture.php
php scripts/qa_ui_source.php
php qa/offline_smoke.php
```

## Execute read-only staging checks

Only after cloning the current database into a separately named staging DB, then configuring staging `.env`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1
```

Automated feature tests require a **third, disposable** local database with `_test` in its name. After confirming `.env.testing` and `phpunit.xml` match, run the same command with `-RunDatabaseTests`. These tests may reset tables in the `_test` database.

See `docs/qa/QA_PROGRESS_2026_11_09.md` for evidence, hard blockers, UAT instructions and acceptance gates.
