#!/usr/bin/env bash
set -euo pipefail

tool="${1:-tofu}"
environment_dir="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../environments/aws-enterprise-lite" && pwd)}"

cd "${environment_dir}"

asg_name="$(${tool} output -raw autoscaling_group_name)"
bucket_name="$(${tool} output -raw bucket_name)"
alb_url="$(${tool} output -raw load_balancer_url)"
target_group_arn="$(${tool} output -raw target_group_arn)"

instance_id="None"
target_health="initial"
for _ in $(seq 1 36); do
  instance_id="$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${asg_name}" --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)"
  if [[ "${instance_id}" != "None" ]]; then
    target_health="$(aws elbv2 describe-target-health --target-group-arn "${target_group_arn}" --query 'TargetHealthDescriptions[0].TargetHealth.State' --output text)"
    [[ "${target_health}" == "healthy" ]] && break
  fi
  sleep 10
done

test "${instance_id}" != "None"
test "${target_health}" = "healthy"

public_ip="$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"
test "${public_ip}" = "None"

profile_arn="$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text)"
test "${profile_arn}" != "None"

aws s3api get-public-access-block --bucket "${bucket_name}" --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' --output text | grep -q $'True\tTrue\tTrue\tTrue'
test "$(aws s3api get-bucket-versioning --bucket "${bucket_name}" --query Status --output text)" = "Enabled"

curl --fail --silent --show-error --retry 18 --retry-delay 10 --retry-connrefused "${alb_url}" | grep -q "OpenTofu enterprise-lite"
echo "AWS enterprise-lite deployment verification passed."
