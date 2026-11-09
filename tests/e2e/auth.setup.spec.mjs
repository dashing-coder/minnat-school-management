import { test, expect } from '@playwright/test';
import { mkdirSync } from 'node:fs';

// One authentication session reused by all read-only browser probes to avoid rate limiting.
test('school administrator signs in and selects the authorized demo school', async ({ page }) => {
  const password = process.env.QA_ADMIN_PASSWORD;
  if (!password) throw new Error('Set QA_ADMIN_PASSWORD in the LOCAL staging terminal; do not commit it.');
  const email = process.env.QA_ADMIN_EMAIL || 'admin.school@example.test';
  await page.goto('/login');
  await expect(page.getByRole('heading', {name: /sign in to your account/i})).toBeVisible();
  await page.locator('#loginEmail').fill(email);
  await page.locator('#loginPassword').fill(password);
  await page.getByRole('button', {name: /sign in to workspace/i}).click();
  await expect(page).toHaveURL(/\/choose-institution(?:\?|$)/);
  await expect(page.getByRole('heading', {name: /choose your institution/i})).toBeVisible();
  const school = page.locator('button.institution-option').filter({hasText: 'Sunrise Model School'});
  await expect(school).toHaveCount(1);
  await school.click();
  await expect(page).toHaveURL(/\/dashboard(?:\?|$)/);
  await expect(page.locator('#main-content')).toBeVisible();
  mkdirSync('qa/.auth', {recursive: true});
  await page.context().storageState({path: 'qa/.auth/admin.json'});
});
