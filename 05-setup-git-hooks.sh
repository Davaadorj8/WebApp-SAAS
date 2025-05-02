#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Setting Up Git Hooks ---"

# Check if .git directory exists
if [ ! -d ".git" ]; then
    echo "ERROR: Not a git repository (or you are not in the root)."
    exit 1
fi

# Check if husky is installed (often a devDependency)
if ! command -v $(pnpm bin)/husky &> /dev/null; then
  echo "ERROR: husky command not found. Ensure 'husky' is installed (devDependencies)."
  exit 1
fi

echo "Running husky install..."
# The command depends on husky version. v7+ often uses `husky install`
# Older versions might require different commands or rely on postinstall.
# This assumes husky v7+ setup where `prepare` script in package.json runs `husky install`.
# Running it manually ensures hooks are set up if `prepare` didn't run or was skipped.
pnpm exec husky install

# Verify that hooks are created (optional check)
if [ -d ".husky" ] && [ -n "$(ls -A .husky)" ]; then
  echo "Husky hooks directory (.husky) found and is not empty."
  ls -l .husky # List hooks for visibility
else
  echo "WARNING: Husky hooks directory (.husky) not found or is empty after install."
  echo "Check your husky configuration and package.json ('prepare' script)."
fi

echo "--- Git hooks setup process completed ---"
exit 0