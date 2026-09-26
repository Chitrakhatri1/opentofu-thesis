# Experiment automation

These scripts execute and verify controlled Terraform/OpenTofu trials for the AWS baseline.

## Safety behavior

- The selected tool must be `terraform` or `tofu`.
- `AWS_PROFILE` and `AWS_REGION` must be set explicitly.
- The expected isolated workspace must be selected.
- The selected workspace state and live thesis environment must be empty before a trial.
- Applying and destroying both require typed confirmation.
- A post-apply no-change plan is captured before destruction.
- Cleanup is verified against local state and live AWS resources.
- Raw logs remain local and are ignored by Git.
- The processed CSV contains timings and status only; inspect it before committing.
- Initialization warnings, including OpenTofu provider-lock translation warnings, are retained in each trial's raw `init.log`.

## Prerequisites

```bash
export AWS_PROFILE=thesis
export AWS_REGION=eu-central-1
aws sts get-caller-identity
```

The local `environments/aws-baseline/terraform.tfvars` file must contain the current test IP in `allowed_http_cidrs`.

## Run a trial

From the repository root:

```bash
./experiments/scripts/run-trial.sh terraform 01 warm
./experiments/scripts/run-trial.sh tofu 01 warm
```

Arguments:

1. Tool: `terraform` or `tofu`.
2. Trial number or short identifier.
3. Cache condition label, normally `warm` for the first controlled dataset.

Do not run the second tool until the first trial reports successful cleanup.

## Verification-only commands

For a live deployment:

```bash
./experiments/scripts/verify-deployment.sh terraform
```

For an empty environment:

```bash
./experiments/scripts/verify-cleanup.sh terraform
```

Replace `terraform` with `tofu` as appropriate.

## Results

- Raw logs: `experiments/results/raw/<trial-id>/`
- Processed summary: `experiments/results/processed/comparison.csv`

Review and sanitize all evidence before publication.
