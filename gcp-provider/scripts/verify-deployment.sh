#!/usr/bin/env bash
set -euo pipefail

tool="${1:-tofu}"

if [[ "${tool}" != "tofu" && "${tool}" != "terraform" ]]; then
  echo "Usage: $0 [tofu|terraform]" >&2
  exit 2
fi

for command_name in "${tool}" gcloud grep; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "ERROR: Required command not found: ${command_name}" >&2
    exit 1
  fi
done

project_id="$(${tool} output -raw project_id)"
region="$(${tool} output -raw region)"
network_name="$(${tool} output -raw network_name)"
subnet_name="$(${tool} output -raw subnet_name)"
bucket_name="$(${tool} output -raw bucket_name)"

gcloud compute networks describe "${network_name}" \
  --project "${project_id}" \
  --format='value(name)' >/dev/null

subnet_region="$(gcloud compute networks subnets describe "${subnet_name}" \
  --project "${project_id}" \
  --region "${region}" \
  --format='value(region.basename())')"

gcloud storage buckets describe "gs://${bucket_name}" \
  --project "${project_id}" \
  --format='value(name)' >/dev/null

storage_state="$(${tool} state show module.storage.google_storage_bucket.this)"

[[ -n "${subnet_region}" ]] || {
  echo "ERROR: Subnet region could not be verified." >&2
  exit 1
}

grep -Eq 'uniform_bucket_level_access[[:space:]]*=[[:space:]]*true' <<<"${storage_state}" || {
  echo "ERROR: Uniform bucket-level access is not enabled." >&2
  exit 1
}

grep -Eq 'public_access_prevention[[:space:]]*=[[:space:]]*"enforced"' <<<"${storage_state}" || {
  echo "ERROR: Public access prevention is not enforced." >&2
  exit 1
}

grep -Eq 'enabled[[:space:]]*=[[:space:]]*true' <<<"${storage_state}" || {
  echo "ERROR: Bucket versioning is not enabled." >&2
  exit 1
}

echo "GCP deployment verification passed."
echo "Project: ${project_id}"
echo "Network: ${network_name}"
echo "Subnet: ${subnet_name} (${subnet_region})"
echo "Bucket: ${bucket_name}"
echo "Storage controls: public access prevention enforced, uniform access enabled, versioning enabled"
