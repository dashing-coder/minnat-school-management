# QA report — School public website concept

## Automated / static checks completed

- Six static HTML pages generated, six matching Blade files, and new Laravel route additions.
- Valid XML SVG artwork; standalone CSS/JS/assets included.
- JavaScript syntax checked using Node.js.
- Static local-link validation and HTML structural checks (run by `scripts/qa_static.py`).
- Route stub validated using PHP lint (`php -l`).

## Not tested / not claimed

- A live inspection of `https://scm.intrigueit.co/` was not available.
- Chromium/Playwright navigation was blocked by the browser environment's administrator restriction, even to local files and loopback addresses, so responsive visual acceptance checks could not be completed here.
- Laravel route registration in your real local server, Blade rendering with your vendor dependencies, and live ERP login flow require verification on your Windows staging copy.
- Forms are intentionally not connected to a database or an email delivery service.
- Pilot acceptance, actual school branding, official contact details, SEO content approval and production deployment are pending.

## Safe next gate

Install the optional Blade route on **staging**, test `/school` at desktop/mobile sizes, then choose whether to make the public school site the domain home page or use a different school subdomain. Do not change existing ERP or login routes without a verified rollback path.
