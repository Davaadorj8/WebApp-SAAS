#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Analyzing Production Bundle Size ---"

# Check if @next/bundle-analyzer is installed
# We check for its presence in package.json as it's not a direct command
if ! grep -q "\"@next/bundle-analyzer\"" package.json; then
    echo "ERROR: '@next/bundle-analyzer' not found in package.json dependencies."
    exit 1
fi

# Ensure the app is built first (optional, could be part of the analyze script)
# echo "Ensuring production build exists..."
# ./13-build-app.sh # Or run 'pnpm build'

echo "Running bundle analysis (assuming 'pnpm run analyze' script exists)..."
echo "This usually involves setting ANALYZE=true and running the build."

# Assumes an "analyze" script exists in package.json
# Example package.json script: "analyze": "ANALYZE=true pnpm build"
if pnpm run --silent analyze &> /dev/null; then
  pnpm run analyze
else
  echo "ERROR: No 'analyze' script found in package.json."
  echo "Please define it (e.g., \"analyze\": \"ANALYZE=true pnpm build\")."
  exit 1
fi

echo "--- Bundle analysis completed ---"
echo "Check the generated report files (e.g., .next/analyze/client.html)."
exit 0