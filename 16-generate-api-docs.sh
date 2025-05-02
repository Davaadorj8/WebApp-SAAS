#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Generating API Documentation (TypeDoc) ---"

# Check if typedoc is installed
if ! command -v $(pnpm bin)/typedoc &> /dev/null; then
  echo "ERROR: typedoc command not found. Ensure 'typedoc' is installed (devDependencies)."
  exit 1
fi

# Check for typedoc config file (typedoc.json)
if [ ! -f "typedoc.json" ]; then
    echo "WARNING: typedoc.json not found. Documentation generation might use defaults or fail."
fi

echo "Generating documentation (assuming 'pnpm run docs:generate' script exists)..."
# Example package.json script: "docs:generate": "typedoc --out docs/api src/index.ts"
if pnpm run --silent docs:generate &> /dev/null; then
  pnpm run docs:generate
else
  echo "ERROR: No 'docs:generate' script found in package.json. Please define it (e.g., 'typedoc --out ./docs/api ./src/ --entryPointStrategy expand ./src')."
  exit 1
fi


echo "--- API documentation generation completed successfully ---"
echo "Check the output directory specified in your typedoc config or script (e.g., docs/api)."
exit 0