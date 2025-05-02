#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Setting Up Environment Variables ---"

ENV_EXAMPLE_FILE=".env.example"
ENV_FILE=".env"

if [ ! -f "$ENV_EXAMPLE_FILE" ]; then
    echo "WARNING: $ENV_EXAMPLE_FILE not found. Cannot guide environment setup."
    exit 0 # Exit gracefully, as we can't proceed with guidance
fi

if [ -f "$ENV_FILE" ]; then
    echo "$ENV_FILE already exists. Skipping creation."
    echo "Please ensure it contains all necessary variables defined in $ENV_EXAMPLE_FILE."
else
    echo "$ENV_FILE does not exist. Copying from $ENV_EXAMPLE_FILE..."
    cp "$ENV_EXAMPLE_FILE" "$ENV_FILE"
    echo "Created $ENV_FILE."
    echo "IMPORTANT: Please review $ENV_FILE and fill in the required environment variable values."
fi

# Optional: Validate with T3 Env if a validation script exists
if pnpm run --silent validate-env &> /dev/null; then
  echo "Attempting to validate environment variables using 'pnpm run validate-env'..."
  if pnpm run validate-env; then
    echo "Environment variables appear valid according to T3 Env schema."
  else
    echo "WARNING: Environment variable validation failed. Check output above and $ENV_FILE."
  fi
else
 echo "NOTE: No 'validate-env' script found in package.json. Skipping T3 Env validation."
 echo "Remember to manually verify your $ENV_FILE contents."
fi


echo "--- Environment variable setup process completed ---"
exit 0