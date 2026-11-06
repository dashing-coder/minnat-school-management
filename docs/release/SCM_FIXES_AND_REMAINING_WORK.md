# CampusSphere / SCM — Verified Source Changes & Remaining Work

**Patch date:** 2026-11-06  
**Baseline:** user-uploaded `minnat-school-management.zip` and `scm-system.sql`  
**Target:** Laravel 12 + MariaDB 10.4.32 on the user's current local system (MySQL 8 portability unverified)  
**Important:** This is a **staging/development hardening update**, not a production certificate.

## Requested fixes — honest outcomes

| Requested work | Deliverable in this patch | Status |
|---|---|---|
| Database and sample data compatibility | `SmsSchoolSafeDemoSeeder` handles the *existing single SCHDEMO school*, additive only. Preserves users, passwords, permissions and membership; hard stop when operational data exists; optional local opt-in. | CODE PREPARED; staging seed run required |
| Critical security and API | Removed undeclared Sanctum dependency from tests/API; same-origin authenticated read-only JSON API registered under `/api/v1/`; table-specific restrictive viewer/export policy; sensitive exports denied; restricted CSV allowlists; mandatory teacher assignment before entering marks; approval evidence fail-closed. | CODE PREPARED; HTTP/role tests required |
| Student, admission, academic verification | Existing workflows retained, plus sample data covers enrollments, offers, timetable prerequisites, marks and attendance. New unit/API smoke tests and operator UAT cases. | SOURCE REVIEWED; E2E not yet verified |
| Finance and accounting | Unique journal source index migration with duplicate check; tenant serialization in posting service; fee-plan invoice generator; read-only net payment/approved refund and invoice line reconciliation; SQL audit checks. | CODE PREPARED; migration and accounting tests required |
| HR, payroll and specialized modules | Added payroll liability posting and **record of externally verified** salary disbursement; no bank transfer is initiated. Existing Hifz/hostel/transport/library flows remain partial. | PARTIAL — payroll deductions/tax and specialized scopes pending |
| Integrations and reporting | Eight reports now have permission-controlled, logged CSV export; new `sms:integrations:check` inventory showing provider/outbox status without secrets. | REPORTING CODE PREPARED; live gateway/SMS/biometric delivery NOT implemented |
| Automated tests and functional QA | New privacy/API tests, enhanced `sms:qa`, read-only SQL checks and Windows staging QA runner. PHP lint and static checks performed on the supplied source. | OFFLINE CHECKS PASSED; full PHPUnit/MySQL/browser tests pending |
| Pilot and production deployment | Detailed UAT checklist, staging release procedure, rollback guidance and go/no-go criteria. | **NOT DONE** — live pilot, infrastructure configuration, approvals and go-live need authorized access and execution |

## Highest impact implementation details

- **Journal idempotency:** migration `2026_11_06_000004_unique_ledger_source.php` creates a UNIQUE key on (`institution_id`, `source_type`, `source_reference`) after refusing existing duplicate non-null references. The posting service also locks the present institution row to serialize writes by institution.
- **Refund and payroll approvals:** existing records with missing creator audit evidence cannot be approved. Manually inspect and remediate those records; do not fabricate audit logs.
- **Teacher permissions:** users with `marks.enter` but without the higher `results.approve` or `results.publish` permission must be active employees assigned to the exam's subject/class/session.
- **Data minimization:** generic CSV downloads are allowed only for explicit column/table allowlists. Sensitive medical, safeguarding, payroll, bank and raw general ledger tables cannot be CSV-exported through the generic registers.
- **Session API:** no bearer token or Sanctum is claimed. This is a browser-session same-origin read-only API. Third-party/mobile API access needs separate authentication, token lifecycle and security review.
- **Payroll:** posting is restricted to approved, zero-deduction batches; disbursement records only a **manually verified** cash/bank transaction and does NOT send money. Withholdings and employee self-service remain unimplemented.
- **Fee plans:** the new invoice workflow validates active enrollment, bills configured plan lines, posts receivable/revenue and supports multiple revenue accounts. It does not schedule recurring billing.

## Critical deployment warnings

1. The uploaded ZIP included `.env` and `.git`. The **updated distributable excludes** these as well as `vendor/`, local SQLite DB, local logs, cached config and session files. Do not disclose the old original ZIP. If it was exposed beyond trusted administrators, evaluate credential rotation, but do **not** blindly rotate `APP_KEY` (encrypted existing data could become unreadable).
2. Do not import demo SQL into the current `scm-system` database. Demo seeding is intended only for a **backed-up local/staging copy**, using `SMS_ALLOW_SCHOOL_DEMO_SEED=true` temporarily.
3. The supplied SQL dump has only one school; the `SmsFullDemoSeeder` and `SmsExtendedDemoSeeder` are **not** compatible with its current state. The new school-only seeder is the safe alternative.
4. Database dump is MariaDB 10.4; MySQL 8 migration and query behavior still require their own live test.
5. Never deploy until unit/feature tests, cross-tenant tests, real finance reconciliation, restore drill, student privacy review and institutional UAT have passed.

## Validation evidence

- `php -l` of all shipped PHP source files: see `qa/LINT_RESULTS.json`.
- `php artisan sms:about` ran successfully in the analysis runtime.
- `php artisan route:list --path=api` could **not** complete because this isolated runtime lacks the `mbstring` PHP extension (`mb_split` undefined).
- `php artisan test` could **not** execute because `dom`, `mbstring`, `xmlwriter` PHP extensions are not installed in the analysis runtime; PDO MySQL is also unavailable.
- No live MySQL/MariaDB, external payment/SMS provider or user's staging browser was accessed.

### Completion criteria

The patch is ready for staging review; **no phase can be called fully production-verified from these offline results**. Execute the release runbook, document failures, perform real pilot UAT and approve deployment separately.
