import { test, expect } from '@playwright/test';

// READ-ONLY probes. Tests must never submit admissions, money, grades or payroll.
test('dashboard, school context and navigation render without server errors', async ({page}) => {
  const badResponses = [];
  const errors = [];
  page.on('response', r => {if (r.status() >= 500) badResponses.push(`${r.status()} ${new URL(r.url()).pathname}`);});
  page.on('pageerror', e => errors.push(e.message));
  await page.goto('/dashboard');
  await expect(page.locator('#main-content')).toBeVisible();
  await expect(page.getByRole('heading', {name: /welcome back/i})).toBeVisible();
  await expect(page.getByRole('link', {name: /switch institution/i})).toContainText('Sunrise Model School');
  await expect(page.locator('.stats-grid')).toBeVisible();
  expect(badResponses).toEqual([]);
  expect(errors).toEqual([]);
});

test('student directory, academic, admissions and finance views load', async ({page}) => {
  for (const [path, heading] of [
    ['/students', /student directory/i],
    ['/modules/admissions', /admissions/i],
    ['/modules/academics', /academic/i],
    ['/modules/finance', /fees|accounting/i],
  ]) {
    const response = await page.goto(path);
    expect(response?.status(), `Request ${path}`).toBe(200);
    await expect(page.locator('main h1').first()).toContainText(heading);
  }
});

test('student search is non-destructive and can clear the filter', async ({page}) => {
  await page.goto('/students');
  const search = page.locator('#studentSearch');
  await expect(search).toBeVisible();
  await search.fill('__QA_NO_STUDENT_MATCH_9817__');
  await page.getByRole('button', {name: 'Search'}).click();
  await expect(page).toHaveURL(/search=__QA_NO_STUDENT_MATCH_9817__/);
  await expect(page.getByText(/no students match your search/i)).toBeVisible();
  await page.getByRole('link', {name: /clear/i}).first().click();
  await expect(page).toHaveURL(/\/students$/);
});

test('module nav filtering and keyboard skip link are available', async ({page, isMobile}) => {
  await page.goto('/dashboard');
  await page.keyboard.press('Tab');
  await expect(page.getByRole('link', {name: /skip to main content/i})).toBeFocused();
  await page.getByRole('link', {name: /skip to main content/i}).press('Enter');
  await expect(page.locator('#main-content')).toBeFocused();
  if (isMobile && (page.viewportSize()?.width ?? 2000) < 700) {
    await page.locator('#menuButton').click();
  }
  const search = page.locator('#moduleNavSearch');
  await search.fill('Hifz');
  const visible = page.locator('[data-nav-module]:visible');
  await expect(visible).toHaveCount(1);
  await expect(visible.first()).toContainText(/hifz/i);
  await search.fill('');
});

test('layout does not cause global horizontal overflow', async ({page}) => {
  await page.goto('/dashboard');
  const widths = await page.evaluate(() => ({
    viewport: document.documentElement.clientWidth,
    content: document.documentElement.scrollWidth,
  }));
  expect(widths.content, 'body/document overflows horizontally').toBeLessThanOrEqual(widths.viewport + 1);
});

test('mobile sidebar opens and closes via Escape', async ({page, isMobile}) => {
  test.skip(!isMobile || (page.viewportSize()?.width ?? 2000) >= 700, 'Applies only to narrow mobile viewports.');
  await page.goto('/dashboard');
  const button = page.locator('#menuButton');
  await expect(button).toBeVisible();
  await button.click();
  await expect(button).toHaveAttribute('aria-expanded', 'true');
  await page.keyboard.press('Escape');
  await expect(button).toHaveAttribute('aria-expanded', 'false');
});
