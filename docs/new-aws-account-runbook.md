# New AWS Account Setup and Phase 1 Test Runbook

Use this runbook to prepare a new AWS account, authenticate with short-lived credentials, deploy the Phase 1 baseline, verify it, test idempotence, and remove all resources.

The baseline creates billable resources. Prices and free-tier eligibility change. Review the AWS Pricing pages for the chosen region and do not assume that `t3.micro` or any other resource is free.

## 1. Secure the new account

Complete these steps in the AWS console before running infrastructure code:

1. Sign in once as the AWS account root user.
2. Enable multi-factor authentication for the root user.
3. Confirm that the root user has no access keys.
4. Enable IAM Identity Center and create a separate administrative identity for yourself.
5. Assign an administrative permission set for this initial isolated thesis account. Reduce permissions after the prototype is stable.
6. Sign out of the root user and use the administrative identity for normal work.
7. Keep the root email address, recovery information, and MFA device secure.

AWS recommends MFA for the root user, avoiding root credentials for daily work, and using IAM Identity Center/federation with temporary credentials:

- https://docs.aws.amazon.com/signin/latest/userguide/best-practices-admin.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started-account-iam.html

Never create root access keys and never place credentials in `.tf`, `.tfvars`, shell scripts, GitHub, or thesis files.

## 2. Create cost controls

In the AWS Billing and Cost Management console:

1. Open **Budgets**.
2. Create a monthly cost budget with a deliberately small amount appropriate for the experiment.
3. Add email alerts below and at the budget threshold, for example at 50%, 80%, and 100%.
4. Confirm the notification email if AWS requests confirmation.
5. Optionally enable Cost Anomaly Detection.

AWS budget instructions:

- https://docs.aws.amazon.com/cost-management/latest/userguide/create-cost-budget.html

A budget sends alerts but does not automatically stop all resources. Cleanup is still mandatory.

## 3. Confirm local tools

On the development computer, check:

```bash
aws --version
tofu version
terraform version
```

This workspace was validated with:

- AWS CLI 2.34.13
- OpenTofu 1.10.7
- Terraform 1.5.7
- AWS provider 5.100.0

Using different versions is a change to the experimental environment and must be recorded.

## 4. Configure short-lived AWS CLI access

AWS CLI v2 can authenticate through IAM Identity Center without saving long-lived access keys.

Create a named profile:

```bash
aws configure sso --profile thesis
```

Follow the prompts to select the Identity Center session, thesis AWS account, administrative permission set, and default region. Use `eu-central-1` if you want to use the supplied variable file unchanged.

Start a session and select the profile for the current terminal:

```bash
aws sso login --profile thesis
export AWS_PROFILE=thesis
export AWS_REGION=eu-central-1
```

Verify the identity:

```bash
aws sts get-caller-identity
aws configure get region --profile thesis
```

Stop if:

- the returned account ID is not the new thesis account;
- the ARN identifies the root user;
- the region is not the intended test region.

AWS CLI Identity Center instructions:

- https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

OpenTofu and Terraform automatically use the selected AWS profile through the standard AWS credential chain. Credentials are intentionally absent from the provider configuration.

## 5. Prepare account-specific variables

From the workspace root:

```bash
cd Aws/environments/aws-baseline
cp terraform.tfvars.example terraform.tfvars
```

Review `terraform.tfvars` before continuing.

If using a region other than `eu-central-1`, change all three of these values:

- `aws_region`
- the first subnet's `availability_zone`
- the second subnet's `availability_zone`

Choose two availability zones that exist in the selected region.

Direct web access is disabled by default. To test the web page, find your current public IPv4 address and set only that address with a `/32` suffix:

```hcl
allowed_http_cidrs = ["203.0.113.10/32"]
```

Replace the example address; do not copy it literally. Do not use `0.0.0.0/0` for this Phase 1 direct-instance test.

Keep:

```hcl
force_destroy_bucket = false
```

This prevents accidental deletion of a bucket containing objects.

## 6. Format and initialize

Run from `Aws/environments/aws-baseline`:

```bash
export TF_DATA_DIR=.tofu-data
tofu fmt -check -recursive ../..
tofu init
tofu validate
```

Initialization must select AWS provider `5.100.0` from the committed dependency lock file. Investigate rather than accepting an unexpected provider change.

## 7. Use a dedicated local workspace

Create an isolated state namespace for the Phase 1 OpenTofu run:

```bash
tofu workspace new phase1-tofu
```

If it already exists:

```bash
tofu workspace select phase1-tofu
```

Confirm the selected workspace:

```bash
tofu workspace show
```

Do not run Terraform and OpenTofu concurrently against the same state.

## 8. Create and review the plan

```bash
tofu plan -out=opentofu.tfplan
tofu show opentofu.tfplan
```

The first clean plan should propose approximately 14 resources:

- one VPC;
- two public subnets;
- one internet gateway;
- one public route table and two associations;
- one security group;
- one EC2 instance;
- one S3 bucket plus ownership, public-access, encryption, and versioning configuration.

Do not apply if the plan contains unexpected replacements, public S3 access, credentials, a different region, or resources outside this list.

## 9. Apply

Apply the reviewed saved plan:

```bash
tofu apply opentofu.tfplan
```

List outputs:

```bash
tofu output
```

Save the command output as experiment evidence only after removing the AWS account ID and other sensitive details.

## 10. Verify the deployment

Check the EC2 instance:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=opentofu-thesis" "Name=instance-state-name,Values=pending,running" \
  --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name,Type:InstanceType,PublicIp:PublicIpAddress}'
```

Check that the S3 bucket is private and encrypted:

```bash
THESIS_BUCKET=$(tofu output -raw bucket_name)
aws s3api get-public-access-block --bucket "$THESIS_BUCKET"
aws s3api get-bucket-encryption --bucket "$THESIS_BUCKET"
aws s3api get-bucket-versioning --bucket "$THESIS_BUCKET"
```

If your `/32` address is in `allowed_http_cidrs`, wait briefly for EC2 user data to finish and test:

```bash
THESIS_URL=$(tofu output -raw instance_url)
curl --fail --retry 12 --retry-delay 10 "$THESIS_URL"
```

Expected page text includes `OpenTofu thesis baseline`.

## 11. Test idempotence

After the deployment is stable, run:

```bash
tofu plan -detailed-exitcode
```

Interpret the exit code:

- `0` - success with no infrastructure changes; expected idempotent result.
- `1` - command error.
- `2` - the plan proposes changes; investigate drift or unstable configuration.

Record the complete result and exit code in the experiment log.

## 12. Destroy and verify cleanup

Destroy with the same tool, directory, profile, and workspace used for apply:

```bash
tofu destroy
```

If destroy reports a non-empty S3 bucket, remove only the experiment objects you intentionally uploaded, then rerun destroy. Do not enable `force_destroy` merely to bypass an unexplained deletion problem.

Verify that the state contains no managed resources:

```bash
tofu state list
```

The command should print nothing.

Check the AWS console in the selected region for remaining:

- running or stopped EC2 instances;
- load balancers or target groups;
- Elastic IP addresses;
- NAT gateways;
- thesis VPCs and related network resources;
- S3 buckets with the thesis prefix.

Budgets can report usage with a delay, so do not treat a zero current total as proof of cleanup.

## 13. Repeat with Terraform

Only after the OpenTofu deployment has been destroyed, create a separate Terraform workspace:

```bash
export TF_DATA_DIR=.terraform-data
terraform init
terraform validate
terraform workspace new phase1-terraform
terraform plan -out=terraform.tfplan
terraform apply terraform.tfplan
terraform output
terraform plan -detailed-exitcode
terraform destroy
```

If the workspace already exists, use `terraform workspace select phase1-terraform` instead of creating it.

Record all compatibility warnings and code changes in `Aws/docs/migration-log.md`. Do not change the infrastructure configuration between tool runs unless the change itself is documented as a migration requirement.

## 14. End the AWS session

When finished:

```bash
aws sso logout
unset TF_DATA_DIR
unset AWS_PROFILE
unset AWS_REGION
```

Keep `terraform.tfvars`, state, saved plans, and raw logs local. They are ignored by Git.

## 15. Common failures

### `ExpiredToken` or SSO credential errors

```bash
aws sso login --profile thesis
export AWS_PROFILE=thesis
```

Then verify again with `aws sts get-caller-identity`.

### Invalid availability zone

The subnet zones do not belong to `aws_region`. List zones:

```bash
aws ec2 describe-availability-zones --region "$AWS_REGION" --query 'AvailabilityZones[?State==`available`].ZoneName'
```

Update both subnet entries in `terraform.tfvars`.

### Unauthorized operation

Confirm the SSO profile selected the intended account and permission set. Do not work around the problem with root access keys.

### S3 bucket cannot be destroyed

The bucket contains an object or version. Inspect it first. Delete only experiment data and versions, then retry destroy.

### Web page does not load

Check that:

- your current public IPv4 address still matches the `/32` value;
- the instance is running and passed status checks;
- the EC2 bootstrap has had time to install Apache;
- the security group contains the intended port 80 rule;
- local or corporate network rules allow outbound HTTP.
