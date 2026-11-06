# CampusSphere School / College / Madrasha ERP — Actual Source & Database QA Audit

**Audit date:** 6 November 2026  
**Source received:** `minnat-school-management.zip` (uploaded project ZIP)  
**Database received:** `scm-system.sql` (phpMyAdmin export of `scm-system`)  
**Audit mode:** Offline / read-only source and SQL export inspection; **not a live Laravel/MySQL or browser acceptance test**.

## 1. Executive determination

**Development-stage application; not production-ready.** The PHP project includes a usable Laravel 12 application scaffold, permission-scoped module views and a set of explicit workflows. The uploaded SQL export, however, contains **no student or school-operational data**. The original Laravel code is not modified by this QA deliverable, and the original database is not overwritten.

**What was actually verified:** ZIP inventory; source structure; SQL CREATE/INSERT statements; database schema-to-migration table names; the module/workflow/editable register catalogs; 71 PHP file syntax checks; basic isolated `SmsMoney` conversion examples.  
**What was not verified:** working web pages, credentials, live MySQL queries, executing database migrations or seeders, passing the Laravel PHPUnit suite, cross-tenant behavior under a real database, production integrations, UAT and deployment.

## 2. Evidence inventory

| Item | Observed |
|---|---|
| ZIP source | Laravel Framework version **12.71.0** installed in supplied `vendor` |
| PHP framework requirement | PHP `^8.2` (`composer.json`) |
| Current database export | `scm-system`, MariaDB **10.4.32**, exported 5 November 2026 |
| SQL tables | **126** |
| SQL CREATE tables represented in migration files | **125**; the 126th is Laravel's self-managed `migrations` table |
| Tables with INSERT rows | **8** |
| Tables without inserted records | **118** |
| Total SQL inserted rows | **94** (includes permissions, users, migration metadata) |
| Institutions | **1** (`SCHDEMO`, Sunrise Model School, active) |
| Users | **8** (includes `admin.school@example.test`); passwords are hashes and are not reprinted |
| Institution memberships | **1**, active administrator membership |
| Permission definitions | **38** |
| Institution role-permission assignments | **38** |
| Laravel migration entries in dump | **6** |
| Navigation module definitions | **20** |
| Registered module data tables | **111** |
| Editable master-data registers | **50** |
| Explicit guided workflow definitions | **27** |
| Read-only report definitions | **8** |
| Blade view templates | **17** |
| PHP lint | **71/71 pass** (directories: `app`, `bootstrap`, `config`, `database`, `routes`, `tests`) |
| PHPUnit and web route-list runtime | **Blocked by missing PHP extensions in audit container**; no pass/fail conclusions on application behavior |
| Supplied project ZIP configuration | Contains `.env` and `.git` folders — exclude from any distribution |
| File-based local cache/sessions | `.env` records `CACHE_STORE=file` and `SESSION_DRIVER=file` |
| Sessions DB table | Not present in this SQL dump (file sessions avoid that dependency) |

### Actual data found in SQL

| `institution_memberships` | 1 |
| `institution_role_permissions` | 38 |
| `institution_roles` | 1 |
| `institutions` | 1 |
| `membership_roles` | 1 |
| `migrations` | 6 |
| `sms_permissions` | 38 |
| `users` | 8 |

**Crucial:** No `INSERT INTO students`, `enrollments`, `student_attendance`, `exam_marks`, `student_invoices`, `student_payments`, `ledger_journals`, `ledger_lines`, or `employees` occurs in the supplied SQL. This is a statement about this **specific database export**, not proof that the application cannot create those records later.

## 3. All 20 ERP modules — source coverage vs execution status

The first number shows schema presence. `Has data` counts populated module tables, not record totals. A database table or a form is not proof of a complete or functional module.

| Module | SQL tables | Has data (tables) | Basic editable registers | Guided flows | Reports | End-to-end QA |
|---|---:|---:|---:|---:|---:|---|
| Students & SIS | 4/4 | 0 | 1 | 0 | 0 | Not executed |
| Admissions | 3/3 | 0 | 1 | 3 | 0 | Not executed |
| Academics & LMS | 15/15 | 0 | 11 | 1 | 0 | Not executed |
| Attendance | 3/3 | 0 | 0 | 2 | 1 | Not executed |
| Exams & Results | 7/7 | 0 | 4 | 2 | 1 | Not executed |
| Fees & Accounting | 16/16 | 0 | 6 | 5 | 2 | Not executed |
| Teachers & HR | 7/7 | 0 | 2 | 4 | 1 | Not executed |
| Communication | 5/5 | 0 | 2 | 0 | 0 | Not executed |
| Library | 3/3 | 0 | 2 | 2 | 0 | Not executed |
| Hostel & Transport | 10/10 | 0 | 7 | 2 | 0 | Not executed |
| Inventory & Assets | 7/7 | 0 | 3 | 1 | 1 | Not executed |
| Security & Analytics | 4/4 | 2 | 0 | 0 | 0 | Not executed |
| Institutions & Campuses | 3/3 | 0 | 2 | 0 | 0 | Not executed |
| Academic Lifecycle | 4/4 | 0 | 0 | 2 | 0 | Not executed |
| Hifz & Madrasha | 4/4 | 0 | 2 | 1 | 1 | Not executed |
| Scholarships & Donations | 6/6 | 0 | 3 | 1 | 1 | Not executed |
| Student Welfare | 3/3 | 0 | 0 | 0 | 0 | Not executed |
| Certificates | 2/2 | 0 | 1 | 1 | 0 | Not executed |
| Campus & Events | 3/3 | 0 | 3 | 0 | 0 | Not executed |
| Integrations | 2/2 | 0 | 0 | 0 | 0 | Not executed |

## 4. Prioritized findings and fixes

| Severity | ID | Finding | Recommended action |
|---|---|---|---|
| **P0** | SEC-001 | Project ZIP bundles a populated .env file | Rebuild clean deployment archives excluding .env, .git, logs, local backups and private assets; assess credential rotation if the archive was shared outside trusted developers. Do not rotate APP_KEY in production without an encrypted-data impact plan. |
| **P0** | DATA-001 | Business records absent from uploaded database | Create a fresh isolated demo database and run initial seeders there. Do not import a full demo dump into this working database. |
| **P0** | DATA-002 | Provided demo seeders do not fit the existing database | Use a clean empty database for the 3-institution demo; for the current school build a specially reviewed additive school-only seeder. Do not force-run or disable seeder safeguards. |
| **P0** | API-001 | API routes and API tests are not executable as delivered | Either remove/defer the unused API tests or properly install/configure Sanctum, register API routes and create a real isolated-database test suite. |
| **P1** | FIN-001 | Ledger transaction idempotency has a concurrency gap | Add a unique source-reference constraint after auditing existing duplicates; add concurrency tests with two simultaneous payment requests. |
| **P1** | EXAM-001 | Teacher subject authorization is not enforced in marks workflow | Require assigned teacher or specific privileged academic-override permission; test unauthorized teacher access. |
| **P1** | PRIV-001 | Generic export/read access exceeds least privilege for sensitive data | Add table-specific authorization and vetted export allowlists; explicitly protect health, incident, contacts, payroll, documents and audit records. |
| **P1** | APPROVAL-001 | Approval separation can fall back to permissive behavior if audit record is absent | Persist requested_by/approved_by columns or immutable approver records; reject when originator cannot be verified. |
| **P1** | ACC-001 | Accounting workflows are only partial | Add validated accounting period workflow, recurring fee engine, payroll liabilities/disbursement, bank statement line matching, cashbook and reconciliation integration tests. |
| **P1** | MIG-001 | Stated production target differs from exported database engine | Run migrations and workflow tests on the actual production-intended database version; preserve the MariaDB version when restoring this export. |
| **P1** | QA-001 | Full runtime regression and security tests not demonstrated | Run php artisan test, sms:qa and role-based acceptance tests on a local/staging PHP 8.2+ installation with required extensions. |
| **P2** | CACHE-001 | Database session table absent in supplied dump | Keep SESSION_DRIVER=file for local use; if switching to database sessions, create the sessions migration and test restore and deployment. |
| **P2** | FEATURE-001 | Module screens are not equivalent to complete workflows | Close each workflow with data setup, success/failure cases, role checks, integration tests, and sign-off evidence. |

### Issue clarification

- **API tests are disconnected from the currently bootstrapped application.** The application boots `routes/web.php`; `routes/sms_api.php` is present, but no `routes/api.php` is registered, and the installed Composer lock does not include Laravel Sanctum. The class `TenantIsolationTest` calls `Sanctum::actingAs`. These issues must be resolved before treating tenant API security tests as executable.
- **Database schema coverage is sound but runtime parity is unproven.** All 125 explicit application table names in the Laravel migration files are present in the uploaded SQL dump. This does not establish column/index equivalence, migration replay success, or correctness of data relationships under load.
- **Operational seeding requires a different strategy.** `SmsFullDemoSeeder` explicitly refuses non-empty users/institutions; `SmsExtendedDemoSeeder` requires all three demo institutions and baseline students. Do not bypass these guards on the current live local school database.
- **Transaction safety must be tested under concurrency.** Journals have a unique `journal_no`, but no source transaction uniqueness constraint. Tests must include duplicated/parallel callbacks and replayed requests.
- **Approval controls must fail closed.** Missing originator audit rows must not allow self-approval of payroll or refunds.
- **Sensitive exports require finer authorization.** Default module permissions expose all their listed tables; CSV filtering based on keyword matching is not equivalent to an approved export/field-level privacy policy.

## 5. Remediation order and acceptance gates

**Gate A — Preserve and isolate:** Back up the current working project and SQL. Treat uploaded `.env` as confidential. Build clean source distributions; exclude `.git`, local sessions/logs, and real credentials.

**Gate B — Establish repeatable data:** Set up a **new, empty** test database and apply migrations/`SmsFullDemoSeeder`, followed by `SmsExtendedDemoSeeder` only when its prerequisites are met. Alternatively develop a separate, reviewed **additive SCHDEMO-only** seeder targeting this existing school database. Never combine the dump and a fresh fixture import into the same schema without checking IDs and uniqueness.

**Gate C — Fix critical access and accounting:** Enable and test tenant-aware API if required; restrict marks to teacher assignments; add specific export permissions; enforce immutable originator/approver controls; add DB-enforced journal source idempotency after duplicate analysis.

**Gate D — Exercise each operational flow:** Students → enrollment → attendance → exam results → fee invoice → payment → reconciliation, followed by HR, library, Hifz, hostel, transport and reporting. Use independent roles and cross-institution attempts.

**Gate E — Acceptance and deployment:** Run migrations on an actual MariaDB 10.4 and/or target MySQL 8 database, run the PHPUnit feature suite, perform browser QA, verify backup restoration, pilot with authorized users, and record UAT signoff before production deployment.

## 6. Reproducible checks

The `diagnostics/READ_ONLY_DATABASE_CHECKS.sql` file contains only SELECT statements. Execute it on the database you actually want to diagnose; it does not create students, alter administrator passwords, add memberships or delete records.

On your own Laravel machine, in the current project directory (the one containing `artisan`):

```bash
php artisan config:clear
php artisan migrate:status
php artisan sms:qa --json
php artisan route:list
php artisan test
```

Run `php artisan test` against a dedicated configured test database, **not** your production or valuable demonstration records. If its tests use `RefreshDatabase`, migrations may reset the *test connection*; verify the target connection first.

### Audit execution limitations

The audit environment has PHP 8.4.24 but lacks `mbstring`, `dom`, `xmlwriter`, and PDO MySQL/SQLite drivers. `php artisan route:list` failed due to `mb_split()` being undefined; `php artisan test` stopped at PHPUnit's PHP-extension check. The user-provided credentials and local `scm-system` MySQL connection were **not used** in this audit.

## 7. Production decision

**NO-GO for production at this stage.** This is a finding about current *verification and demonstrated feature completeness*, not a claim that every source screen is broken. A successful admin login is useful evidence of authentication locally, but cannot substitute for business-workflow, privacy, financial and security signoff.

**Files in this audit ZIP:** `evidence/MODULE_COVERAGE.csv`, `evidence/DATABASE_ROW_COUNTS.csv`, `evidence/FINDINGS.csv`, `evidence/STATIC_AUDIT_RESULTS.json`, `diagnostics/READ_ONLY_DATABASE_CHECKS.sql`, `instructions/QA_RUNBOOK_BANGLA.md`, `instructions/QA_RUNBOOK_ENGLISH.md`.
