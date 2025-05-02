#!/bin/bash
# set -e # Usually DON'T exit on error for storybook, let it report issues
# set -o pipefail
# set -u

echo "--- Starting Storybook ---"

# Check if storybook is installed
if ! command -v $(pnpm bin)/storybook &> /dev/null && ! command -v $(pnpm bin)/start-storybook &> /dev/null; then
  echo "ERROR: storybook command not found. Ensure '@storybook/react', etc. are installed."
  exit 1
fi

# Check for storybook config directory (.storybook)
if [ ! -d ".storybook" ]; then
    echo "WARNING: .storybook directory not found. Storybook might not be configured correctly."
fi

echo "Starting Storybook server (assuming 'pnpm run storybook' script exists)..."
echo "Storybook should be available at http://localhost:6006 (default)."
echo "Press Ctrl+C to stop the server."

if pnpm run --silent storybook &> /dev/null; then
  pnpm run storybook
else
  echo "ERROR: No 'storybook' script found in package.json. Please define it (e.g., 'storybook dev -p 6006')."
  exit 1
fi


echo "--- Storybook stopped ---"
exit 0 # Exit normally after Ctrl+C