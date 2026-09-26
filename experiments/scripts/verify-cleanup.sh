#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

configure_tool "${1:-}"
require_environment
select_expected_workspace

state_count=$({ "${TOOL}" state list 2>/dev/null || true; } | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
instance_count=$(aws ec2 describe-instances \
  --filters Name=tag:Project,Values=opentofu-thesis Name=instance-state-name,Values=pending,running,stopping,stopped \
  --query 'length(Reservations[].Instances[])' --output text)
vpc_count=$(aws ec2 describe-vpcs \
  --filters Name=tag:Project,Values=opentofu-thesis \
  --query 'length(Vpcs[])' --output text)
alb_count=$(aws elbv2 describe-load-balancers \
  --query 'length(LoadBalancers[?contains(LoadBalancerName, `opentofu-thesis`)])' --output text)
bucket_count=$(aws s3api list-buckets \
  --query "length(Buckets[?starts_with(Name, 'opentofu-thesis-experiment-')])" --output text)

printf 'state_resources=%s\n' "${state_count}"
printf 'active_instances=%s\n' "${instance_count}"
printf 'thesis_vpcs=%s\n' "${vpc_count}"
printf 'thesis_load_balancers=%s\n' "${alb_count}"
printf 'thesis_buckets=%s\n' "${bucket_count}"

if [[ "${state_count}" != "0" || "${instance_count}" != "0" || "${vpc_count}" != "0" || "${alb_count}" != "0" || "${bucket_count}" != "0" ]]; then
  die "Cleanup verification failed. Do not begin another trial."
fi

printf 'Cleanup verification passed for %s.\n' "${TOOL}"
