# Phase 1 Security & QA Checklist

**Status key:** ✅ Source prepared • 🔴 Must execute/verify • 🟡 Future module

| Check | Status | Verification |
|---|---|---|
| Laravel syntax for all provided PHP files | ✅ | Run `php -l` against each file |
| MySQL migration on a clean database | 🔴 | `php artisan migrate --pretend` then `php artisan migrate` on test database |
| Permission catalog seeding | 🔴 | `php artisan db:seed --class=SmsPermissionSeeder` on test DB |
| Authorized institution context | 🔴 | Run tenant test #1 |
| Unauthorized cross-tenant request | 🔴 | Same test, assert HTTP 403 |
| Campus-scoped read | 🔴 | Run tenant test #2 |
| Missing permission | 🔴 | Run tenant test #3 |
| Suspended membership & institution behavior | 🔴 | Add tests for 403 and 404 respectively |
| Cross-tenant role assignment | 🔴 | Try composite FK violation (must be rejected) |
| Cross-tenant campus assignment | 🔴 | Try composite FK violation (must be rejected) |
| Data export and search queries | 🟡 | Future endpoints must tenant-scope every query |
| Parent linked-child record policy | 🟡 | Test unauthorized student IDs return 403/404 |
| Role modification audit | 🟡 | Log actor, before/after IDs, request ID |
| Payment callback authentication/idempotency | 🟡 | Future finance phase; signature and duplicate tests |
| Outbox event delivery | 🟡 | Future queue worker; retry and dead-letter behavior |
| Private file access | 🟡 | Future upload/download authorization |
| Backup + full restore test | 🔴 | Independent test environment, verify sample data |
| MFA/secret handling/rate limit | 🔴 | Deployment and auth configuration |

## Required negative tests

1. Institution A user passes Institution B slug.
2. Institution A role is attached to Institution B membership (DB must reject).
3. Teacher retrieves a student in an unassigned class, even in their campus.
4. Guardian guesses a different student's identifier.
5. Suspended member still presents a valid Sanctum token.
6. Campus-restricted member tries data from a different campus.
7. Queue job runs after institution context changes in worker process.
8. Certificate verification exposes medical or guardian data.
9. Actor attempts mass assignment of `institution_id` or finance status.
10. Retry a payment notification with identical external transaction reference.

## Acceptance gate

Do not go live while the clean migration, automated tests, membership onboarding, permission assignment, backup restore rehearsal, logging and security review remain pending.
