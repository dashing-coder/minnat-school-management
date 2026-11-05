# CampusSphere Laravel ERP — Phase: Dashboard & 20 Modules QA
**Report date:** 2026-11-05  |  **Scope:** provided 119 KB Laravel source baseline and fictitious fixtures

## Overall verdict
**NOT PRODUCTION-READY.** Local source inspection and offline structural checks were completed. The application cannot be exercised in a full Laravel/MySQL runtime in this workspace because Composer/vendor dependencies and the user’s running database are not accessible. A read-only `php artisan sms:qa` command and 100 manual test cases are included for execution on the actual installation.

## Offline verified source checks
- Laravel module definitions: **20** (expected 20).
- Mapped, distinct module register tables: **111** (expected 111).
- Created tables in source migrations: **120** (expected 120 including users/core).
- Unmapped module tables: **0**.
- Registered tables lacking `institution_id` or `id` in source definitions: **0**.
- PHP lint: **50/50** PHP files passed.
- Fictional fixture records: **602**, across **116** named tables.
- Fictional sample posted journals with unequal debits/credits: **0**.
- Fictional invoice paid amounts differing from allocations: **0**.
- A passing structural check does **not** prove routes, SQL migrations, dashboards, authentication, or workflows execute successfully.

## Fixes made in QA-reviewed source
1. **Dashboard privacy:** student/HR/admissions/finance metrics now check their own module permissions; restricted users no longer inherit finance and student data through `dashboard.view` alone. Related links are conditional.
2. **Campus isolation guard:** campus-limited memberships are additionally filtered through student, employee, section, admission-cycle or known parent relations. If a data register has no vetted campus scope, it returns no rows for campus-limited members (fail-closed). This may hide institution-wide curriculum/reference registers pending specific access policies.
3. **Read-only command:** `php artisan sms:qa` checks all 20 module table mappings on the actual MySQL connection, core tables, session/cache config, sample admin membership, invoice bounds and allocations, posted journal balancing, and attendance uniqueness.
4. **Automated test skeleton:** PHPUnit module map and guest-protected-route tests added, but **not run** in this environment.

## Module-by-module functional assessment
| # | Module | Tables mapped | Current source assessment | Local E2E test |
|---:|---|---:|---|---|
| 1 | Students & SIS | 4 | Basic create/edit + directory; family/documents are register-only | NOT RUN |
| 2 | Admissions | 3 | Register browser; application/merit/approval workflow missing | NOT RUN |
| 3 | Academics & LMS | 15 | Register browser; routine conflict/lesson/LMS workflow missing | NOT RUN |
| 4 | Attendance | 3 | Basic mark/upsert form; device sync/alerts/leave approval missing | NOT RUN |
| 5 | Exams & Results | 7 | Register browser; grade calculation/approval/publication missing | NOT RUN |
| 6 | Fees & Accounting | 16 | Dashboard snapshot and registers; billing, accounting posting, reconciliation missing | NOT RUN |
| 7 | Teachers & HR | 7 | Register browser; payroll computation/leave approvals missing | NOT RUN |
| 8 | Communication | 5 | Notice preview and registers; messages/SMS/WhatsApp delivery missing | NOT RUN |
| 9 | Library | 3 | Register browser; circulation/fines workflow missing | NOT RUN |
| 10 | Hostel & Transport | 10 | Register browser; bed/route/meal operations missing | NOT RUN |
| 11 | Inventory & Assets | 7 | Register browser; procurement/stock movement workflow missing | NOT RUN |
| 12 | Security & Analytics | 4 | RBAC and scoped registers; full audit/privacy/security QA missing | NOT RUN |
| 13 | Institutions & Campuses | 3 | Membership-based institution selector; configuration workflows missing | NOT RUN |
| 14 | Academic Lifecycle | 4 | Register browser; promotion/TC/graduation workflow missing | NOT RUN |
| 15 | Hifz & Madrasha | 4 | Register browser; sabaq/sabqi/manzil assessment workflows missing | NOT RUN |
| 16 | Scholarships & Donations | 6 | Register browser; restricted fund/accounting control missing | NOT RUN |
| 17 | Student Welfare | 3 | Register browser; safeguarding/discipline workflow missing | NOT RUN |
| 18 | Certificates | 2 | Register browser; issue/verify/revoke missing | NOT RUN |
| 19 | Campus & Events | 3 | Register browser; visitor pass/room booking workflow missing | NOT RUN |
| 20 | Integrations | 2 | Register browser; external APIs/biometrics/payment integrations missing | NOT RUN |

## Critical release blockers (confirmed missing source capabilities)
- **P0 — Finance:** Implement invoice creation/approval, payment idempotency, balanced double-entry posting, refunds and bank reconciliation before financial use.
- **P0 — Exams:** Implement grade calculations, marks approval and controlled publication before academic reporting.
- **P0 — Authorization:** Expand row-level RBAC and campus access policies, especially for institution-wide shared tables and sensitive welfare/finance records.
- **P0 — Production security:** Perform authenticated/unauthenticated role testing, MySQL integration tests, CSRF/session checks, PII export review, backup/restore rehearsal and penetration testing.
- **P1 — HR, library, hostel, Hifz, admissions, messaging and integrations:** Most module pages are data register browsers, not transactional workflows.
- **P1 — Demo attendance:** Fixture attendance sessions are closed. To test marking attendance, create/open an authorized session in a separate test database; do not change production attendance records casually.

## Local execution instructions (safe: read-only)
1. **Back up your current project** and database. Keep your current working `.env`, administrator password, and MySQL connection (port 3307 in your earlier setup).
2. Copy only changed code files from the `QA_PATCH_ONLY` archive into their matching paths, after reviewing them. **Do not import demo SQL or run `migrate:fresh`.**
3. In the existing Laravel root: `php artisan config:clear` and then `php artisan sms:qa`.
4. For machine-readable output: `php artisan sms:qa --json`. Do not publish the output if it exposes your private database name.
5. Run the available PHPUnit tests (with Composer already installed): `php artisan test` in a separate testing environment.
6. Execute `qa/QA_EXECUTION_CHECKLIST.csv` through browser/UI with assigned institution roles; record PASS/FAIL plus evidence.
7. Only after defects are fixed and verified on staging, plan deployment.

## Boundaries
- This QA package does **not** alter the actual MySQL data and does not reset login credentials.
- The prior `SESSION_DRIVER=file` and `CACHE_STORE=file` solution remains unchanged.
- Source lint, sample arithmetic and file presence were checked offline; runtime tests and end-to-end module acceptance remain pending.
- QA changes do not magically complete the advanced workflow modules.
