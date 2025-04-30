#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
GCP_PROJECT_ID=$(gcloud config get-value project)
if [ -z "$GCP_PROJECT_ID" ]; then
  echo "ERROR: GCP Project ID not set. Use 'gcloud config set project YOUR_PROJECT_ID'"
  exit 1
fi

# Prompt for Service Account details
read -p "Enter desired Service Account Name (e.g., firebase-gemini-orchestrator): " SA_NAME
# Replace spaces/invalid chars for SA_ID if needed, or use SA_NAME directly if simple
SA_ID="${SA_NAME// /-}" # Basic replacement, adjust if needed
SA_EMAIL="${SA_ID}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
read -p "Enter desired path for Service Account Key file (e.g., ./sa-key.json): " KEY_FILE_PATH

echo "--------------------------------------------------"
echo "Objective 1.1: Activate Gemini API Access & Authentication"
echo "Project: ${GCP_PROJECT_ID}"
echo "Service Account Name: ${SA_NAME}"
echo "Service Account ID: ${SA_ID}"
echo "Service Account Email: ${SA_EMAIL}"
echo "Key File Path: ${KEY_FILE_PATH}"
echo "--------------------------------------------------"
read -p "Proceed? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# 1. Enable Vertex AI API
echo "STEP 1: Enabling Vertex AI API (vertexai.googleapis.com)..."
gcloud services enable vertexai.googleapis.com --project="${GCP_PROJECT_ID}"
echo "Vertex AI API enabled successfully."

# 2. Create Service Account
echo "STEP 2: Creating Service Account ${SA_NAME}..."
# Check if SA already exists
if gcloud iam service-accounts describe "${SA_EMAIL}" --project="${GCP_PROJECT_ID}" > /dev/null 2>&1; then
  echo "Service Account ${SA_EMAIL} already exists. Skipping creation."
else
  gcloud iam service-accounts create "${SA_ID}" \
    --display-name="${SA_NAME}" \
    --description="Service Account for Firebase Gemini Orchestrator" \
    --project="${GCP_PROJECT_ID}"
  echo "Service Account ${SA_EMAIL} created successfully."
  # Allow some time for propagation before binding roles
  sleep 5
fi

# 3. Grant Vertex AI User role (needed for calling the API)
echo "STEP 3: Granting 'Vertex AI User' role to ${SA_EMAIL}..."
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/aiplatform.user" \
  --condition=None # Explicitly set no condition
echo "'Vertex AI User' role granted."

# 4. Create and Download Service Account Key
echo "STEP 4: Creating and downloading key file to ${KEY_FILE_PATH}..."
gcloud iam service-accounts keys create "${KEY_FILE_PATH}" \
  --iam-account="${SA_EMAIL}" \
  --project="${GCP_PROJECT_ID}"
echo "Key file created at ${KEY_FILE_PATH}."

# 5. Instruct User on Security and Environment Variable
echo "--------------------- IMPORTANT ----------------------"
echo "ACTION REQUIRED:"
echo "1. SECURE THE KEY FILE: Move '${KEY_FILE_PATH}' to a secure location."
echo "   DO NOT commit this file to Git or share it publicly."
echo "2. SET ENVIRONMENT VARIABLE: To use this key for authentication,"
echo "   set the GOOGLE_APPLICATION_CREDENTIALS environment variable:"
echo ""
echo "   For the current session:"
echo "   export GOOGLE_APPLICATION_CREDENTIALS=\"$(realpath ${KEY_FILE_PATH})\"" # Use realpath for absolute path
echo ""
echo "   To set it persistently (example for bash/zsh):"
echo "   echo \"export GOOGLE_APPLICATION_CREDENTIALS='$(realpath ${KEY_FILE_PATH})'\" >> ~/.bashrc  # or ~/.zshrc"
echo "   Then run: source ~/.bashrc  # or source ~/.zshrc"
echo "------------------------------------------------------"
echo "Objective 1.1 completed."