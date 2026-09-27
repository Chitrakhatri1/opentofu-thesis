#!/usr/bin/env bash
set -euo pipefail

tool="${1:-tofu}"
environment_dir="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../environments/aws-enterprise-lite" && pwd)}"

cd "${environment_dir}"

asg_name="$(${tool} output -raw autoscaling_group_name)"
bucket_name="$(${tool} output -raw bucket_name)"
alb_url="$(${tool} output -raw load_balancer_url)"

instance_id="$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${asg_name}" --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)"
test "${instance_id}" != "None"

public_ip="$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)"
test "${public_ip}" = "None"

profile_arn="$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text)"
test "${profile_arn}" != "None"

aws s3api get-public-access-block --bucket "${bucket_name}" --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' --output text | grep -q $'True\tTrue\tTrue\tTrue'
test "$(aws s3api get-bucket-versioning --bucket "${bucket_name}" --query Status --output text)" = "Enabled"

curl --fail --silent --show-error --retry 18 --retry-delay 10 "${alb_url}" | grep -q "OpenTofu enterprise-lite"
echo "AWS enterprise-lite deployment verification passed."
