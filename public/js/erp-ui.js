/* CampusSphere UI enhancements. No external dependencies or stored user data. */
(() => {
  'use strict';
  const menu = document.getElementById('menuButton');
  const sidebar = document.getElementById('sidebar');
  const backdrop = document.getElementById('navBackdrop');
  const moduleSearch = document.getElementById('moduleNavSearch');
  let priorFocus = null;
  const isMobile = () => window.matchMedia('(max-width: 900px)').matches;
  function closeMenu(restoreFocus = false) {
    if (!sidebar || !menu || !backdrop) return;
    sidebar.classList.remove('mobile-open');
    backdrop.hidden = true;
    menu.setAttribute('aria-expanded', 'false');
    menu.setAttribute('aria-label', 'Open navigation menu');
    document.body.classList.remove('nav-open');
    if (restoreFocus && priorFocus && priorFocus.isConnected) priorFocus.focus();
  }
  function openMenu() {
    if (!sidebar || !menu || !backdrop) return;
    priorFocus = document.activeElement;
    sidebar.classList.add('mobile-open');
    backdrop.hidden = false;
    menu.setAttribute('aria-expanded', 'true');
    menu.setAttribute('aria-label', 'Close navigation menu');
    document.body.classList.add('nav-open');
    (moduleSearch || sidebar.querySelector('a'))?.focus();
  }
  menu?.addEventListener('click', () => sidebar?.classList.contains('mobile-open') ? closeMenu(true) : openMenu());
  backdrop?.addEventListener('click', () => closeMenu(true));
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && sidebar?.classList.contains('mobile-open')) {
      event.preventDefault(); closeMenu(true);
    }
    if (event.key !== 'Tab' || !isMobile() || !sidebar?.classList.contains('mobile-open')) return;
    const focusables = [...sidebar.querySelectorAll('a[href],input:not([disabled]),button:not([disabled])')]
      .filter(el => !el.hidden && el.offsetParent !== null);
    if (!focusables.length) return;
    const first = focusables[0], last = focusables[focusables.length - 1];
    if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
    if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
  });
  window.matchMedia('(max-width: 900px)').addEventListener('change', e => { if (!e.matches) closeMenu(false); });
  sidebar?.querySelectorAll('a[href]').forEach(link => link.addEventListener('click', () => { if (isMobile()) closeMenu(false); }));

  const moduleLinks = [...document.querySelectorAll('[data-nav-module]')];
  const empty = document.getElementById('moduleNavEmpty');
  moduleSearch?.addEventListener('input', () => {
    const q = moduleSearch.value.trim().toLocaleLowerCase();
    let visible = 0;
    moduleLinks.forEach(link => { const match = link.textContent.toLocaleLowerCase().includes(q); link.hidden = !match; if (match) visible++; });
    if (empty) empty.hidden = visible !== 0;
  });
  document.querySelectorAll('form[data-prevent-double-submit="true"]').forEach(form => {
    form.addEventListener('submit', () => {
      if (form.dataset.submitting === 'true') return;
      form.dataset.submitting = 'true';
      const submitter = form.querySelector('button[type="submit"]');
      if (submitter) {
        submitter.disabled = true;
        submitter.dataset.originalLabel = submitter.textContent;
        submitter.textContent = 'Saving…';
      }
    });
  });
  if (document.getElementById('validation-summary')) document.getElementById('validation-summary').focus({preventScroll:false});
})();
