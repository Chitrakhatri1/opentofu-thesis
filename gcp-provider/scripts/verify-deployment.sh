#!/usr/bin/env bash
set -euo pipefail

tool="${1:-tofu}"

if [[ "${tool}" != "tofu" && "${tool}" != "terraform" ]]; then
  echo "Usage: $0 [tofu|terraform]" >&2
  exit 2
fi

for command_name in "${tool}" gcloud; do
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

uniform_access="$(gcloud storage buckets describe "gs://${bucket_name}" \
  --project "${project_id}" \
  --format='value(iamConfiguration.uniformBucketLevelAccess.enabled)')"

public_access_prevention="$(gcloud storage buckets describe "gs://${bucket_name}" \
  --project "${project_id}" \
  --format='value(iamConfiguration.publicAccessPrevention)')"

versioning_enabled="$(gcloud storage buckets describe "gs://${bucket_name}" \
  --project "${project_id}" \
  --format='value(versioning.enabled)')"

uniform_access="$(printf '%s' "${uniform_access}" | tr '[:upper:]' '[:lower:]')"
public_access_prevention="$(printf '%s' "${public_access_prevention}" | tr '[:upper:]' '[:lower:]')"
versioning_enabled="$(printf '%s' "${versioning_enabled}" | tr '[:upper:]' '[:lower:]')"

[[ -n "${subnet_region}" ]] || {
  echo "ERROR: Subnet region could not be verified." >&2
  exit 1
}

[[ "${uniform_access}" == "true" ]] || {
  echo "ERROR: Uniform bucket-level access is not enabled." >&2
  exit 1
}

[[ "${public_access_prevention}" == "enforced" ]] || {
  echo "ERROR: Public access prevention is not enforced." >&2
  exit 1
}

[[ "${versioning_enabled}" == "true" ]] || {
  echo "ERROR: Bucket versioning is not enabled." >&2
  exit 1
}

echo "GCP deployment verification passed."
echo "Project: ${project_id}"
echo "Network: ${network_name}"
echo "Subnet: ${subnet_name} (${subnet_region})"
echo "Bucket: ${bucket_name}"
echo "Storage controls: public access prevention enforced, uniform access enabled, versioning enabled"
