# Enterprise-Lite Thesis Extension

This directory is an isolated extension of the completed AWS and GCP baselines. It applies enterprise patterns observed in the professor-provided Azure reference without copying its credentials, state, provider binaries, paid firewall/VPN/desktop services, or Azure-specific resources.

The original baseline code and evidence remain unchanged.

## Architecture

### AWS

- VPC with two public and two private subnets.
- Public Application Load Balancer.
- One private EC2 workload managed by a launch template and Auto Scaling Group.
- IAM role and instance profile; no embedded cloud credentials.
- Private, encrypted, versioned S3 bucket with lifecycle cleanup.
- Free S3 gateway endpoint; no NAT Gateway, VPN, Transit Gateway, or Network Firewall.
- Auto Scaling capacity is fixed at one for the experiment.

### GCP

- Custom VPC and private-access subnet in an Always Free eligible US region.
- Private, versioned Cloud Storage bucket with lifecycle cleanup.
- Dedicated service account and least-privilege bucket IAM membership; no service-account key.
- Optional private `e2-micro` VM, disabled by default.
- No load balancer, Cloud NAT, VPN, managed firewall policy, or managed directory.

## Cost warning

The code avoids high fixed-hour services, but cloud pricing and account eligibility change. The AWS ALB, EC2, EBS, public IPv4 use, S3 operations, and the optional GCP VM/storage can consume credits or generate charges. Review the plan, current account benefits, quotas, and billing alerts before every apply. Destroy immediately after evidence collection.

## Safe execution order

Start with static validation only:

```bash
cd aws/environments/aws-enterprise-lite
terraform init -backend=false
terraform validate
tofu init -backend=false
tofu validate

cd ../../../gcp/environments/gcp-enterprise-lite
terraform init -backend=false
terraform validate
tofu init -backend=false
tofu validate
```

Do not apply both tools to the same live environment simultaneously. Use separate workspaces and `TF_DATA_DIR` values, following the existing experiment protocol.

## Research purpose

This extension tests whether the Terraform-to-OpenTofu compatibility result continues to hold when the artifact adds identity, private networking, replaceable compute, storage lifecycle rules, and provider-specific enterprise conventions.
