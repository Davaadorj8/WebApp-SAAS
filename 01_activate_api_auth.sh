```bash
#!/bin/bash
set -euo pipefail

# Changes:
# Added:   gcloud CLI availability check; trap to clean up partial key files
# Changed: merged sed calls for sanitization; all "$VAR" properly quoted; replaced fixed sleep with polling
# Removed: fixed sleep 8; invalid --condition=None flag; duplicate overwrite prompts

# --- Fail fast if gcloud missing ---
command -v gcloud >/dev/null || { echo "ERROR: gcloud CLI not found." >&2; exit 1; }

# --- Cleanup on error ---
trap 'if [ $? -ne 0 ] && [ -n "${KEY_FILE_PATH:-}" ] && [ -f "$KEY_FILE_PATH" ]; then rm -f "$KEY_FILE_PATH"; fi' EXIT

sanitize_for_sa_id() {
  local name="$1"
  name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | \
    sed -E 's/[^a-z0-9-]+/-/g; s/^-|-$//g')
  name=${name:0:30}
  name=$(echo "$name" | sed -E 's/-$//')
  [ -z "$name" ] && { echo "ERROR: Sanitized name is empty." >&2; exit 1; }
  [ ${#name} -lt 6 ] && echo "Warning: ID '$name' may be shorter than 6 chars." >&2
  echo "$name"
}

# --- Config ---
echo "Fetching GCP Project ID and User Account…"
GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
GCP_USER_ACCOUNT=$(gcloud config get-value account 2>/dev/null)

[ -z "$GCP_PROJECT_ID" ] && { echo "ERROR: Project ID not set. Use: gcloud config set project <ID>" >&2; exit 1; }
[ -z "$GCP_USER_ACCOUNT" ] && { echo "ERROR: No user account. Run: gcloud auth login" >&2; exit 1; }

echo "Project: $GCP_PROJECT_ID"
echo "User: $GCP_USER_ACCOUNT"

# --- Prompts ---
while :; do
  read -p "Service Account Display Name: " SA_NAME
  [ -n "$SA_NAME" ] && break || echo "Name cannot be empty." >&2
done

SA_ID=$(sanitize_for_sa_id "$SA_NAME")
SA_EMAIL="${SA_ID}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
echo "Service Account ID: $SA_ID"

while :; do
  read -p "Key file path (e.g., ./sa-key.json): " KEY_FILE_PATH
  [ -n "$KEY_FILE_PATH" ] || { echo "Path cannot be empty." >&2; continue; }
  [[ "$KEY_FILE_PATH" == *.json ]] || KEY_FILE_PATH="${KEY_FILE_PATH}.json"
  [ -d "$KEY_FILE_PATH" ] && { echo "Error: '$KEY_FILE_PATH' is a directory." >&2; continue; }
  if [ -f "$KEY_FILE_PATH" ]; then
    read -p "Overwrite '$KEY_FILE_PATH'? (y/N): " resp
    [[ "$resp" =~ ^[Yy] ]] && break || continue
  else
    break
  fi
done

echo "--------------------------------------------------"
echo "Proceed with:"
echo " Project: $GCP_PROJECT_ID"
echo " Service Account: $SA_EMAIL"
echo " Key file: $KEY_FILE_PATH"
read -p "Proceed? (y/N): " confirm
[[ "$confirm" =~ ^[Yy] ]] || { echo "Aborted."; exit 1; }

# 1. Enable Vertex AI API
echo "STEP 1: Enabling Vertex AI API…"
if ! gcloud services list --enabled --filter="vertexai.googleapis.com" --project="$GCP_PROJECT_ID" --format="value(name)" | grep -q .; then
  gcloud services enable vertexai.googleapis.com --project="$GCP_PROJECT_ID"
  echo "Vertex AI API enabled."
else
  echo "Already enabled."
fi

# 2. Create Service Account
echo "STEP 2: Creating Service Account if needed…"
if ! gcloud iam service-accounts describe "$SA_EMAIL" --project="$GCP_PROJECT_ID" &>/dev/null; then
  gcloud iam service-accounts create "$SA_ID" \
    --display-name="$SA_NAME" \
    --description="Service Account for Firebase Gemini Orchestrator" \
    --project="$GCP_PROJECT_ID"
  # Poll until propagation
  until gcloud iam service-accounts describe "$SA_EMAIL" --project="$GCP_PROJECT_ID" &>/dev/null; do sleep 1; done
  echo "Service Account created."
else
  echo "Exists. Skipping creation."
fi

# 3. Grant Vertex AI User role
echo "STEP 3: Granting roles/aiplatform.user…"
if ! gcloud projects get-iam-policy "$GCP_PROJECT_ID" \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:$SA_EMAIL AND bindings.role:roles/aiplatform.user" \
     --format="value(bindings.role)" | grep -q .; then
  gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/aiplatform.user"
  echo "Role granted."
else
  echo "Role already present."
fi

# 4. Grant Token Creator to user
echo "STEP 4: Granting roles/iam.serviceAccountTokenCreator…"
if ! gcloud iam service-accounts get-iam-policy "$SA_EMAIL" --project="$GCP_PROJECT_ID" \
     --flatten="bindings[].members" \
     --filter="bindings.members:user:$GCP_USER_ACCOUNT AND bindings.role:roles/iam.serviceAccountTokenCreator" \
     --format="value(bindings.role)" | grep -q .; then
  gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
    --member="user:$GCP_USER_ACCOUNT" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --project="$GCP_PROJECT_ID"
  echo "Role granted."
else
  echo "Role already present."
fi

# 5. Create and download key
echo "STEP 5: Creating key…"
mkdir -p "$(dirname "$KEY_FILE_PATH")"
gcloud iam service-accounts keys create "$KEY_FILE_PATH" \
  --iam-account="$SA_EMAIL" \
  --project="$GCP_PROJECT_ID"
echo "Key written to $KEY_FILE_PATH."

# 6. Optional: Configure gcloud impersonation
echo "STEP 6: Configure default impersonation? (y/N):"
read -r resp
if [[ "$resp" =~ ^[Yy] ]]; then
  gcloud config set auth/impersonate_service_account "$SA_EMAIL"
  echo "Impersonation configured."
else
  echo "Skipped impersonation."
fi

# 7. Summary
echo -e "\n--- Complete. Secure your key and set GOOGLE_APPLICATION_CREDENTIALS as needed. ---"
```