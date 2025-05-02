#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Running Unit Tests (Jest + RTL) ---"

# Check if jest is installed
if ! command -v $(pnpm bin)/jest &> /dev/null; then
  echo "ERROR: jest command not found. Ensure 'jest' and related packages are installed."
  exit 1
fi

# Check for Jest config file (jest.config.js or defined in package.json)
if [ ! -f "jest.config.js" ] && ! grep -q "\"jest\":" package.json; then
    echo "WARNING: No jest.config.js found and no 'jest' key in package.json. Tests might use defaults or fail."
fi

echo "Running unit tests (assuming 'pnpm run test' or 'pnpm run test:unit' script exists)..."
# Prefer specific script if available
if pnpm run --silent test:unit &> /dev/null; then
  pnpm run test:unit $@ # Pass arguments like --watch, --coverage
elif pnpm run --silent test &> /dev/null; then
  pnpm run test $@ # Pass arguments like --watch, --coverage
else
  echo "ERROR: No 'test' or 'test:unit' script found in package.json. Please define it (e.g., 'jest')."
  exit 1
fi

echo "--- Unit tests completed successfully ---"
exit 0