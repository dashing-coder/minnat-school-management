# CampusSphere SCM — controlled staging release, 2026-11-06

## Scope and verification (not production sign-off)
This release is based on the uploaded Laravel project and SCM SQL schema. It is a **staging candidate** rather than a complete production deployment. Existing local database credentials, .env, administrator account, memberships and records are not included in this ZIP or modified remotely.

| Requested task | Delivered in source | Remaining validation / block |
|---|---|---|
| Full Laravel/MySQL automated testing | CI workflow for MariaDB 10.11, migration and PHPUnit; tenant/API, webhook and unit test sources | PHP environment here lacks DOM, mbstring, xmlwriter, pdo_mysql. Tests and migrations **not run** against live MariaDB. CI must pass. |
| Financial reconciliation | Read-only `sms:finance:reconcile` for invoice lines, allocated payments/refunds, GL posting/balance/duplicates, tenant relationships and payroll items | Run against populated staging DB; reconcile bank statements, refunds, opening balances and legacy records independently. |
| Cross-institution security | Tenant-scoped session API; extra tenant and campus tests | Full authenticated API, authorization, CSRF, IDOR and multi-campus browser review on running server. |
| Backup & full restore | Staging-only `scripts/test_mariadb_restore.sh`, separate EMPTY `scm_restore_test_*` DB, row-count comparison and checksum | **Never executed here**. Operator must exercise with real dump, verify application after restore and sign off recovery objectives. |
| Payroll deductions | Salary item calculation, per-deduction liability account, gross/net validation and withholding mapping in payroll posting | Complete local payroll policies, statutory rates and statutory reporting require professional configuration and live QA. |
| Payment gateway | Local/test HMAC-verified demo intent and webhook with idempotency; no real money posted | **No live bKash, Nagad, Rocket or card provider credentials/integration**; signed demo events are NOT settlement evidence. |
| SMS and biometric | Local-only SMS notification simulation and campus-scoped biometric CSV import with validation and duplicate resistance | **No external SMS/WhatsApp traffic or direct biometric hardware connection**. Official provider adapters/credentials needed. |
| Advanced workflows | Existing ERP flows, added payroll and pilot import tooling | Not a claim of all specialized features; perform full UAT and extend based on actual institution policies. |
| Pilot UAT | 61-case UAT checklist (`qa/UAT_EXECUTION.csv`), operator reports and release blocker | All cases currently NOT_RUN. Named pilot owner must gather outcomes/screenshots. |
| Production deployment | Read-only `sms:release:check --production` blocking gate, deployment runbook | **Not deployed**; valid HTTPS, backups, non-demo integrations, monitoring, smoke tests and approved pilot evidence required. |

## Safe staging install (Windows / XAMPP Laravel)
1. Make filesystem and database backups; set up a **separate** staging Laravel directory and staging MariaDB database.
2. Extract the **patch archive**, review changed PHP/migrations, and copy it over staging only. Do not replace `.env`; never import the prior full SQL dump into existing SCM database.
3. Set staging `.env` to actual DB host/port and `CACHE_STORE=file`, `SESSION_DRIVER=file`, `APP_ENV=local`, `APP_DEBUG=true`. Do not enable demo providers in production.
4. Run `composer install`, `php artisan config:clear`, `php artisan migrate:status`, `php artisan migrate --pretend` and review the SQL.
5. **Only after backup and review:** run `php artisan migrate`.
6. Run `php artisan sms:qa`, `php artisan sms:finance:reconcile --json`, `php artisan sms:integrations:check`, `php artisan route:list --path=api`, `php artisan test`.
7. Perform manual admission -> enrollment -> attendance -> marks -> invoice -> payment -> ledger workflow, with at least two distinct institutions and campus-restricted accounts.
8. Restore a backup to a separate EMPTY DB (Linux script provided; for Windows use same explicit separate-db approach) and compare key tables, transactions and login.
9. Record UAT outcomes in `qa/UAT_EXECUTION.csv`, with assigned owner and evidence. Review every blocker before go-live.
10. On production, set `APP_ENV=production`, `APP_DEBUG=false`, HTTPS, appropriate queues/monitoring; confirm `php artisan sms:release:check --production` and obtain written deployment approval. No one should bypass the release gate by setting flags without evidence.

### Limitations
- An offline PHP syntax lint, source inventory, package integrity and pure helper smoke test can run here. These are **not** substitutes for live integration tests or complete ERP certification.
- The distributed release deliberately excludes `.env`, `.git`, `vendor`, `node_modules`, logs and database credentials. Run Composer and frontend tooling using local deployment instructions.
- No production payment gateway, outbound messaging account, or biometric service has been connected or verified.
- No pilot users were enrolled, and no live deployment was executed.
