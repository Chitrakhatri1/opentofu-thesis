# Terraform-to-OpenTofu Migration Log

Record every compatibility observation, including cases where no code change is required.

| Date | Commit | Step | Observation | Category | Required change | Time spent | Evidence |
|---|---|---|---|---|---|---:|---|
| 2026-09-26 | `10e3262` | GitHub Actions validation | The same configuration passed formatting, initialization, and validation jobs for OpenTofu 1.10.7 and Terraform 1.5.7. | CI/compatibility | None for validation. Deployment comparison remains pending. | Not measured | GitHub Actions run `36239313197` |
| 2026-09-27 | Working tree | Direct state handoff | Terraform created 19 AWS resources and state with 20 addresses. OpenTofu read the same state and outputs, returned detailed-exit code 0 with no changes, and destroyed all 19 Terraform-created resources. | State compatibility | No infrastructure-source changes. OpenTofu translated provider registry lock metadata while preserving AWS provider 5.100.0. | Not measured | `experiments/results/raw/state-handoff-2/` |
| 2026-09-27 | Working tree | Enterprise-lite pilots | The isolated AWS and GCP company-inspired configurations initialized and validated with both tools. OpenTofu pilots completed apply, idempotence, destroy, and cleanup. | Extended compatibility | No tool-specific resource-code fork. Formal repeated comparison still recorded separately. | Not measured | `enterprise-lite/RESULTS.md` |

## Initial compatibility observation

Terraform 1.5.7 and OpenTofu 1.10.7 both successfully initialized and validated the same configuration with AWS provider 5.100.0. Separate `TF_DATA_DIR` values keep each tool's plugin cache independent. The completed direct handoff demonstrates local-state readability and a no-change plan; it does not by itself evaluate every remote backend or future provider/tool release.
