#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <project-id> <network-name> <bucket-name>" >&2
  exit 2
fi

project_id="$1"
network_name="$2"
bucket_name="$3"

for value_name in project_id network_name bucket_name; do
  if [[ -z "${!value_name}" ]]; then
    echo "ERROR: ${value_name} must not be empty." >&2
    exit 2
  fi
done

if ! command -v gcloud >/dev/null 2>&1; then
  echo "ERROR: Required command not found: gcloud" >&2
  exit 1
fi

if gcloud compute networks describe "${network_name}" \
  --project "${project_id}" >/dev/null 2>&1; then
  echo "ERROR: GCP network still exists: ${network_name}" >&2
  exit 1
fi

if gcloud storage buckets describe "gs://${bucket_name}" \
  --project "${project_id}" >/dev/null 2>&1; then
  echo "ERROR: GCP bucket still exists: ${bucket_name}" >&2
  exit 1
fi

echo "GCP cleanup verification passed."
echo "Network is absent: ${network_name}"
echo "Bucket is absent: ${bucket_name}"
