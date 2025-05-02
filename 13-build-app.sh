#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Building Next.js Application for Production ---"

# Check if next is installed
if ! command -v $(pnpm bin)/next &> /dev/null; then
  echo "ERROR: next command not found. Ensure 'next' is installed."
  exit 1
fi

# Check if .env exists, as build might need production env vars
if [ ! -f ".env" ]; then
    echo "WARNING: .env file not found. Build might fail or use default/missing variables."
    echo "Ensure production environment variables are available (e.g., via CI secrets or a .env file)."
fi

echo "Running production build (assuming 'pnpm run build' script exists)..."
if pnpm run --silent build &> /dev/null; then
  pnpm run build
else
  echo "ERROR: No 'build' script found in package.json. Please define it (e.g., 'next build')."
  exit 1
fi

echo "--- Production build completed successfully ---"
echo "Output directory: .next/"
exit 0