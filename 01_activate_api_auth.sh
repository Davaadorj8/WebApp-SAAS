#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error
set -o pipefail # Causes pipelines to fail on the first command that fails

# --- Helper Functions ---
# More robust SA ID sanitization
sanitize_for_sa_id() {
  local name="$1"
  # Convert to lowercase
  name=$(echo "${name}" | tr '[:upper:]' '[:lower:]')
  # Replace non-alphanumeric characters (excluding hyphen) with a hyphen
  name=$(echo "${name}" | sed -e 's/[^a-z0-9-]/-/g')
  # Replace multiple consecutive hyphens with a single hyphen
  name=$(echo "${name}" | sed -e 's/--*/-/g')
  # Remove leading hyphens
  name=$(echo "${name}" | sed -e 's/^-*//')
  # Remove trailing hyphens
  name=$(echo "${name}" | sed -e 's/-*$//')
  # Truncate to 28 characters to leave room for potential suffix if needed by GCP (though unlikely)
  # Max length is 30. Let's truncate to 30 directly.
  name=${name:0:30}
  # Ensure it doesn't end with a hyphen after truncation
  name=$(echo "${name}" | sed -e 's/-*$//')
  # Check if the result is empty after sanitization
  if [ -z "$name" ]; then
    echo "ERROR: Sanitized name is empty. Please choose a different name." >&2
    exit 1
  fi
  # Basic check for minimum length (GCP requires 6-30)
  if [ ${#name} -lt 6 ]; then
     # Attempt to pad (less ideal, validation might be better)
     # For simplicity, let's just inform the user the derived ID might be too short.
     # Or better: Validate the input name upfront. Let's stick to sanitization for now.
     # A better approach might be to validate the *input* SA_NAME length.
     # Let's assume gcloud will handle the final validation.
     echo "Warning: Sanitized ID '$name' might be shorter than the 6-character minimum required by GCP." >&2
  fi
  echo "$name"
}

# --- Configuration ---
echo "Fetching GCP Project ID..."
GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null) # Hide potential errors if not set
if [ -z "$GCP_PROJECT_ID" ]; then
  echo "ERROR: GCP Project ID not set or gcloud not configured correctly." >&2
  echo "Please set your project using: gcloud config set project YOUR_PROJECT_ID" >&2
  exit 1
fi
echo "Using Project ID: ${GCP_PROJECT_ID}"

# Prompt for Service Account details
while true; do
  read -p "Enter desired Service Account Display Name (e.g., firebase-gemini-orchestrator): " SA_NAME
  if [ -z "$SA_NAME" ]; then
    echo "Service Account Name cannot be empty." >&2
  else
    break
  fi
done

# Generate and display sanitized SA ID
SA_ID=$(sanitize_for_sa_id "${SA_NAME}")
echo "Sanitized Service Account ID will be: ${SA_ID}"
# Optional: Add validation against GCP rules here if desired (more complex)

SA_EMAIL="${SA_ID}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# Prompt for Key File Path
while true; do
 read -p "Enter desired path for Service Account Key file (e.g., ./sa-key.json): " KEY_FILE_PATH
 if [ -z "$KEY_FILE_PATH" ]; then
    echo "Key file path cannot be empty." >&2
 elif [ -d "$KEY_FILE_PATH" ]; then
    echo "Error: Specified path '$KEY_FILE_PATH' is a directory, please provide a file path." >&2
 else
    # Check if file exists and confirm overwrite
    if [ -f "$KEY_FILE_PATH" ]; then
        read -p "WARNING: File '${KEY_FILE_PATH}' already exists. Overwrite? (y/N): " overwrite_confirm
        if [[ "$overwrite_confirm" == [yY] || "$overwrite_confirm" == [yY][eE][sS] ]]; then
            echo "Will overwrite existing file."
            break
        else
            echo "Please enter a different file path."
            # Loop continues
        fi
    else
        # File doesn't exist, path is valid
        break
    fi
 fi
done


echo "--------------------------------------------------"
echo "Objective 1.1: Activate Gemini API Access & Authentication"
echo "Project: ${GCP_PROJECT_ID}"
echo "Service Account Name: ${SA_NAME}"
echo "Service Account ID: ${SA_ID}"
echo "Service Account Email: ${SA_EMAIL}"
echo "Key File Path: ${KEY_FILE_PATH}"
echo "--------------------------------------------------"
read -p "Proceed? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || { echo "Aborted."; exit 1; }

# 1. Enable Vertex AI API
echo "STEP 1: Enabling Vertex AI API (vertexai.googleapis.com)..."
if gcloud services list --enabled --filter="name:vertexai.googleapis.com" --project="${GCP_PROJECT_ID}" --format="value(name)" | grep -q "vertexai.googleapis.com"; then
  echo "Vertex AI API is already enabled."
else
  gcloud services enable vertexai.googleapis.com --project="${GCP_PROJECT_ID}"
  echo "Vertex AI API enabled successfully."
fi

# 2. Create Service Account
echo "STEP 2: Checking/Creating Service Account ${SA_NAME} (${SA_EMAIL})..."
# Check if SA already exists
if gcloud iam service-accounts describe "${SA_EMAIL}" --project="${GCP_PROJECT_ID}" > /dev/null 2>&1; then
  echo "Service Account ${SA_EMAIL} already exists. Skipping creation."
else
  echo "Creating Service Account ${SA_ID}..."
  gcloud iam service-accounts create "${SA_ID}" \
    --display-name="${SA_NAME}" \
    --description="Service Account for Firebase Gemini Orchestrator" \
    --project="${GCP_PROJECT_ID}"
  echo "Service Account ${SA_EMAIL} created successfully."
  # Allow some time for propagation before binding roles
  echo "Waiting for SA propagation..."
  sleep 8 # Slightly increased sleep time just in case
fi

# 3. Grant Vertex AI User role (needed for calling the API)
echo "STEP 3: Checking/Granting 'Vertex AI User' role to ${SA_EMAIL}..."
# Check if binding already exists (more robust than just adding)
EXISTING_BINDING=$(gcloud projects get-iam-policy "${GCP_PROJECT_ID}" \
  --flatten="bindings[].members" \
  --format='value(bindings.role)' \
  --filter="bindings.members:serviceAccount:${SA_EMAIL} AND bindings.role:roles/aiplatform.user" 2>/dev/null)

if [ -n "$EXISTING_BINDING" ]; then
    echo "'Vertex AI User' role is already granted."
else
    echo "Granting 'Vertex AI User' role..."
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SA_EMAIL}" \
      --role="roles/aiplatform.user" \
      --condition=None # Explicitly set no condition
    echo "'Vertex AI User' role granted."
    # Optional: add sleep after role grant if subsequent steps fail immediately
    # sleep 5
fi

# 4. Create and Download Service Account Key
echo "STEP 4: Creating and downloading key file to ${KEY_FILE_PATH}..."
# Ensure the directory exists for the key file
KEY_DIR=$(dirname "${KEY_FILE_PATH}")
mkdir -p "${KEY_DIR}"
# The overwrite check was done during the input phase
gcloud iam service-accounts keys create "${KEY_FILE_PATH}" \
  --iam-account="${SA_EMAIL}" \
  --project="${GCP_PROJECT_ID}"
echo "Key file created at ${KEY_FILE_PATH}."

# 5. Instruct User on Security and Environment Variable
echo ""
echo "--------------------- IMPORTANT ----------------------"
echo "ACTION REQUIRED:"
echo "1. SECURE THE KEY FILE: '${KEY_FILE_PATH}' has been created."
echo "   Ensure it is stored securely and access is restricted."
echo "   DO NOT commit this file to Git or share it publicly."
echo ""
echo "2. SET ENVIRONMENT VARIABLE: To use this key for authentication with GCP SDKs"
echo "   or client libraries, set the GOOGLE_APPLICATION_CREDENTIALS environment variable."
echo ""
echo "   For the current terminal session:"
echo "   export GOOGLE_APPLICATION_CREDENTIALS=\"$(realpath "${KEY_FILE_PATH}")\""
echo ""
echo "   To set it persistently (example for bash/zsh - choose one):"
echo "   echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath "${KEY_FILE_PATH}")'\" >> ~/.bashrc"
echo "   # OR"
echo "   echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath "${KEY_FILE_PATH}")'\" >> ~/.zshrc"
echo ""
echo "   After adding it to your shell profile, reload the configuration:"
echo "   source ~/.bashrc  # or source ~/.zshrc"
echo "------------------------------------------------------"
echo ""
echo "Objective 1.1 completed successfully."