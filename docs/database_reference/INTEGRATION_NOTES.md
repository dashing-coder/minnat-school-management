# Laravel Integration Notes

- Start with **a fresh Laravel project using MySQL 8+**. This package intentionally does not ship Laravel framework/vendor files.
- The two supplied migrations are ordered so that the standard Laravel `users` table migration runs before the Phase 1 core migration (2026_11_04...).
- Copy the `app/` and `routes/` Phase 1 reference code only after checking against your Laravel version and `bootstrap/app.php` middleware/route registration. They are not required to import or seed this database.
- `SmsPermissionSeeder` and `SmsFullDemoSeeder` use the standard Laravel Seeder namespace. Do not run `SmsPermissionSeeder` ahead of `SmsFullDemoSeeder`: the latter includes the complete permission catalog as fixtures. `SmsFullDemoSeeder` requires `SMS_ALLOW_DEMO_SEED=true`, local/testing environment, and an empty database.
- The standalone raw SQL import and Laravel migrations are **exclusive alternatives**. The raw SQL schema includes `users`, but does not register Laravel migrations or other framework tables.
- The schema uses **composite tenant foreign keys**; never disable FOREIGN_KEY_CHECKS to bypass tenant integrity. Authorization is still required in middleware, policies, queries, exports and file access.
- Do not treat `DECIMAL` fields or ledger rows alone as completed double-entry accounting. Posting services must validate debits equal credits and perform inserts atomically.
- The demo dataset deliberately includes no functioning third-party service credentials and no real documents.
- Before production: add per-tenant unique business-key indexes, relevant compound query indexes, audit hooks, encryption of sensitive medical info, file security, lifecycle retention, payroll calculations, and device/provider idempotency.
- Note: hard deleting master data is restricted by foreign keys; implement soft-delete policies for business records after review.

- Extra migration `000003` adds tenant-scoped unique keys and indexes; keep it in the Laravel migration chain alongside `000001` and `000002`.
