# FIX: 404 at https://scm.intrigueit.co/school

## Cause

The previous ZIP supplied website files, but **downloading a ZIP does not deploy or register routes on your live server**. In that version, the route file `routes/school_site.php` was deliberately **not activated automatically**; `routes/web.php` still needed `require __DIR__.'/school_site.php';` at its end. This is the most likely explanation for the `/school` 404. We have **not accessed your live server**, so it is not yet confirmed.

## Install safely (Laravel 12, existing CampusSphere ERP)

1. **Back up your existing website files** first. A database backup is also recommended before any server change, but this patch does **not** modify the database.
2. In your hosting File Manager, SFTP client or SSH console, locate the **actual Laravel application root** for `scm.intrigueit.co`: the directory containing `artisan`, `routes/`, `resources/`, and `public/`. Do not confuse it with the web server `public_html`/document root.
3. Extract the fix ZIP into that application root **preserving folder structure**. The files must end up at:
   - `<Laravel root>/routes/school_site.php`
   - `<Laravel root>/resources/views/school/home.blade.php` (and five others)
   - `<Laravel root>/public/school-site/assets/styles.css` (and accompanying assets)
   - `<Laravel root>/scripts/install_school_site.php`
4. Open terminal/SSH/PowerShell **in the Laravel root** and run:

   ```bash
   php scripts/install_school_site.php --install
   php artisan route:list --path=school
   ```

   Successful output includes six `GET|HEAD` routes, including `school` with route name `school.home` and `school/about`, `school/contact` etc.
5. Open `https://scm.intrigueit.co/school`. Verify this asset also loads: `https://scm.intrigueit.co/school-site/assets/styles.css`.

**What it changes:** The installer adds a **single include** to `routes/web.php` if not already present, creates a backup copy of `web.php` in `storage/app/school-site-install-backups/`, then attempts `route:clear` and `view:clear`. It is idempotent. **It does not change your `/`, `/login`, `/dashboard`, `.env`, MySQL data, roles, student records, or demo admin credentials.**

### If you do NOT have PHP CLI/SSH

Copy these files into your Laravel root as above. Open `<Laravel root>/routes/web.php` and add exactly **one line at the END of the file**, outside any middleware group:

```php
require __DIR__.'/school_site.php';
```

If a route cache is enabled, have your host run `php artisan route:clear` (and optionally `php artisan view:clear`) on the *deployed application*. A web-server restart alone is not a substitute for clearing stale Laravel route caches.

## Diagnosis if it still returns 404

- **If `route:list --path=school` lists ZERO routes**, `routes/web.php` was not updated in the correct deployed project, the include path is wrong, or the host is still using a cached route collection. Check the installer output and `php artisan route:clear`.
- **If the routes DO appear in Artisan but the website still returns 404**, check whether you deployed into the wrong server/project, `scm.intrigueit.co` uses another document root/release, or Apache/Nginx rewrite/route cache is pointing elsewhere. The Laravel document root should normally be the app's **`public/`** folder. Do NOT copy the entire Laravel project into public HTML.
- **If `/school` opens but looks unstyled**, check that `public/school-site/assets/styles.css` is accessible at `https://scm.intrigueit.co/school-site/assets/styles.css`. Check deployment of the `public/` assets and reverse-proxy/CDN caches.
- **If you get HTTP 500**, check `storage/logs/laravel.log` and verify file read permissions / Blade caches. Avoid enabling `APP_DEBUG=true` on a public site.
- **If `/login` works but `/school` does not**, the server is handling Laravel routes; focus on route registration rather than changing web-server rewrites.

## Manual test commands

```bash
php scripts/install_school_site.php --status
php -l routes/school_site.php
php -l scripts/install_school_site.php
php artisan route:clear
php artisan view:clear
php artisan route:list --path=school
```

## Rollback

Remove the **single line** `require __DIR__.'/school_site.php';` from `routes/web.php`, or restore the timestamped `web.php` backup made by the installer (take care not to discard other edits made afterward). Then run `php artisan route:clear` and `php artisan view:clear`.

## Known limitations

The school website is a public-facing design prototype. Its contact/admissions forms are front-end demonstrations only (not database-backed). Branding is the example school **Sunrise Model School**. The package has not been deployed or verified against your live hosting by the assistant. Replace sample details with official content before announcing the site.
