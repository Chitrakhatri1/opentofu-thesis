# GCP extensibility implementation evidence

## Purpose

This file records the bounded Google Cloud extension used to answer the
multi-cloud extensibility question. AWS remains the full reference
implementation and the environment used for the repeated Terraform/OpenTofu
trials. GCP is a smaller second-provider case, not a second performance
benchmark.

Azure was attempted first, but the Free Trial subscription rejected basic
network and storage resources with `RequestDisallowedByAzure` in West Europe,
North Europe, Sweden Central, and East US. GCP was therefore selected as the
deployable second provider.

## Scope

- Provider: Google Cloud Platform
- Project identifier in thesis material: anonymized
- Region: `europe-west3`
- Execution tools: Terraform and OpenTofu
- Resources:
  - one custom VPC network;
  - one regional subnet with Private Google Access;
  - one private Standard Cloud Storage bucket;
  - uniform bucket-level access;
  - public access prevention;
  - object versioning.
- Explicitly out of scope: VM, load balancer, database, public IP address,
  project creation, billing-account creation, and cross-cloud connectivity.

## Implementation measurements

| Measure | Recorded value |
|---|---|
| New GCP `.tf` files | 13 |
| New GCP `.tf` lines | 261 |
| OpenTofu version | 1.10.7 |
| Terraform version | 1.5.7 |
| Google provider version | 7.46.1 |
| Google Cloud region | `europe-west3` |
| Planned resource count | 3 |
| OpenTofu validation | Passed |
| OpenTofu apply | Passed |
| OpenTofu deployment verification | Passed |
| OpenTofu destroy | Passed, resources removed |
| Terraform validation | Passed |
| Terraform apply | Passed |
| Terraform destroy | Passed, resources removed |
| Final OpenTofu state | Empty |
| Final Terraform state | Empty |
| Billing observation | EUR 0 when checked after the trials; billing data may be delayed |
| Active implementation time | Not measured prospectively |
| OpenTofu idempotence exit code | 0 |
| Terraform idempotence exit code | 0 |
| Terraform deployment verification | Passed |

## Reused conventions

The AWS resource blocks were not reusable because AWS and GCP expose different
resource models. The following engineering conventions were reused:

- separate `network` and `storage` modules;
- typed and validated input variables;
- stable resource naming;
- common metadata through labels;
- root-module composition;
- explicit outputs;
- dependency lock files;
- separate Terraform and OpenTofu plugin-data directories;
- the same validate, plan, apply, verify, idempotence, destroy, and cleanup
  workflow;
- automated verification scripts.

This is interface and workflow reuse, not literal reuse of provider-specific
resource blocks.

## Issues and resolutions

| Category | Observation | Resolution | Thesis meaning |
|---|---|---|---|
| Provider selection | Azure Free Trial regional eligibility blocked network and storage deployment in four tested regions. | Retained the Azure attempt as limitation evidence and used GCP as the successful second-provider case. | Cloud-account constraints can affect empirical feasibility independently of the IaC tool. |
| Authentication | Terraform-compatible tools required Google Application Default Credentials in addition to the interactive `gcloud` login. | Ran `gcloud auth application-default login` and assigned the thesis project as quota project. | Provider authentication setup is part of extension effort. |
| API enablement | Compute Engine and Resource Manager APIs were not initially enabled. | Enabled the required Google Cloud APIs before deployment. | Provider onboarding includes platform-specific prerequisites. |
| Verification portability | The initial Bash script used `${value,,}`, which is unsupported by the default macOS Bash 3.2. | Replaced lowercase expansion with portable `tr` normalization. | Automation portability is a practical implementation concern. |
| Provider signing | OpenTofu warned that the Google provider signing key is expired and may fail in a future OpenTofu version. | Recorded the warning; provider installation and validation succeeded. | Ecosystem compatibility includes dependency-signing behavior, not only HCL syntax. |

## Evidence retained

- GCP source modules and root configuration;
- `.terraform.lock.hcl` with Google provider selection;
- OpenTofu and Terraform validation results;
- dashboard screenshots of the custom VPC and subnet;
- dashboard verification of the private bucket;
- successful automated OpenTofu verification output;
- successful apply and destroy observations for both tools;
- empty final state checks;
- billing observation of EUR 0 immediately after the trials.

Generated plans, local variable files, state files, credentials, and raw output
containing account identifiers must remain excluded from version control.

## Result

The bounded GCP extension was deployable with both Terraform and OpenTofu using
the same GCP configuration. No tool-specific GCP resource code was required.
The provider-specific implementation could not reuse AWS resource blocks, but
the module structure, input/output conventions, validation process, and
resource-lifecycle workflow were reusable.

The evidence supports a narrow conclusion: for this use case, OpenTofu retained
Terraform configuration compatibility while the larger implementation effort
arose from differences between AWS and GCP resource models rather than from the
choice between Terraform and OpenTofu.
