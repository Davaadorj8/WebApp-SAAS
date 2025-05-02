#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
GCP_PROJECT_ID=$(gcloud config get-value project)
if [ -z "$GCP_PROJECT_ID" ]; then
  echo "ERROR: GCP Project ID not set. Use 'gcloud config set project YOUR_PROJECT_ID'"
  exit 1
fi

# Prompt for Service Account Email
read -p "Enter the Service Account Email (e.g., your-sa-id@your-project-id.iam.gserviceaccount.com): " SA_EMAIL
if [ -z "$SA_EMAIL" ]; then
    echo "ERROR: Service Account Email cannot be empty."
    exit 1
fi

echo "--------------------------------------------------"
echo "Objective 1.2: Implement Minimum Necessary Read Permissions"
echo "Project: ${GCP_PROJECT_ID}"
echo "Service Account: ${SA_EMAIL}"
echo "--------------------------------------------------"
read -p "Proceed? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# 1. Grant Vector Store Read Permissions (Example: Firestore)
echo "STEP 1: Granting Vector Store Read Permissions..."
echo "Choose your Vector Store type:"
echo "  1) Firestore (roles/datastore.user - provides read/write)"
echo "  2) Firestore (roles/datastore.viewer - provides read-only)"
echo "  3) Vertex AI Vector Search (requires specific index/endpoint roles - grant manually for now)"
echo "  4) Skip / Grant manually"
read -p "Enter choice [1-4]: " vs_choice

case $vs_choice in
  1)
    echo "Granting 'Cloud Datastore User' (read/write)..."
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SA_EMAIL}" \
      --role="roles/datastore.user" \
      --condition=None
    echo "'Cloud Datastore User' role granted."
    ;;
  2)
    echo "Granting 'Cloud Datastore Viewer' (read-only)..."
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SA_EMAIL}" \
      --role="roles/datastore.viewer" \
      --condition=None
    echo "'Cloud Datastore Viewer' role granted."
    ;;
  3)
    echo "Skipping role grant. Please grant necessary Vertex AI Vector Search roles manually."
    echo "See documentation for roles like 'roles/aiplatform.viewer' or roles specific to endpoint querying."
    ;;
  *)
    echo "Skipping Vector Store role grant."
    ;;
esac


# 2. Verify Roles and Instruct User
echo "STEP 2: Displaying current roles for ${SA_EMAIL}..."
echo "Current Roles assigned to ${SA_EMAIL}:"
gcloud projects get-iam-policy "${GCP_PROJECT_ID}" \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:serviceAccount:${SA_EMAIL}"

echo ""
echo "--------------------- IMPORTANT ----------------------"
echo "ACTION REQUIRED: MANUAL VERIFICATION"
echo "1. REVIEW the roles listed above carefully."
echo "2. ENSURE only the intended roles are present:"
echo "   - 'roles/aiplatform.user' (from Objective 1.1)"
echo "   - The Vector Store role you just granted (if any)"
echo "   - Any other *intentionally* granted read-only roles."
echo "3. CONFIRM that NO unintended write roles (e.g., roles/editor, roles/owner,"
echo "   roles/storage.admin, roles/firebase.admin, etc.) are assigned."
echo "4. DOCUMENT the assigned roles and their justification for your records."
echo "   If incorrect roles are assigned, use 'gcloud projects remove-iam-policy-binding' to remove them."
echo "------------------------------------------------------"
echo "Objective 1.2 completed (Manual Verification Required)."