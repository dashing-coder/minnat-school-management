# Go-live plan — blocked pending external execution

**Preflight:** green CI; successful MariaDB migration/rollback review; successful finance reconciliation; full UAT with signed evidence; cross-tenant security review; completed restore drill on isolated database; API/SMS/payment provider sandbox contract tests; monitored queue; incident contacts and rollback plan.

**Cutover:** take point-in-time verified backup, lock maintenance window, apply approved artifact (not project `.env`), `composer install --no-dev --optimize-autoloader`, `php artisan migrate --force` only after DBA review, `php artisan config:cache`, `php artisan route:cache` if compatible, start queue workers/scheduler, and smoke test role-specific screens and ledger totals. Never run demo seeders on production.

**Rollback:** stop writes; preserve migration/change logs and original DB snapshot; redeploy prior application build and restore DB only with authorized rollback procedure (otherwise data loss may occur). Validate records and financial ledger afterward.

**Evidence:** operator, date/time, CI URL/test transcript, SQL migration plan, backup hash, restore audit, payments/SMS sandbox verification, pilot UAT, finance sign-off, named release approver and deployment window. No synthetic pass marks.
