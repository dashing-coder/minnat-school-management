# Database QA / Acceptance Test Plan

**Executed locally:** Schema graph, tenant FK references, fixture fields, financial balancing, SQL generation and PHP syntax were checked by package tooling (see validation report).

**Not executed:** actual Laravel migrations and MySQL runtime import (Composer/MySQL server not present). Do not claim production verification.

## Required runtime checks after installing MySQL and Laravel

1. `php artisan migrate:fresh` on a **disposable local** database only; never use `migrate:fresh` on production.
2. Seed with `SMS_ALLOW_DEMO_SEED=true` and verify 3 institutions are created.
3. Confirm all account passwords are randomized and work only for authorized institution memberships.
4. Confirm `(institution_id,student_id)` from School cannot link to College student in `student_attendance` or `student_invoices`.
5. Confirm invoice totals equal lines; payments and payment allocations reconcile.
6. Confirm every journal has `SUM(debit) = SUM(credit)` and is nonzero.
7. Confirm Institution A cannot read Institution B data through API routes, export endpoints, file downloads or guessed IDs.
8. Confirm posted financial records can only be reversed, not silently overwritten/deleted.
9. Confirm no duplicate invoices/receipts from retried payment callbacks (idempotency).
10. Confirm permission/role boundaries for Admin, Teacher, Accountant, Parent and Hifz Teacher.
11. Confirm academic results cannot publish without approval and marks remain auditable.
12. Confirm indexes, query plans, backups, restorations, timezone and utf8mb4 Bangla support.
13. Test the SQL import path on a *different fresh database* and compare row counts with the Laravel seeder path.
14. Test schema migration rollback in a disposable environment.

## Demo financial reconciliation

| Institution | Invoiced | Paid | Outstanding | Journal pair count |
|---|---:|---:|---:|---:|
| Sunrise School | 2500.00 | 1000.00 | 1500.00 | 2 |
| Horizon College | 3800.00 | 800.00 | 3000.00 | 2 |
| Noorul Huda Madrasha | 1800.00 | 500.00 | 1300.00 | 2 |

Unapproved refund requests are not posted to the ledger.
