# AWS baseline environment

This is the root configuration used for the direct Terraform/OpenTofu compatibility experiment.

It intentionally has no backend block in Phase 1. Both tools therefore use local state. Do not switch tools against a shared state until the experiment protocol and backups are in place.

Quick validation:

```bash
cp terraform.tfvars.example terraform.tfvars
export TF_DATA_DIR=.tofu-data
tofu init
tofu validate
tofu plan
```

Before applying, inspect `terraform.tfvars`, confirm the AWS account and region, and read `../../docs/new-aws-account-runbook.md`.
