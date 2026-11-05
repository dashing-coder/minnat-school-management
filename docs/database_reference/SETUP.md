# Integration Setup — Existing or New Laravel App

**This ZIP is a Laravel source overlay, not a complete runnable Laravel application.** A base Laravel project, Composer dependencies and configured database are prerequisites. No existing project files were modified by preparing this ZIP.

## Minimum prerequisites

- Compatible Laravel installation and PHP version; validate dependencies with `composer check-platform-reqs`.
- MySQL 8+ with a separate development database and database user with appropriate permissions.
- Standard Laravel `users` migration already present.
- Laravel Sanctum installed/configured for your chosen authentication channel.
- Back up any existing database, commit working code and perform the first installation in a non-production environment.

## Step 1 — Copy the overlay

Copy corresponding files from this package into the Laravel project, preserving folder structure. Compare file names first to avoid replacing existing custom classes.

## Step 2 — Add scoped context binding

In `app/Providers/AppServiceProvider.php`, within `register()` add:

```php
$this->app->scoped(\App\Support\Sms\InstitutionContext::class, function () {
    return new \App\Support\Sms\InstitutionContext();
});
```

The context must be scoped per HTTP request/job lifecycle; do **not** register it as a process-wide singleton in queue workers.

## Step 3 — Include routes

Add the following to the **existing** `routes/api.php`:

```php
require __DIR__ . '/sms_api.php';
```

If your Laravel skeleton does not have an API routing file, enable API routes in `bootstrap/app.php` according to the Laravel version you are using. In Laravel distributions with an `install:api` command, follow its normal installation process; do not add a second `/api` prefix.

## Step 4 — Configure a development database

In `.env` provide the correct non-production DB credentials. Example only:

```dotenv
APP_ENV=local
APP_DEBUG=true
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sms_erp_dev
DB_USERNAME=your_dev_db_user
DB_PASSWORD=your_dev_db_password
```

**Never commit real credentials.** Disable `APP_DEBUG` in production.

## Step 5 — Inspect and run migration in DEV

Windows PowerShell from Laravel project folder:

```powershell
php artisan migrate:status
php artisan migrate --pretend
php artisan migrate
php artisan db:seed --class=SmsPermissionSeeder
php artisan route:list --path=api/v1
```

The migration assumes `users` already exists; otherwise the FK creation will fail. Run Laravel's base migrations first.

## Step 6 — Provision tenant and role securely

Use only the restricted command described in the next step. A full institution invitation and ongoing role-management UI has not yet been implemented.

Do **not** insert production admin memberships via publicly accessible endpoints. `platform_admin_users` is separate from institution roles and is not used to bypass tenant authorization.

## Step 7 — Securely create an institution and its first admin

First, create a trusted Laravel user through your existing authentication/admin process and verify their email. The package includes a server-console-only bootstrap command; it grants **limited institution administration**, not finance permissions or platform privileges.

```powershell
php artisan sms:bootstrap-institution SCH001 my-school "My School" admin@example.com --type=school --campus="Main Campus"
```

You will be prompted to confirm. Replace the example email with the verified email of your chosen administrator. Do not run this command before reviewing the account owner. For college/madrasha use `--type=college` or `--type=madrasha`. Laravel generally autodiscovers commands in `app/Console/Commands`; if your application doesn't, register the command through its actual command routing/Kernel mechanism.

## Step 8 — Run the tests

```powershell
php artisan test --filter=TenantIsolationTest
```

Confirm all three tests pass. The test file requires Laravel's normal `tests/TestCase.php`, user factory, test database and Sanctum. These dependencies are not included in this overlay.

## Step 9 — Verify API

After authenticating an active member and assigning the necessary permissions:

- `GET /api/v1/institutions/{slug}/context`
- `GET /api/v1/institutions/{slug}/campuses`

Without auth, membership or the required role permission, endpoints must deny access. Replace `{slug}` with the actual institution slug. Never trust the slug alone as access control.

## Required before production

- Verify database migration on MySQL; run integration and negative tests.
- Build controlled institution provisioning, invite and role administration workflow.
- Add rate limits, MFA for privileged roles, secure token policies, full audit logging and operational monitoring.
- Implement institution/module gates, campus/record policies for all future endpoints, and an audited data retention policy.
- Configure backup/restore, CI, dependency audits and deployment review.
