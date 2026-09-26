# Terraform-to-OpenTofu Migration Log

Record every compatibility observation, including cases where no code change is required.

| Date | Commit | Step | Observation | Category | Required change | Time spent | Evidence |
|---|---|---|---|---|---|---:|---|
| 2026-09-26 | `10e3262` | GitHub Actions validation | The same configuration passed formatting, initialization, and validation jobs for OpenTofu 1.10.7 and Terraform 1.5.7. | CI/compatibility | None for validation. Deployment comparison remains pending. | Not measured | GitHub Actions run `36239313197` |

## Initial compatibility observation

Terraform 1.5.7 and OpenTofu 1.10.7 both successfully initialized and validated the same configuration with AWS provider 5.100.0. The provider source is explicitly set to `registry.terraform.io/hashicorp/aws` so that the comparison uses the same provider distribution. Separate `TF_DATA_DIR` values keep each tool's plugin cache independent for controlled cold-cache and warm-cache trials. OpenTofu currently reports that the provider signing key is expired and warns that this may fail in a future OpenTofu release; this warning must be retained as migration evidence and the tool versions must remain fixed for the experiment.
