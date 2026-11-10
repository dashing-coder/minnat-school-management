# Install the Laravel public school site

Copy this patch's contents into your existing Laravel project root (the folder containing artisan). It is additive and does not include .env or SQL.

Run `php scripts/install_school_site.php --install` OR append `require __DIR__.'/school_site.php';` to the end of `routes/web.php` manually. Then `php artisan route:clear`, `php artisan view:clear`, `php artisan route:list --path=school`.

Verify staging `/school` and `/login` before deploying. No database change is required. Original route installer documentation is in the main README.
