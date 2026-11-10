# Sunrise Model School — public website concept for CampusSphere ERP

This is a **new, separate, public-facing school website concept** for the existing Laravel 12 CampusSphere ERP application associated with `https://scm.intrigueit.co/`.

The reference project archive was inspected for compatibility: the existing ERP routes use `/` for the CampusSphere marketing home page and `/login` for authentication. The optional integration uses new routes under `/school`, leaving those routes intact. **The live URL was not accessed or audited.**

## What's included

- `site/` — working six-page static prototype. Open `site/index.html` locally or place the folder under a static web server.
- `laravel/resources/views/school/` — six equivalent Blade views.
- `laravel/public/school-site/assets/` — self-contained styles, script and vector artwork.
- `laravel/routes/school_site.php` — public `/school` route definitions (not activated automatically).
- `QA_REPORT.md` — scope and verification status.

### Pages

1. Home — welcome, programs, why us, campus life, example notices, FAQs.
2. About Us — mission, vision and school values.
3. Academics — Early Years, Primary and Secondary example pathways.
4. Admissions — overview, four-step process, **demo-only** inquiry form.
5. Campus Life — extracurricular, creativity, clubs and school community.
6. Contact — **demo-only** contact form and school detail placeholders.

Site design: responsive and mobile-first breakpoints, keyboard-accessible mobile navigation, visible focus indicators, SEO titles, semantic landmarks, prefers-reduced-motion support, and local SVG artwork without an external image dependency.

## Preview

Unzip and open `site/index.html` in a modern browser. The navigation is a real set of linked HTML pages. Forms only validate fields **in the browser** and display a preview-only notice. They do not write to or contact the ERP database.

## Safest integration with your Laravel app

**Do this on a separate staging copy first. Back up project files and database.**

1. Copy the `laravel/resources/views/school` folder into your existing `resources/views/` folder.
2. Copy the `laravel/public/school-site` folder into your existing `public/` folder.
3. Copy `laravel/routes/school_site.php` into your `routes/` folder.
4. At the **end** of existing `routes/web.php`, add this single line:

   ```php
   require __DIR__.'/school_site.php';
   ```

5. From Laravel root, verify:

   ```bash
   php artisan route:list --path=school
   php artisan view:clear
   ```

6. Browse `http://127.0.0.1:8000/school` on staging (use your own Laravel host and port).
7. Verify navigation, responsive behavior, assets, and the existing ERP login page.

### Existing ERP protections

- Does NOT overwrite `routes/web.php`, ERP controllers, ERP authentication, `/login` or the existing `/` route.
- Does NOT include `.env`, credentials, database migrations or seeders.
- Does NOT reset users, schools, permissions, sample data, or passwords.
- Links to ERP login use `route('login')` in Blade. In the static preview, ERP login links point to `https://scm.intrigueit.co/login` (verify the actual publicly deployed route).
- The site uses `Sunrise Model School` because that is the name of your existing local **demo institution**. Swap for the real school's name, logo, address, media, academic programs and branding before launch.

## Future dynamic integration (not implemented in this package)

For a production school website, build a tenant-scoped public-content subsystem or CMS that stores approved notices, staff bios, school events, public gallery files, and school contact settings. Keep these models separate from authenticated student, parent, payroll, attendance and financial information. Protect any enquiry processing with Laravel CSRF, throttling, server-side validation, spam protection, consent/privacy disclosures and authorized email delivery. Do not expose private ERP data on public routes.

## Important content notes

This is a **design prototype**, not a live institutional website. All school statements and listed programs are illustrative. Contact information and schedules are intentionally not invented. Forms are preview-only. No production deployment or live browser acceptance testing was performed.
