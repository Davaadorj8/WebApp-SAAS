#!/bin/bash
set -euo pipefail

# Purpose: Configures environment to use a PREDEFINED Service Account
#          for Vertex AI API access, including optional gcloud impersonation.
# Action:  Enables Vertex AI API, grants necessary roles to the predefined SA
#          and the user, guides on using the existing key file.
# Does NOT create a new Service Account or Key File.

# --- Predefined Credentials ---
PREDEFINED_SA_EMAIL="saas-builder@gen-lang-client-0794018478.iam.gserviceaccount.com"
PREDEFINED_KEY_FILENAME="gen-lang-client-0794018478-42e00c5a6ab0.json"
# Extract project ID from SA email for informational purposes/validation if needed
PREDEFINED_SA_PROJECT_ID=$(echo "$PREDEFINED_SA_EMAIL" | cut -d'@' -f2 | cut -d'.' -f1)

# --- Fail fast if gcloud missing ---
command -v gcloud >/dev/null || { echo "ERROR: gcloud CLI not found." >&2; exit 1; }

# --- Config ---
echo "Fetching GCP Project ID and User Account…"
# Use the project associated with the predefined SA for consistency in checks/grants
# Alternatively, could use the user's current default project, but using the SA's project seems safer
# for ensuring roles are granted in the correct place. Let's stick with the SA's project.
GCP_PROJECT_ID="$PREDEFINED_SA_PROJECT_ID"
GCP_USER_ACCOUNT=$(gcloud config get-value account 2>/dev/null)

# Check if the SA's project is set or accessible
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ "$CURRENT_PROJECT" != "$GCP_PROJECT_ID" ]; then
    echo "Warning: Your current gcloud project ('$CURRENT_PROJECT') differs from the Service Account's project ('$GCP_PROJECT_ID')." >&2
    echo "         Attempting to operate on project '$GCP_PROJECT_ID'." >&2
    # Optional: Add prompt to switch project or exit
    # read -p "Switch active project to '$GCP_PROJECT_ID' to continue? (y/N): " switch_proj
    # [[ "$switch_proj" =~ ^[Yy] ]] || { echo "Aborted. Please run 'gcloud config set project $GCP_PROJECT_ID'"; exit 1; }
    # gcloud config set project "$GCP_PROJECT_ID"
    # GCP_PROJECT_ID=$(gcloud config get-value project) # Re-fetch just in case
fi

[ -z "$GCP_PROJECT_ID" ] && { echo "ERROR: Could not determine Project ID for the Service Account." >&2; exit 1; }
[ -z "$GCP_USER_ACCOUNT" ] && { echo "ERROR: No active gcloud user account found. Run: gcloud auth login" >&2; exit 1; }

echo "Target Project: $GCP_PROJECT_ID"
echo "Predefined Service Account: $PREDEFINED_SA_EMAIL"
echo "Acting User: $GCP_USER_ACCOUNT"

# --- Check if Predefined SA Exists ---
echo "Checking if predefined Service Account exists..."
if ! gcloud iam service-accounts describe "$PREDEFINED_SA_EMAIL" --project="$GCP_PROJECT_ID" &>/dev/null; then
    echo "ERROR: The predefined Service Account '$PREDEFINED_SA_EMAIL' was not found in project '$GCP_PROJECT_ID'." >&2
    echo "Please ensure the Service Account exists and the email is correct." >&2
    exit 1
fi
echo "Service Account found."

# --- Prompt for EXISTING Key File Path ---
while :; do
  # Prompt clearly indicating the expected filename
  read -p "Enter the full path to the EXISTING key file ('$PREDEFINED_KEY_FILENAME'): " KEY_FILE_PATH
  [ -n "$KEY_FILE_PATH" ] || { echo "Path cannot be empty." >&2; continue; }
  # Optional: Check if filename matches exactly (can be too strict if user renamed it)
  # [[ "$(basename "$KEY_FILE_PATH")" == "$PREDEFINED_KEY_FILENAME" ]] || { echo "Warning: Filename does not match '$PREDEFINED_KEY_FILENAME'." >&2; }

  [ ! -f "$KEY_FILE_PATH" ] && { echo "ERROR: File not found at '$KEY_FILE_PATH'." >&2; continue; }
  [ -d "$KEY_FILE_PATH" ] && { echo "ERROR: '$KEY_FILE_PATH' is a directory, not a file." >&2; continue; }

  # It's an existing file, break the loop
  break
done
echo "Using key file: $KEY_FILE_PATH"


echo "--------------------------------------------------"
echo "Objective: Configure environment for Vertex AI using:"
echo " Project:             $GCP_PROJECT_ID"
echo " Service Account:     $PREDEFINED_SA_EMAIL"
echo " User:                $GCP_USER_ACCOUNT"
echo " Existing Key File:   $KEY_FILE_PATH"
echo "--------------------------------------------------"
read -p "Proceed with enabling API and granting roles? (y/N): " confirm
[[ "$confirm" =~ ^[Yy] ]] || { echo "Aborted."; exit 1; }

# 1. Enable Vertex AI API
echo "STEP 1: Enabling Vertex AI API (vertexai.googleapis.com) in project '$GCP_PROJECT_ID'..."
if ! gcloud services list --enabled --filter="vertexai.googleapis.com" --project="$GCP_PROJECT_ID" --format="value(name)" | grep -q .; then
  gcloud services enable vertexai.googleapis.com --project="$GCP_PROJECT_ID"
  echo "Vertex AI API enabled successfully."
else
  echo "Vertex AI API is already enabled in this project."
fi

# Step 2 (SA Creation) is skipped - using predefined SA

# 3. Grant Vertex AI User role TO THE PREDEFINED SERVICE ACCOUNT
echo "STEP 2: Granting 'roles/aiplatform.user' to '$PREDEFINED_SA_EMAIL'..."
if ! gcloud projects get-iam-policy "$GCP_PROJECT_ID" \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:$PREDEFINED_SA_EMAIL AND bindings.role:roles/aiplatform.user" \
     --format="value(bindings.role)" | grep -q .; then
  gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" \
    --member="serviceAccount:$PREDEFINED_SA_EMAIL" \
    --role="roles/aiplatform.user" \
    --condition=None # Explicitly setting no condition (standard practice)
  echo "Role 'roles/aiplatform.user' granted to the Service Account."
else
  echo "Role 'roles/aiplatform.user' already granted to the Service Account."
fi

# 4. Grant Token Creator role TO THE USER (for impersonation) ON THE PREDEFINED SA
echo "STEP 3: Granting 'roles/iam.serviceAccountTokenCreator' to user '$GCP_USER_ACCOUNT' on '$PREDEFINED_SA_EMAIL'..."
echo "         (This allows your user account to impersonate the service account via gcloud)"
if ! gcloud iam service-accounts get-iam-policy "$PREDEFINED_SA_EMAIL" --project="$GCP_PROJECT_ID" \
     --flatten="bindings[].members" \
     --filter="bindings.members:user:$GCP_USER_ACCOUNT AND bindings.role:roles/iam.serviceAccountTokenCreator" \
     --format="value(bindings.role)" | grep -q .; then
  gcloud iam service-accounts add-iam-policy-binding "$PREDEFINED_SA_EMAIL" \
    --member="user:$GCP_USER_ACCOUNT" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --project="$GCP_PROJECT_ID"
  echo "Role 'roles/iam.serviceAccountTokenCreator' granted to user '$GCP_USER_ACCOUNT'."
else
  echo "Role 'roles/iam.serviceAccountTokenCreator' already granted to user '$GCP_USER_ACCOUNT'."
fi

# Step 5 (Create Key) is skipped - using predefined key

# 5. Optional: Configure gcloud CLI for Default Impersonation
echo "STEP 4: Configure gcloud CLI for default impersonation?"
echo "        This makes gcloud commands run as '$PREDEFINED_SA_EMAIL' by default."
read -p "Configure default gcloud impersonation? (y/N): " resp_impersonate

IMPERSONATION_CONFIGURED=false
if [[ "$resp_impersonate" =~ ^[Yy] ]]; then
  gcloud config set auth/impersonate_service_account "$PREDEFINED_SA_EMAIL"
  echo "gcloud CLI default impersonation configured for '$PREDEFINED_SA_EMAIL'."
  IMPERSONATION_CONFIGURED=true
else
  echo "Skipped gcloud CLI default impersonation configuration."
fi

# 6. Final Instructions
echo ""
echo "--------------------- IMPORTANT ----------------------"
echo "Configuration Complete. Please note the following:"
echo ""
if [ "$IMPERSONATION_CONFIGURED" = true ]; then
  echo "1. GCLOUD CLI CONFIGURED FOR IMPERSONATION:"
  echo "   Your gcloud CLI will now run commands as '$PREDEFINED_SA_EMAIL' by default."
  echo "   To STOP impersonating by default, run:"
  echo "   gcloud config unset auth/impersonate_service_account"
  echo ""
  echo "2. SDK/APPLICATION AUTHENTICATION (Using the Key File):"
else
  echo "1. GCLOUD CLI NOT CONFIGURED FOR DEFAULT IMPERSONATION."
  echo "   You can still impersonate for specific gcloud commands using:"
  echo "   gcloud [...] --impersonate-service-account=\"$PREDEFINED_SA_EMAIL\""
  echo ""
  echo "2. GCLOUD CLI / SDK/APPLICATION AUTHENTICATION (Using the Key File):"
fi
echo "   The EXISTING key file is located at: '$KEY_FILE_PATH'"
echo "   - SECURE THIS KEY FILE: It grants access to your cloud resources."
echo "     Store it securely, restrict access, and DO NOT commit it to Git."
echo "   - FOR SDKs/APPLICATIONS (Python, Node, Java, etc.) or environments"
echo "     without gcloud impersonation, set the GOOGLE_APPLICATION_CREDENTIALS"
echo "     environment variable:"
echo ""
echo "     For the current terminal session:"
echo "     export GOOGLE_APPLICATION_CREDENTIALS=\"$(realpath "$KEY_FILE_PATH")\""
echo ""
echo "     To set it persistently (example for bash/zsh - choose one):"
echo "     echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath "$KEY_FILE_PATH")'\" >> ~/.bashrc"
echo "     # OR"
echo "     echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath "$KEY_FILE_PATH")'\" >> ~/.zshrc"
echo ""
echo "     Then reload your shell profile:"
echo "     source ~/.bashrc  # or source ~/.zshrc"
echo "------------------------------------------------------"
echo ""
echo "Setup process finished."