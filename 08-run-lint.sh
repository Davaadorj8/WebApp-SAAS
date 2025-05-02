#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Running Code Formatter (Prettier) ---"

# Check if prettier config exists (e.g., .prettierrc.json, prettier.config.js)
# Prettier usually finds its config automatically
if [ ! -f ".prettierrc.json" ] && [ ! -f ".prettierrc.js" ] && [ ! -f "prettier.config.js" ]; then
    echo "WARNING: No standard Prettier config file found. Formatting might use defaults."
fi

# Check if prettier is installed
if ! command -v $(pnpm bin)/prettier &> /dev/null; then
  echo "ERROR: prettier command not found. Ensure 'prettier' is installed."
  exit 1
fi

echo "Running formatter check (assuming 'pnpm run format:check' script exists)..."
# Often, you have separate check and write scripts
if pnpm run --silent format:check &> /dev/null; then
  pnpm run format:check
else
  echo "No 'format:check' script found, attempting 'prettier --check .'"
  if ! pnpm exec prettier --check .; then
     echo "Code formatting issues found. Run formatter to fix (e.g., 'pnpm run format' or './09-run-format.sh --write')."
     exit 1
  fi
fi

# Add write capability with a flag
if [[ "$1" == "--write" ]]; then
  echo "Running formatter write (assuming 'pnpm run format' script exists)..."
  if pnpm run --silent format &> /dev/null; then
    pnpm run format
  else
    echo "No 'format' script found for writing, attempting 'prettier --write .'"
    pnpm exec prettier --write .
  fi
  echo "--- Formatting write completed ---"
else
 echo "--- Formatting check completed successfully (use --write flag to fix) ---"
fi


exit 0