#!/usr/bin/env bash
set -euo pipefail

project_id="${1:?project ID required}"
network_name="${2:?network name required}"
bucket_name="${3:?bucket name required}"
service_account="${4:?service-account email required}"

if gcloud compute networks describe "${network_name}" --project "${project_id}" >/dev/null 2>&1; then
  echo "ERROR: Network still exists: ${network_name}" >&2
  exit 1
fi
if gcloud storage buckets describe "gs://${bucket_name}" >/dev/null 2>&1; then
  echo "ERROR: Bucket still exists: ${bucket_name}" >&2
  exit 1
fi
if gcloud iam service-accounts describe "${service_account}" --project "${project_id}" >/dev/null 2>&1; then
  echo "ERROR: Service account still exists: ${service_account}" >&2
  exit 1
fi

echo "GCP enterprise-lite cleanup verification passed."
