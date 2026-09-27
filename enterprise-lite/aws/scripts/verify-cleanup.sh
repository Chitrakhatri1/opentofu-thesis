#!/usr/bin/env bash
set -euo pipefail

project_name="${1:-opentofu-thesis}"

vpcs="$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=${project_name}" "Name=tag:Architecture,Values=EnterpriseLite" --query 'length(Vpcs[])' --output text)"
instances="$(aws ec2 describe-instances --filters "Name=tag:Project,Values=${project_name}" "Name=tag:Architecture,Values=EnterpriseLite" "Name=instance-state-name,Values=pending,running,stopping,stopped" --query 'length(Reservations[].Instances[])' --output text)"
load_balancers="$(aws elbv2 describe-load-balancers --query 'length(LoadBalancers[?contains(LoadBalancerName, `enterprise`)])' --output text)"

test "${vpcs}" = "0"
test "${instances}" = "0"
test "${load_balancers}" = "0"
echo "AWS enterprise-lite cleanup verification passed."
