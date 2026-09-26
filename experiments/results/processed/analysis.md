# Terraform and OpenTofu AWS Trial Analysis

## 1. Purpose

This document summarizes the controlled AWS baseline trials executed with Terraform and OpenTofu. It provides the first empirical evidence for the thesis comparison of operational behavior, configuration compatibility, deployment success, and idempotence.

Dataset: `comparison.csv`

Tested Git commit: `eea6e1d8825f819624bb5e9a8fce00f9bd37afcd`

AWS region: `eu-central-1`

Cache condition: warm

Terraform version: 1.5.7

OpenTofu version: 1.10.7

AWS provider version: 5.100.0

## 2. Infrastructure under test

Each complete trial created and destroyed the same 19 managed AWS resources. The architecture contained:

- one VPC;
- two public subnets in separate availability zones;
- one internet gateway;
- one public route table and two subnet associations;
- one EC2 instance running an Apache demonstration page;
- one EC2 security group;
- one Application Load Balancer;
- one load-balancer security group;
- one HTTP listener;
- one target group and EC2 target attachment;
- one S3 bucket with ownership controls, public-access blocking, AES-256 encryption, and versioning.

The same Infrastructure-as-Code configuration was used by Terraform and OpenTofu. No tool-specific copy of the AWS configuration was maintained.

## 3. Trial selection

### Included trials

The primary comparison uses three successful trials per tool:

| Tool | Included trials |
|---|---|
| Terraform | `terraform-trial-02`, `terraform-trial-03`, `terraform-trial-04` |
| OpenTofu | `tofu-trial-01`, `tofu-trial-02`, `tofu-trial-03` |

All included trials completed initialization, validation, planning, application, deployment verification, idempotence checking, destruction, and cleanup verification.

### Excluded trial

`terraform-trial-01` is retained in the source dataset but excluded from the primary timing comparison. Its deployment, ALB health check, HTTP verification, S3 verification, and idempotence check passed. The automation was interrupted before the scripted destroy and cleanup stages, so those durations were not captured. The resources were later destroyed, and cleanup was independently verified.

This observation represents an incomplete experimental procedure rather than a Terraform infrastructure failure.

## 4. Summary statistics

The median is used as the primary descriptive statistic because the sample contains only three complete observations per tool and individual AWS provisioning times can vary.

| Operation | Terraform median (s) | Terraform range (s) | OpenTofu median (s) | OpenTofu range (s) | OpenTofu minus Terraform (s) |
|---|---:|---:|---:|---:|---:|
| Initialize | 0.872 | 0.844-1.002 | 0.861 | 0.860-1.735 | -0.011 |
| Validate | 1.896 | 1.882-1.952 | 1.466 | 1.386-1.563 | -0.430 |
| Plan | 6.298 | 3.502-8.986 | 2.626 | 2.575-4.789 | -3.672 |
| Apply | 157.630 | 157.407-159.111 | 166.953 | 158.575-167.627 | +9.323 |
| Deployment verification | 26.943 | 15.195-28.513 | 15.290 | 15.222-15.422 | -11.653 |
| Idempotence plan | 5.928 | 5.773-11.952 | 4.986 | 4.968-5.069 | -0.942 |
| Destroy | 41.352 | 40.645-43.498 | 38.774 | 35.357-38.965 | -2.578 |
| Cleanup verification | 5.508 | 3.653-7.414 | 3.608 | 3.543-3.736 | -1.900 |

Negative differences indicate a lower OpenTofu median. Positive differences indicate a higher OpenTofu median.

## 5. Reliability and idempotence

| Measure | Terraform | OpenTofu |
|---|---:|---:|
| Complete formal trials | 3 | 3 |
| Successful formal trials | 3 | 3 |
| Formal trial success rate | 100% | 100% |
| Idempotent formal trials | 3 | 3 |
| Idempotence rate | 100% | 100% |
| Successful cleanup verifications | 3 | 3 |

Every included trial produced a healthy ALB target, returned the expected application response, verified the required S3 controls, produced a post-apply no-change plan, destroyed all 19 managed resources, and passed the final cleanup check.

## 6. Configuration compatibility

Both tools initialized, validated, planned, applied, verified, and destroyed the same root configuration and modules. The trials did not require changes to AWS resources, module inputs, provider configuration, or outputs when switching tools.

OpenTofu reported a provider-lock translation warning during initialization. It translated the provider registry representation while preserving AWS provider version 5.100.0. This warning did not prevent validation, planning, application, idempotence, or destruction. It should be retained as a migration compatibility observation because a future OpenTofu or provider release could change this behavior.

## 7. Interpretation

OpenTofu had lower median initialization, validation, planning, idempotence-plan, and destruction times in this dataset. Its median plan time was 3.672 seconds lower than Terraform's median. Terraform had a lower median apply time by 9.323 seconds.

These differences do not establish that either tool is generally faster. Apply and destroy durations include AWS control-plane and resource-provisioning latency, particularly Application Load Balancer creation and EC2 lifecycle operations. The sample size is small, all trials used a warm dependency cache, and all trials ran in one region from one client environment.

Deployment verification duration is not a direct Terraform/OpenTofu performance metric. It measures how soon AWS reports the target as healthy and how the polling interval aligns with that transition. It is retained as operational evidence but should not be used to rank the tools.

The strongest empirical result is functional equivalence for this use case: both tools achieved a 100% formal trial success rate, 100% idempotence rate, and 100% cleanup-verification rate using the same configuration.

## 8. Relationship to the research questions

### Migration compatibility

The tested Terraform configuration executed successfully with OpenTofu without infrastructure-code changes. The only observed compatibility issue was the provider-lock translation warning.

### Operational behavior

Both tools reliably completed the full resource lifecycle. Timing differences were observed, but the small sample and cloud latency limit performance conclusions.

### Extensibility

The AWS trials do not answer the second-provider extensibility question. That question requires implementation and measurement of a bounded Azure or GCP extension.

## 9. Threats to validity

- Only three successful trials per tool were included.
- Trials used one AWS region and one client computer.
- All formal trials used a warm dependency cache.
- AWS API and resource-provisioning latency could influence apply and destroy durations.
- Trials were sequential rather than randomized or interleaved.
- The environment contains one EC2 target and represents a bounded experimental workload rather than production infrastructure.
- The comparison covers the tested versions and should not be generalized automatically to other releases.
- The incomplete Terraform pilot was excluded from timing analysis using a documented rule applied before interpretation.

## 10. Reproducibility evidence

The processed dataset is stored in `experiments/results/processed/comparison.csv`. Private raw logs are stored locally under `experiments/results/raw/` and are excluded from Git because they contain resource identifiers and local paths. The repository commit, tool versions, provider version, region, cache label, durations, exit codes, and final trial status are recorded for every trial.

## 11. Next analysis steps

1. Create separate trial-level charts for plan, apply, and destroy durations.
2. Retain medians, ranges, sample sizes, and units in every table or figure caption.
3. Add the second-provider implementation-effort results when available.
4. Use the raw logs to verify any anomaly before interpreting it.
5. Map the final findings explicitly to each approved thesis research question.
