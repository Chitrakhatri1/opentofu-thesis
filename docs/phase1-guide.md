# Phase 1 Folder and Testing Guide

## Current status

The Phase 1 OpenTofu apply completed in the local workspace `phase1-tofu`. The local state currently records 15 AWS objects, including the AMI lookup, VPC, two subnets, internet gateway, route table, two route-table associations, security group, EC2 instance, S3 bucket, and four S3 configuration resources.

Formatting and OpenTofu configuration validation were successfully checked on 2026-09-26.

The most recent live verification attempt on 2026-09-26 could not contact AWS because the configured AWS security token was invalid or expired (`InvalidClientTokenId`). This is an authentication problem, not evidence that the infrastructure failed. Renew the AWS login before performing live checks or cleanup.

The deployed resources may continue to incur AWS charges while authentication is unavailable.

## 1. Workspace layout

```text
Thesis_Code/
  README.md
  THESIS_UNDERSTANDING.md
  THESIS_COMPLETION_PLAN.md
  Thesis_WorkingPlan_commented (1).pdf
  Aws/
    README.md
    .gitignore
    .github/workflows/validate.yml
    modules/
      network/
      compute/
      storage/
      load-balancer/
    environments/aws-baseline/
    docs/
    experiments/
    second-provider/
    legacy/
  thesis/
```

## 2. Top-level files and folders

### `README.md`

This is the entry point for the entire workspace. It explains where the infrastructure, research plan, and writing material are stored.

### `THESIS_UNDERSTANDING.md`

This explains the research problem, recommended scope, research questions, methodology, initial code assessment, and thesis risks.

### `THESIS_COMPLETION_PLAN.md`

This is the accelerated seven-phase schedule for completing the implementation, collecting results, preparing the professor meeting, and beginning the thesis chapters.

### `Thesis_WorkingPlan_commented (1).pdf`

This is the original thesis plan with supervisor comments. It remains the source document against which implementation progress is mapped.

### `thesis/`

This is the writing workspace. Its subfolders separate chapters, literature notes, figures, tables, and meeting notes. It does not contain infrastructure code.

### `Aws/`

This contains the complete Infrastructure-as-Code artifact, technical documentation, experiment structure, CI workflow, old prototype, and future second-provider implementation.

## 3. AWS implementation folders

### `Aws/modules/network/`

Purpose: reusable AWS networking module.

- `main.tf` creates the VPC, internet gateway, two or more public subnets, public route table, default internet route, and route-table associations.
- `variables.tf` defines and validates the module inputs.
- `outputs.tf` exposes the VPC, subnet, and route-table IDs to other modules.
- `versions.tf` declares supported Terraform/OpenTofu and AWS provider versions.

Thesis contribution: satisfies the networking part of Experimental Setup Phase 1 and part of the modularization goal in Phase 2.

### `Aws/modules/compute/`

Purpose: reusable demonstration-compute module.

- `main.tf` looks up the current Amazon Linux 2023 AMI, creates a security group, launches one encrypted EC2 instance, and installs an Apache demonstration page using user data.
- `variables.tf` defines the VPC, subnet, instance size, allowed HTTP CIDRs, names, and tags.
- `outputs.tf` exposes the instance ID, public address, security group ID, and AMI ID.
- `versions.tf` declares compatible tool and provider versions.

Security behavior:

- HTTP ingress is disabled when `allowed_http_cidrs` is empty.
- If enabled, HTTP should be restricted to the researcher's public IPv4 address with `/32`.
- Instance metadata requires IMDSv2 tokens.
- The root volume is encrypted.

Thesis contribution: satisfies the EC2 and security-group parts of Experimental Setup Phase 1 and the compute modularization goal.

### `Aws/modules/storage/`

Purpose: reusable S3 storage module.

- `main.tf` creates a uniquely named S3 bucket, enforced bucket ownership, public-access blocking, AES-256 server-side encryption, and versioning.
- `variables.tf` controls naming, tags, and safe destruction behavior.
- `outputs.tf` returns the bucket name and ARN.
- `versions.tf` declares compatible tool and provider versions.

Thesis contribution: satisfies the S3 part of Experimental Setup Phase 1, the storage modularization goal, and basic security controls.

### `Aws/modules/load-balancer/`

Purpose: reserved for Phase 2.

Only a README placeholder currently exists. No Application Load Balancer, listener, or target group has been implemented yet.

Thesis impact: the Application Load Balancer item in the original Phase 1 experimental setup is not yet complete.

### `Aws/environments/aws-baseline/`

Purpose: root configuration used for the direct Terraform-versus-OpenTofu experiment.

- `main.tf` connects the network, compute, and storage modules.
- `provider.tf` configures AWS and applies common tags.
- `variables.tf` defines environment-wide inputs and defaults.
- `outputs.tf` exposes the deployed VPC, subnets, EC2 instance, URL, AMI, and bucket.
- `versions.tf` pins tool compatibility and the AWS provider major version.
- `terraform.tfvars.example` is a safe template for local variables.
- `terraform.tfvars` is the private local variable file and must not be committed.
- `.terraform.lock.hcl` records the selected provider version and checksums.
- `.tofu-data/` contains OpenTofu's local cache and workspace selection.
- `.terraform-data/` contains Terraform's separate local cache.
- `terraform.tfstate.d/phase1-tofu/terraform.tfstate` is the local OpenTofu state for the deployed Phase 1 workspace. It must remain private and must not be edited manually.
- `opentofu.tfplan` is the saved plan that was applied. It is local evidence but may become stale after configuration or state changes.

The separate OpenTofu and Terraform data directories prevent the two tools from sharing plugin caches during comparison trials.

### `Aws/.github/workflows/validate.yml`

Purpose: CI validation for both tools.

The workflow checks formatting, initializes without a backend, and validates the same root configuration with OpenTofu 1.10.7 and Terraform 1.5.7.

Thesis contribution: begins the CI/CD integration phase. It does not deploy AWS resources and does not require AWS credentials.

### `Aws/docs/`

- `architecture.md` describes the Phase 1 architecture and design rules.
- `experiment-protocol.md` lists evidence required for each formal trial.
- `metric-definitions.md` defines migration, timing, success, idempotence, and extensibility metrics.
- `migration-log.md` records compatibility observations and required changes.
- `new-aws-account-runbook.md` is the full account setup, deployment, verification, idempotence, cleanup, and Terraform repetition procedure.
- `phase1-guide.md` is this folder and testing guide.

### `Aws/experiments/`

This contains placeholders for Phase 3 automation and results:

- `scripts/` will contain repeatable experiment scripts.
- `results/raw/` will hold private raw logs and must not be committed.
- `results/processed/` will hold sanitized datasets suitable for the thesis.

No automated experiment runner or formal dataset exists yet.

### `Aws/second-provider/`

This is reserved for the bounded Azure or GCP implementation. The second provider has not been selected or implemented yet.

### `Aws/legacy/`

This preserves the original proof-of-concept files. These files are historical evidence and should not be used for the current deployment.

## 4. Mapping Phase 1 to the thesis plan

| Thesis-plan item | Phase 1 status | Notes |
|---|---|---|
| AWS VPC | Complete | Implemented in the network module. |
| Subnets | Complete for baseline | Two public subnets in separate availability zones. |
| Internet gateway | Complete | Implemented in the network module. |
| Route tables | Complete | Public route and associations implemented. |
| Security groups | Complete for direct Phase 1 test | HTTP is disabled by default or restricted by CIDR. |
| EC2 instance | Complete | Amazon Linux 2023 instance with an Apache test page. |
| S3 object storage | Complete | Private, encrypted, versioned bucket. |
| Application Load Balancer | Not complete | Reserved for Phase 2. |
| Network module | Complete for baseline | Reusable module created. |
| Compute module | Complete for baseline | Reusable module created. |
| Storage module | Complete for baseline | Reusable module created. |
| Load-balancer module | Not complete | Placeholder only. |
| GitHub Actions | Initial implementation complete | Format and validation only. |
| Terraform/OpenTofu compatibility | Partially demonstrated | Both initialized and validated; formal repeated trials are pending. |
| Migration measurement | Scaffold only | Log and metrics exist; formal data collection is pending. |
| Multi-cloud provider | Not started | Planned for Phase 5. |
| Policy-as-code/security experiment | Out of implementation scope | Basic secure defaults exist; theoretical comparison recommended. |
| State strategy | Local Phase 1 state only | Formal portability procedure is not yet complete. |

## 5. Test the implementation one step at a time

Run all commands from the same terminal so that environment variables remain active.

### Step 1 - Enter the root environment

```bash
cd /Users/chitrakhatri/Documents/Thesis_Code/Aws/environments/aws-baseline
```

### Step 2 - Renew AWS authentication

The last verification failed because the token was invalid. If the named SSO profile is `thesis`, run:

```bash
aws sso login --profile thesis
export AWS_PROFILE=thesis
export AWS_REGION=eu-central-1
```

Then verify the identity:

```bash
aws sts get-caller-identity
```

Confirm that the account is the intended thesis account and that the ARN is not the AWS root user. Do not proceed if the identity is unexpected.

If static environment credentials were used instead of SSO, replace or unset the expired values securely. Never place credentials in `.tf`, `.tfvars`, shell scripts, logs, Git, or thesis documents.

### Step 3 - Select OpenTofu's private data directory

```bash
export TF_DATA_DIR=.tofu-data
```

Confirm the workspace:

```bash
tofu workspace show
```

Expected result:

```text
phase1-tofu
```

Stop if another workspace is selected.

### Step 4 - Check formatting

```bash
tofu fmt -check -recursive ../..
```

Success returns to the prompt with exit code `0` and normally prints nothing.

### Step 5 - Initialize dependencies

```bash
tofu init
```

Expected provider: AWS `5.100.0` from `.terraform.lock.hcl`. Record unexpected provider or signing warnings in `Aws/docs/migration-log.md`.

### Step 6 - Validate configuration

```bash
tofu validate
```

Expected result:

```text
Success! The configuration is valid.
```

This tests configuration structure, not live AWS health.

### Step 7 - Inspect managed state

```bash
tofu state list
tofu output
```

The current state should list 15 addresses. The outputs should include the VPC, two subnets, instance, AMI, URL, and bucket. Do not publish unredacted state or raw logs.

### Step 8 - Confirm the EC2 instance is live

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=opentofu-thesis" "Name=instance-state-name,Values=pending,running" \
  --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name,Type:InstanceType,PublicIp:PublicIpAddress}'
```

Expected result: one `t3.micro` instance in `running` state.

### Step 9 - Confirm S3 security settings

```bash
THESIS_BUCKET=$(tofu output -raw bucket_name)
aws s3api get-public-access-block --bucket "$THESIS_BUCKET"
aws s3api get-bucket-encryption --bucket "$THESIS_BUCKET"
aws s3api get-bucket-versioning --bucket "$THESIS_BUCKET"
```

Expected results:

- all four public-access-block values are `true`;
- server-side encryption reports `AES256`;
- versioning reports `Enabled`.

### Step 10 - Test the demonstration web page

First inspect `terraform.tfvars`. The `allowed_http_cidrs` value must contain the computer's current public IPv4 address with `/32`. If the list is empty, the web page being unreachable is expected and is not a deployment failure.

When the current address is allowed:

```bash
THESIS_URL=$(tofu output -raw instance_url)
curl --fail --retry 12 --retry-delay 10 "$THESIS_URL"
```

Expected text:

```text
OpenTofu thesis baseline
Provisioned successfully.
```

### Step 11 - Test idempotence

```bash
tofu plan -detailed-exitcode
echo $?
```

Interpretation:

- `0`: configuration and live infrastructure match; Phase 1 is idempotent.
- `1`: command or authentication error.
- `2`: OpenTofu proposes changes; inspect the plan for drift before applying anything.

Do not run `tofu apply` merely to hide unexplained drift. Record the result first.

### Step 12 - Check GitHub Actions

The workflow runs only when `Aws/` is the root of the GitHub repository or when the workflow paths are adapted to the actual repository root. Push a clean branch or open a pull request, then confirm both jobs pass:

- OpenTofu validation;
- Terraform validation.

CI validates code but does not prove that AWS resources can be deployed.

### Step 13 - Destroy when testing is finished

Because the EC2 instance is billable, do not leave the environment running unnecessarily.

```bash
tofu destroy
```

Review the destruction plan before confirming. Then verify:

```bash
tofu state list
```

Expected result: no output.

Also check the AWS console for remaining EC2 instances, VPC components, S3 buckets, load balancers, NAT gateways, and Elastic IPs associated with the thesis project.

## 6. Phase 1 completion decision

Phase 1 can be marked complete only when:

- authentication works;
- `tofu validate` succeeds;
- all expected AWS resources are live and correctly configured;
- the web page works when intentionally enabled;
- the no-change plan exits with code `0`;
- cleanup succeeds and leaves no managed resources;
- the same configuration is then tested using Terraform in its separate workspace;
- results and compatibility observations are recorded.

At present, the local apply is confirmed, but live health, idempotence, and cleanup are not confirmed because AWS authentication must be renewed.
