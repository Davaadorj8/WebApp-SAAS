#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
DEFAULT_PROJECT_DIR="firebase-gemini-studio"
read -p "Enter project directory name [${DEFAULT_PROJECT_DIR}]: " PROJECT_DIR
PROJECT_DIR="${PROJECT_DIR:-${DEFAULT_PROJECT_DIR}}" # Use default if empty

# List of base dependencies
DEPENDENCIES="genkit @google-cloud/vertexai firebase-admin dotenv"
DEV_DEPENDENCIES="typescript @types/node" # Optional: If using TypeScript

echo "--------------------------------------------------"
echo "Objective 1.3: Prepare Orchestrator Development Environment"
echo "Project Directory: ${PROJECT_DIR}"
echo "--------------------------------------------------"
read -p "Proceed? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1


# 1. Check Tool Prerequisites
echo "STEP 1: Checking prerequisites (node, npm/yarn, git, firebase)..."
command -v node >/dev/null 2>&1 || { echo >&2 "ERROR: 'node' is required but it's not installed. Aborting."; exit 1; }
# Prefer npm but allow yarn
NPM_CMD="npm"
YARN_CMD=""
if command -v yarn >/dev/null 2>&1; then
    YARN_CMD="yarn"
    read -p "Found 'yarn'. Use yarn instead of npm? (Y/n): " use_yarn
    if [[ $use_yarn == [nN] ]]; then
        YARN_CMD=""
    else
         NPM_CMD="yarn" # Set NPM_CMD to yarn for install command
    fi
fi
command -v $NPM_CMD >/dev/null 2>&1 || { echo >&2 "ERROR: '$NPM_CMD' is required but it's not installed. Aborting."; exit 1; }
command -v git >/dev/null 2>&1 || { echo >&2 "ERROR: 'git' is required but it's not installed. Aborting."; exit 1; }
command -v firebase >/dev/null 2>&1 || { echo >&2 "ERROR: 'firebase' CLI is required but it's not installed. See Firebase documentation. Aborting."; exit 1; }
echo "Prerequisites check passed."
echo "Node version: $(node --version)"
echo "Using package manager: $NPM_CMD"
echo "Git version: $(git --version)"
echo "Firebase CLI version: $(firebase --version)"


# 2. Create Project Directory and Initialize
echo "STEP 2: Creating directory '${PROJECT_DIR}' and initializing project..."
if [ -d "$PROJECT_DIR" ]; then
  echo "Directory '$PROJECT_DIR' already exists. Skipping creation."
else
  mkdir "$PROJECT_DIR"
  echo "Directory created."
fi
cd "$PROJECT_DIR"
echo "Changed directory to $(pwd)"

# Initialize npm/yarn project if package.json doesn't exist
if [ ! -f "package.json" ]; then
  if [ "$NPM_CMD" == "yarn" ]; then
      yarn init -y
  else
      npm init -y
  fi
  echo "Initialized $NPM_CMD project."
else
    echo "package.json already exists. Skipping init."
fi

# Initialize TypeScript if requested and tsconfig.json doesn't exist
read -p "Initialize TypeScript project (adds tsconfig.json and dev dependencies)? (y/N): " init_ts
if [[ $init_ts == [yY] || $init_ts == [yY][eE][sS] ]]; then
    if [ ! -f "tsconfig.json" ]; then
        echo "Initializing TypeScript..."
        if [ "$NPM_CMD" == "yarn" ]; then
            yarn add --dev $DEV_DEPENDENCIES
            ./node_modules/.bin/tsc --init
        else
            npm install --save-dev $DEV_DEPENDENCIES
            ./node_modules/.bin/tsc --init
        fi
        echo "TypeScript initialized (tsconfig.json created, dev dependencies added)."
        # Optional: Create a basic src directory
        mkdir -p src
        touch src/index.ts
        echo "Created src/index.ts"
    else
        echo "tsconfig.json already exists. Skipping TypeScript init."
    fi
fi

# 3. Install Dependencies
echo "STEP 3: Installing base dependencies (${DEPENDENCIES})..."
if [ "$NPM_CMD" == "yarn" ]; then
    yarn add $DEPENDENCIES
else
    npm install --save $DEPENDENCIES
fi
echo "Base dependencies installed."

# 4. Create .gitignore
echo "STEP 4: Creating/updating .gitignore..."
touch .gitignore # Create if it doesn't exist
# Add entries if they don't already exist
grep -qxF 'node_modules/' .gitignore || echo 'node_modules/' >> .gitignore
grep -qxF '.env' .gitignore || echo '.env' >> .gitignore
grep -qxF '*.log' .gitignore || echo '*.log' >> .gitignore
grep -qxF 'sa-key.json' .gitignore || echo 'sa-key*.json' >> .gitignore # Pattern for key files
grep -qxF '.DS_Store' .gitignore || echo '.DS_Store' >> .gitignore
echo ".gitignore configured."

# 5. Create Template .env File
echo "STEP 5: Creating template .env file..."
if [ ! -f ".env" ]; then
  cat > .env << EOL
# Environment variables for Firebase Gemini Orchestrator
# IMPORTANT: Add this file to .gitignore and DO NOT commit it!

# Path to your downloaded Service Account Key JSON file
# Example: GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/secure/location/sa-key.json"
GOOGLE_APPLICATION_CREDENTIALS=""

# Your Google Cloud Project ID
# Example: GCP_PROJECT_ID="your-gcp-project-id"
GCP_PROJECT_ID=""

# Your Firebase Project ID
# Example: FIREBASE_PROJECT_ID="your-firebase-project-id"
FIREBASE_PROJECT_ID=""

# Add other configuration variables as needed
# Example: VECTOR_STORE_ID="your-vector-store-index-id"

EOL
  echo "Created template .env file."
else
  echo ".env file already exists. Skipping creation."
fi


# 6. Final Instructions
echo "--------------------- IMPORTANT ----------------------"
echo "ACTION REQUIRED:"
echo "1. EDIT the '.env' file in the '${PROJECT_DIR}' directory."
echo "   Fill in the correct values for GOOGLE_APPLICATION_CREDENTIALS,"
echo "   GCP_PROJECT_ID, FIREBASE_PROJECT_ID, and any other variables."
echo "2. ENSURE the path to your Service Account key is correct and the file is secure."
echo "3. You can now start developing your Genkit flows in this directory!"
echo "------------------------------------------------------"
echo "Objective 1.3 completed."