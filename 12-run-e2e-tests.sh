#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Running End-to-End Tests (Playwright) ---"

# Check if playwright is installed
# Playwright might be installed via `pnpm exec playwright install` separately
if ! command -v $(pnpm bin)/playwright &> /dev/null; then
  echo "WARNING: playwright command not found directly via pnpm bin."
  echo "Ensure Playwright is installed ('pnpm add -D @playwright/test') and browsers are installed ('pnpm exec playwright install')."
  # We don't exit here, as the pnpm script might still work
fi

# Check for Playwright config file (playwright.config.ts/js)
if [ ! -f "playwright.config.ts" ] && [ ! -f "playwright.config.js" ]; then
    echo "WARNING: No playwright.config.ts/js found. Tests might use defaults or fail."
fi

# E2E tests might need the app to be built or running
# Option 1: Run against a running dev server (start it separately first)
# Option 2: Build the app and run tests against the build (common in CI)
# Option 3: Let Playwright handle the server (if configured in playwright.config.js)

echo "Running E2E tests (assuming 'pnpm run test:e2e' script exists)..."
# This script likely handles starting/stopping servers or uses a build.
if pnpm run --silent test:e2e &> /dev/null; then
  pnpm run test:e2e $@ # Pass arguments like --ui, --headed
else
  echo "ERROR: No 'test:e2e' script found in package.json. Please define it (e.g., 'playwright test')."
  exit 1
fi

echo "--- End-to-End tests completed successfully ---"
exit 0