# OpenTofu Thesis Infrastructure

This directory contains the reproducible infrastructure artifact for comparing Terraform and OpenTofu.

## Structure

```text
modules/                    Reusable AWS modules
  network/                  VPC, public subnets, routing
  compute/                  EC2 web instance and security group
  storage/                  Private, encrypted, versioned S3 bucket
  load-balancer/            Application Load Balancer, listener, target group
environments/
  aws-baseline/             Root configuration used by both tools
experiments/
  scripts/                  Experiment automation added in Phase 3
  results/raw/              Ignored raw command output
  results/processed/        Sanitized thesis datasets
docs/                       Architecture and experiment documentation
second-provider/            Bounded Azure or GCP extension in Phase 5
legacy/                     Preserved initial proof-of-concept code
.github/workflows/          CI validation
```

## Current Phase 1 baseline

The baseline composes four modules:

- A VPC with two public subnets in separate availability zones.
- One Amazon Linux 2023 EC2 instance running a simple Apache page.
- One private S3 bucket with server-side encryption and versioning.
- One public Application Load Balancer with an HTTP listener and health-checked target group.

Set `allowed_http_cidrs` to your public IPv4 address with a `/32` suffix. This permits access to the load balancer. Direct HTTP access to the EC2 instance is blocked; the instance accepts port 80 only from the load-balancer security group.

## Requirements

- Terraform 1.5 or later, or OpenTofu 1.5 or later.
- AWS provider 5.x.
- AWS credentials configured locally.
- An AWS account with permission to manage VPC, EC2, IAM read-only identity checks, SSM parameter reads, and S3 resources used by this configuration.

## Local setup

```bash
cd environments/aws-baseline
cp terraform.tfvars.example terraform.tfvars
export TF_DATA_DIR=.tofu-data
tofu fmt -check -recursive ../..
tofu init
tofu validate
tofu plan -out=opentofu.tfplan
```

Terraform uses the same configuration:

```bash
export TF_DATA_DIR=.terraform-data
terraform init
terraform validate
terraform plan -out=terraform.tfplan
```

The separate data directories keep each tool's plugin cache independent, which makes cold-cache and warm-cache trials easier to control. Do not apply both plans at the same time. During the formal experiment, use the state-handling procedure documented in `docs/experiment-protocol.md`.

## Cost and cleanup

This configuration creates billable AWS resources, including an Application Load Balancer. Review current pricing and the plan before applying. After testing, run the destroy command with the same tool and state used for the apply:

```bash
tofu destroy
```

The S3 bucket uses `force_destroy = false` by default. Empty the bucket before destroy if test objects were uploaded.

Never commit credentials, `terraform.tfvars`, plan files, state files, or raw logs containing account details.
