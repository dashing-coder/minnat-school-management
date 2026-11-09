import {test, expect} from '@playwright/test';

test('unauthenticated browser is redirected away from protected dashboards', async ({browser, baseURL}) => {
  const context = await browser.newContext({baseURL}); // no shared admin cookie
  const page = await context.newPage();
  try {
    for (const route of ['/dashboard', '/students', '/modules/finance', '/attendance/mark']) {
      await page.goto(route);
      await expect(page).toHaveURL(/\/login(?:\?|$)/);
    }
  } finally {
    await context.close();
  }
});
