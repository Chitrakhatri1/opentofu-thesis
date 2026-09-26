#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

configure_tool "${1:-}"
require_environment
select_expected_workspace

state_count=$("${TOOL}" state list | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
[[ "${state_count}" -ge 20 ]] || die "Expected at least 20 state addresses including the AMI data source; found ${state_count}."

alb_url=$("${TOOL}" output -raw load_balancer_url)
bucket_name=$("${TOOL}" output -raw bucket_name)
target_group_arn=$(aws elbv2 describe-target-groups \
  --names opentofu-thesis-experiment-web \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

[[ -n "${target_group_arn}" && "${target_group_arn}" != "None" ]] || die "Target group was not found."

target_state=unknown
for _ in $(seq 1 24); do
  target_state=$(aws elbv2 describe-target-health \
    --target-group-arn "${target_group_arn}" \
    --query 'TargetHealthDescriptions[0].TargetHealth.State' --output text)

  if [[ "${target_state}" == "healthy" ]]; then
    break
  fi

  sleep 10
done

[[ "${target_state}" == "healthy" ]] || die "ALB target did not become healthy; final state: ${target_state}"

page=$(curl --fail --silent --show-error --retry 12 --retry-delay 10 "${alb_url}")
grep -q 'OpenTofu thesis baseline' <<<"${page}" || die "ALB response did not contain the expected demonstration text."

public_block=$(aws s3api get-public-access-block \
  --bucket "${bucket_name}" \
  --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' \
  --output text)
encryption=$(aws s3api get-bucket-encryption \
  --bucket "${bucket_name}" \
  --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
  --output text)
versioning=$(aws s3api get-bucket-versioning \
  --bucket "${bucket_name}" \
  --query 'Status' --output text)

[[ "${public_block}" == $'True\tTrue\tTrue\tTrue' ]] || die "S3 public-access block is incomplete: ${public_block}"
[[ "${encryption}" == "AES256" ]] || die "Unexpected S3 encryption setting: ${encryption}"
[[ "${versioning}" == "Enabled" ]] || die "S3 versioning is not enabled: ${versioning}"

printf 'Deployment verification passed.\n'
printf 'state_addresses=%s\n' "${state_count}"
printf 'target_health=%s\n' "${target_state}"
printf 'alb_url=%s\n' "${alb_url}"
printf 's3_public_access_block=enabled\n'
printf 's3_encryption=%s\n' "${encryption}"
printf 's3_versioning=%s\n' "${versioning}"
