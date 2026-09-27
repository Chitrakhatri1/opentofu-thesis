#!/usr/bin/env bash
set -euo pipefail

tool="${1:-tofu}"
environment_dir="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../environments/gcp-enterprise-lite" && pwd)}"

cd "${environment_dir}"
project_id="$(${tool} output -raw project_id)"
region="$(${tool} output -raw region)"
network_name="$(${tool} output -raw network_name)"
subnet_name="$(${tool} output -raw subnet_name)"
bucket_name="$(${tool} output -raw bucket_name)"
service_account="$(${tool} output -raw service_account_email)"

test "$(gcloud compute networks describe "${network_name}" --project "${project_id}" --format='value(name)')" = "${network_name}"
test "$(gcloud compute networks subnets describe "${subnet_name}" --project "${project_id}" --region "${region}" --format='value(privateIpGoogleAccess)')" = "True"
test "$(gcloud iam service-accounts describe "${service_account}" --project "${project_id}" --format='value(email)')" = "${service_account}"
test "$(gcloud storage buckets describe "gs://${bucket_name}" --format='value(iamConfiguration.uniformBucketLevelAccess.enabled)')" = "True"

if [ "$(${tool} output -raw compute_enabled)" = "true" ]; then
  instance_name="$(${tool} output -raw instance_name)"
  external_ip="$(gcloud compute instances describe "${instance_name}" --project "${project_id}" --zone "${TF_VAR_zone:-us-central1-a}" --format='value(networkInterfaces[0].accessConfigs[0].natIP)')"
  test -z "${external_ip}"
fi

echo "GCP enterprise-lite deployment verification passed."
