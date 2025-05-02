#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Running TypeScript Type Check ---"

# Check if tsconfig.json exists
if [ ! -f "tsconfig.json" ]; then
    echo "ERROR: tsconfig.json not found."
    exit 1
fi

# Check if typescript is installed
if ! command -v $(pnpm bin)/tsc &> /dev/null; then
  echo "ERROR: TypeScript compiler (tsc) not found. Ensure 'typescript' is installed."
  exit 1
fi

echo "Running tsc --noEmit..."
# Assumes a "typecheck" script exists in package.json or uses the direct command
# Using a script from package.json is generally preferred
if pnpm run --silent typecheck &> /dev/null; then
  pnpm run typecheck
else
  echo "No 'typecheck' script found in package.json, running 'pnpm exec tsc --noEmit' directly."
  pnpm exec tsc --noEmit
fi


echo "--- TypeScript type check completed successfully ---"
exit 0