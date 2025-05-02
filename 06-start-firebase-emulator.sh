#!/bin/bash
# set -e # Usually DON'T exit on error for emulators, let user Ctrl+C
# set -o pipefail
# set -u

echo "--- Starting Firebase Emulator Suite ---"

# Check if Firebase CLI exists
if ! command -v firebase &> /dev/null; then
    echo "ERROR: Firebase CLI command not found. Please install it ('npm install -g firebase-tools')."
    exit 1
fi

# Check for firebase.json configuration file
if [ ! -f "firebase.json" ]; then
    echo "WARNING: firebase.json not found. Emulator configuration might be missing."
fi

# Define emulators to start based on documentation (Firestore, Auth)
# Add others like Functions, Storage, Hosting if needed.
EMULATORS_TO_START="auth,firestore"

# Optional: Define ports if defaults are not suitable (check firebase.json)
# export FIRESTORE_EMULATOR_HOST="localhost:8080"
# export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"

# Optional: Specify project ID if needed
# PROJECT_ID="your-dev-project-id"
# PROJECT_FLAG="--project ${PROJECT_ID}"

# Optional: Specify import/export path for data persistence
# EMULATOR_DATA_PATH=".firebase-emulator-data"
# IMPORT_FLAG="--import ${EMULATOR_DATA_PATH}"
# EXPORT_FLAG="--export-on-exit ${EMULATOR_DATA_PATH}"

echo "Starting emulators: ${EMULATORS_TO_START}..."
echo "Emulator UI should be available at http://localhost:4000 (default)."
echo "Press Ctrl+C to stop the emulators."

# Construct the command
CMD="firebase emulators:start --only ${EMULATORS_TO_START}"
# [[ -n "$PROJECT_FLAG" ]] && CMD+=" ${PROJECT_FLAG}"
# [[ -n "$IMPORT_FLAG" ]] && CMD+=" ${IMPORT_FLAG}"
# [[ -n "$EXPORT_FLAG" ]] && CMD+=" ${EXPORT_FLAG}"

# Execute the command
$CMD

echo "--- Firebase Emulator Suite stopped ---"
exit 0 # Exit normally after Ctrl+C