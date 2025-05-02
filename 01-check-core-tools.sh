#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Installing Project Dependencies ---"

if [ ! -f "package.json" ]; then
    echo "ERROR: package.json not found in the current directory."
    exit 1
fi

echo "Running pnpm install..."
pnpm install

echo "--- Project dependencies installed successfully ---"
exit 0