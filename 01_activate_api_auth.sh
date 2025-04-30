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
  # Truncate to 30 characters (GCP max length for SA ID)
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
     echo "Warning: Sanitized ID '$name' might be shorter than the 6-character minimum required by GCP." >&2
     # gcloud create command will perform final validation
  fi
  echo "$name"
}

# --- Configuration ---
echo "Fetching GCP Project ID and User Account..."
GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
GCP_USER_ACCOUNT=$(gcloud config get-value account 2>/dev/null)

if [ -z "$GCP_PROJECT_ID" ]; then
  echo "ERROR: GCP Project ID not set or gcloud not configured correctly." >&2
  echo "Please set your project using: gcloud config set project YOUR_PROJECT_ID" >&2
  exit 1
fi
if [ -z "$GCP_USER_ACCOUNT" ]; then
  echo "ERROR: GCP User Account not found or gcloud not configured correctly." >&2
  echo "Please login using: gcloud auth login" >&2
  exit 1
fi
echo "Using Project ID: ${GCP_PROJECT_ID}"
echo "Using User Account: ${GCP_USER_ACCOUNT}"


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
SA_EMAIL="${SA_ID}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# Prompt for Key File Path (still useful for SDKs/Apps)
while true; do
 read -p "Enter desired path for Service Account Key file (needed for SDKs/Apps, e.g., ./sa-key.json): " KEY_FILE_PATH
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
echo "User Account: ${GCP_USER_ACCOUNT}"
echo "Service Account Name: ${SA_NAME}"
echo "Service Account ID: ${SA_ID}"
echo "Service Account Email: ${SA_EMAIL}"
echo "Key File Path (for SDKs): ${KEY_FILE_PATH}"
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
if gcloud iam service-accounts describe "${SA_EMAIL}" --project="${GCP_PROJECT_ID}" > /dev/null 2>&1; then
  echo "Service Account ${SA_EMAIL} already exists. Skipping creation."
else
  echo "Creating Service Account ${SA_ID}..."
  gcloud iam service-accounts create "${SA_ID}" \
    --display-name="${SA_NAME}" \
    --description="Service Account for Firebase Gemini Orchestrator" \
    --project="${GCP_PROJECT_ID}"
  echo "Service Account ${SA_EMAIL} created successfully."
  echo "Waiting for SA propagation..."
  sleep 8
fi

# 3. Grant Vertex AI User role TO THE SERVICE ACCOUNT
echo "STEP 3: Checking/Granting 'Vertex AI User' role to ${SA_EMAIL}..."
EXISTING_BINDING_AIUSER=$(gcloud projects get-iam-policy "${GCP_PROJECT_ID}" \
  --flatten="bindings[].members" \
  --format='value(bindings.role)' \
  --filter="bindings.members:serviceAccount:${SA_EMAIL} AND bindings.role:roles/aiplatform.user" 2>/dev/null)

if [ -n "$EXISTING_BINDING_AIUSER" ]; then
    echo "'Vertex AI User' role is already granted to the Service Account."
else
    echo "Granting 'Vertex AI User' role to ${SA_EMAIL}..."
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SA_EMAIL}" \
      --role="roles/aiplatform.user" \
      --condition=None
    echo "'Vertex AI User' role granted to the Service Account."
    sleep 5 # Allow propagation
fi

# 4. Grant Service Account Token Creator role TO THE USER (for impersonation)
echo "STEP 4: Checking/Granting 'Service Account Token Creator' role to user ${GCP_USER_ACCOUNT} on ${SA_EMAIL}..."
echo "         (This allows your user account to impersonate the service account)"

# Check if the binding exists on the service account's policy
EXISTING_BINDING_TOKENCREATOR=$(gcloud iam service-accounts get-iam-policy "${SA_EMAIL}" \
  --project="${GCP_PROJECT_ID}" \
  --flatten="bindings[].members" \
  --format='value(bindings.role)' \
  --filter="bindings.members:user:${GCP_USER_ACCOUNT} AND bindings.role:roles/iam.serviceAccountTokenCreator" 2>/dev/null)

if [ -n "$EXISTING_BINDING_TOKENCREATOR" ]; then
    echo "'Service Account Token Creator' role already granted to ${GCP_USER_ACCOUNT} on this SA."
else
    echo "Granting 'Service Account Token Creator' role to ${GCP_USER_ACCOUNT} on ${SA_EMAIL}..."
    gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
      --project="${GCP_PROJECT_ID}" \
      --member="user:${GCP_USER_ACCOUNT}" \
      --role='roles/iam.serviceAccountTokenCreator'
    echo "'Service Account Token Creator' role granted."
    sleep 5 # Allow propagation
fi


# 5. Create and Download Service Account Key (For SDKs/Apps)
echo "STEP 5: Creating and downloading key file to ${KEY_FILE_PATH} (for SDKs/Apps)..."
KEY_DIR=$(dirname "${KEY_FILE_PATH}")
mkdir -p "${KEY_DIR}"
gcloud iam service-accounts keys create "${KEY_FILE_PATH}" \
  --iam-account="${SA_EMAIL}" \
  --project="${GCP_PROJECT_ID}"
echo "Key file created at ${KEY_FILE_PATH}."


# 6. Configure gcloud CLI for Default Impersonation (Optional)
echo "STEP 6: Configure gcloud CLI for default impersonation..."
echo ""
echo "You can configure your local gcloud CLI to automatically use the identity"
echo "of the service account '${SA_EMAIL}' for future commands."
echo "This uses your user credentials (${GCP_USER_ACCOUNT}) to act as the service account."
echo ""
read -p "Configure gcloud CLI to impersonate ${SA_EMAIL} by default? (y/N): " confirm_impersonate

IMPERSONATION_CONFIGURED=false
if [[ "$confirm_impersonate" == [yY] || "$confirm_impersonate" == [yY][eE][sS] ]]; then
    echo "Setting gcloud config auth/impersonate_service_account..."
    gcloud config set auth/impersonate_service_account "${SA_EMAIL}"
    echo "gcloud CLI is now configured to impersonate ${SA_EMAIL} by default."
    IMPERSONATION_CONFIGURED=true
else
    echo "Skipping gcloud CLI default impersonation configuration."
fi


# 7. Final Instructions
echo ""
echo "--------------------- IMPORTANT ----------------------"
echo "ACTION REQUIRED / SUMMARY:"
echo ""
if [ "$IMPERSONATION_CONFIGURED" = true ]; then
  echo "1. GCLOUD CLI CONFIGURED: Your gcloud CLI will now run commands as"
  echo "   '${SA_EMAIL}' by default using impersonation."
  echo "   To STOP impersonating by default, run:"
  echo "   gcloud config unset auth/impersonate_service_account"
  echo ""
  echo "2. SDK/APPLICATION AUTHENTICATION:"
else
  echo "1. GCLOUD CLI NOT CONFIGURED FOR IMPERSONATION BY DEFAULT."
  echo "   You can still impersonate for specific commands using:"
  echo "   gcloud [...] --impersonate-service-account=\"${SA_EMAIL}\""
  echo ""
  echo "2. GCLOUD CLI / SDK/APPLICATION AUTHENTICATION:"
fi
echo "   The key file '${KEY_FILE_PATH}' has been created."
echo "   - SECURE THE KEY FILE: Store it securely, restrict access."
echo "     DO NOT commit this file to Git or share it publicly."
echo "   - FOR SDKs/APPLICATIONS (Python, Node, Java, etc.) or environments"
echo "     without gcloud impersonation, set the GOOGLE_APPLICATION_CREDENTIALS"
echo "     environment variable:"
echo ""
echo "     For the current terminal session:"
echo "     export GOOGLE_APPLICATION_CREDENTIALS=\"$(realpath "${KEY_FILE_PATH}")\""
echo ""
echo "     To set it persistently (example for bash/zsh - choose one):"
echo "     echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath "${KEY_FILE_PATH}")'\" >> ~/.bashrc"
echo "     # OR"
echo "     echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath "${KEY_FILE_PATH}")'\" >> ~/.zshrc"
echo ""
echo "     Then reload your shell profile:"
echo "     source ~/.bashrc  # or source ~/.zshrc"
echo "------------------------------------------------------"
echo ""
echo "Objective 1.1 completed successfully."