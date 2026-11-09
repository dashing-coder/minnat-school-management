import { defineConfig, devices } from '@playwright/test';

// Default is an isolated, locally hosted STAGING copy on port 8001.
// Never point this suite at your working site or a public production domain.
const baseURL = process.env.QA_BASE_URL || 'http://127.0.0.1:8001';
const target = new URL(baseURL);
if (target.protocol !== 'http:' || !['127.0.0.1', 'localhost'].includes(target.hostname)) {
  throw new Error('Browser QA is restricted to http://127.0.0.1 or http://localhost staging URLs.');
}
const auth = 'qa/.auth/admin.json';
export default defineConfig({
  testDir: '../tests/e2e',
  timeout: 30_000,
  expect: { timeout: 10_000 },
  retries: process.env.CI ? 1 : 0,
  workers: 1, // Avoid repeated login attempts and throttling against demo users.
  forbidOnly: Boolean(process.env.CI),
  reporter: [['list'], ['json', {outputFile: 'qa-results/browser-results.json'}]],
  outputDir: 'qa-results/browser-output',
  use: {
    baseURL,
    headless: true,
    trace: 'off',
    screenshot: 'off', // Don't write student names / financial details into evidence by default.
    video: 'off',
    ignoreHTTPSErrors: false,
  },
  projects: [
    { name: 'login-setup', testMatch: /auth\.setup\.spec\.mjs/, use: { ...devices['Desktop Chrome'] } },
    { name: 'desktop', testIgnore: /auth\.setup\.spec\.mjs/, dependencies: ['login-setup'],
      use: { ...devices['Desktop Chrome'], storageState: auth } },
    { name: 'mobile', testIgnore: /auth\.setup\.spec\.mjs/, dependencies: ['login-setup'],
      use: { ...devices['iPhone 13'], browserName: 'chromium', storageState: auth } },
    { name: 'tablet', testIgnore: /auth\.setup\.spec\.mjs/, dependencies: ['login-setup'],
      use: { ...devices['iPad (gen 7)'], browserName: 'chromium', storageState: auth } },
  ],
});
