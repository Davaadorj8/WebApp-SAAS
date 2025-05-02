#!/bin/bash
# set -e # Usually DON'T exit on error for dev server, let it report issues
# set -o pipefail
# set -u

echo "--- Starting Next.js Development Server ---"

# Check if next is installed
if ! command -v $(pnpm bin)/next &> /dev/null; then
  echo "ERROR: next command not found. Ensure 'next' is installed."
  exit 1
fi

echo "Starting dev server (assuming 'pnpm run dev' script exists)..."
echo "Server should be available at http://localhost:3000 (default)."
echo "Press Ctrl+C to stop the server."

if pnpm run --silent dev &> /dev/null; then
  pnpm run dev
else
  echo "ERROR: No 'dev' script found in package.json. Please define it (e.g., 'next dev')."
  exit 1
fi

echo "--- Development server stopped ---"
exit 0 # Exit normally after Ctrl+C