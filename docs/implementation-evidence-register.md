# Implementation Evidence Register and Meeting Preparation

This document is the working record for the remaining implementation and the professor meeting. It separates verified results, interrupted experiments, remaining tasks, and proposed work. It should be updated only with evidence that was actually observed.

## 1. Current implementation summary

### Verified AWS implementation

- Modular AWS configuration containing network, compute, storage, and load-balancer modules.
- One VPC and two public subnets in separate availability zones.
- Internet gateway, public routing, and route-table associations.
- One EC2 demonstration instance with encrypted root storage and IMDSv2 required.
- One Application Load Balancer, listener, target group, and target attachment.
- Security groups restricting direct instance access and limiting ALB access to the configured test CIDR.
- One S3 bucket with ownership enforcement, public-access blocking, AES-256 encryption, and versioning.
- Consistent project, environment, purpose, and management tags.
- Automated deployment verification, idempotence testing, destruction, and cloud-cleanup verification.

### Verified Terraform and OpenTofu comparison

| Evidence | Terraform | OpenTofu |
|---|---:|---:|
| Complete formal AWS trials | 3 | 3 |
| Successful formal AWS trials | 3 | 3 |
| Formal success rate | 100% | 100% |
| Idempotent trials | 3 | 3 |
| Idempotence rate | 100% | 100% |
| Successful cleanup checks | 3 | 3 |

Both tools executed the same AWS root configuration and modules. No separate OpenTofu resource-code copy was maintained.

### Recorded median AWS durations

| Operation | Terraform median (s) | OpenTofu median (s) |
|---|---:|---:|
| Initialize | 0.872 | 0.861 |
| Validate | 1.896 | 1.466 |
| Plan | 6.298 | 2.626 |
| Apply | 157.630 | 166.953 |
| Deployment verification | 26.943 | 15.290 |
| Idempotence plan | 5.928 | 4.986 |
| Destroy | 41.352 | 38.774 |
| Cleanup verification | 5.508 | 3.608 |

These measurements are bounded observations, not proof that either tool is generally faster. Apply and destroy measurements include AWS control-plane latency. The sample contains three complete warm-cache trials per tool in one AWS region from one client environment.

### Verified GCP extensibility implementation

- Custom GCP VPC network.
- Regional subnet with Private Google Access.
- Private Standard Cloud Storage bucket.
- Uniform bucket-level access.
- Enforced public-access prevention.
- Object versioning.
- Validation, apply, deployment verification, idempotence, destroy, and cleanup completed with Terraform and OpenTofu.
- Idempotence exit code `0` recorded for both tools.
- Empty final state and cloud-cleanup evidence recorded for both tools.
- Thirteen GCP `.tf` files containing 261 lines were added.

### Azure attempt

The Azure implementation validated with Terraform and OpenTofu, but live deployment was blocked by Azure Free Trial subscription restrictions in the tested regions. This is recorded as an external feasibility limitation, not a Terraform or OpenTofu failure. GCP was used as the successful second-provider case.

## 2. State-handoff attempt on 2026-09-26

### Objective

Test whether OpenTofu can read and operate on local state originally created by Terraform.

### What succeeded

- Terraform state contained 20 addresses, including the AMI data source.
- The Terraform deployment was verified while live:
  - the ALB returned the expected demonstration page;
  - the target group reported `healthy`;
  - all S3 public-access controls were enabled;
  - S3 encryption reported `AES256`;
  - S3 versioning reported `Enabled`.
- A protected Terraform state backup was created.
- Backup SHA-256: `7fd49f67b8f84f6e27c8c468565f0b6ecf22deab0940ea3f344c761510e335bc`.
- OpenTofu successfully listed 20 addresses from the recovered Terraform state.
- OpenTofu successfully displayed the Terraform-created outputs.
- OpenTofu refreshed the state objects against AWS.

### What prevented a valid final result

Before the final no-change OpenTofu plan, the live AWS resources disappeared. AWS subsequently reported:

- no thesis VPC;
- no active thesis EC2 instance;
- no thesis load balancer;
- no thesis S3 bucket.

The cause of the external deletion was not established. State-list, state-pull, state-push, provider-address replacement, and plan commands do not delete cloud resources. No unsupported cause should be claimed.

The final OpenTofu plan proposed 19 additions because the state referenced resources that AWS reported as absent. The run is therefore an interrupted experiment and must not be reported as a successful no-change handoff.

### Additional troubleshooting observations

- Read-only OpenTofu initialization reported a dependency-lock translation requirement.
- The AWS provider version remained `5.100.0`.
- A temporary provider-address replacement was attempted during diagnosis and later reverted after inspection showed that the configuration, lock file, and installed cache used `registry.terraform.io/hashicorp/aws`.
- The refresh-only cleanup plan could not be applied because absent subnet outputs violated compute and load-balancer input validation.
- The failed attempt and all state backups remain private under `experiments/results/raw/`.

### Current status

- AWS experiment resource counts: zero.
- The interrupted `state-handoff` workspace is retained as evidence.
- The `state-handoff-2` workspace is selected by Terraform and is empty.
- No second handoff deployment has been created.

## 3. Tomorrow's implementation plan

### Task 1: Complete one clean state-handoff experiment

Use `state-handoff-2`. Do not alter the provider address. Execute the following controlled sequence without unrelated commands between stages:

1. Confirm AWS identity, region, and zero thesis resource counts.
2. Confirm Terraform selected workspace `state-handoff-2` and empty state.
3. Create and immediately apply a Terraform plan.
4. Verify the ALB, target health, S3 controls, and Terraform state count.
5. Back up the state and record its checksum.
6. Switch to OpenTofu and select the same workspace.
7. Confirm OpenTofu reads the same state addresses and outputs.
8. Immediately run an OpenTofu detailed-exit-code plan.
9. If the exit code is `0`, record a successful no-change handoff.
10. Destroy the Terraform-created resources with OpenTofu.
11. Confirm empty OpenTofu state and zero AWS resource counts.

Success criteria:

- Terraform apply succeeds.
- OpenTofu reads the Terraform-created state without infrastructure-code changes.
- OpenTofu plan returns exit code `0`.
- OpenTofu destroys the Terraform-created resources.
- Final state and AWS cleanup checks are empty.

Stop criteria:

- Wrong AWS account or region.
- Non-empty cloud preflight.
- Unexpected plan actions.
- OpenTofu plan exit code `1` or `2`.
- Any live resource disappears before the handoff completes.

### Task 2: Quantify cross-provider standardization and duplication

Produce a final table using verified source counts:

| Category | AWS | GCP | Interpretation |
|---|---|---|---|
| Provider-specific resource blocks | Measure | Measure | Expected to differ because cloud resource models differ |
| Module boundaries | Network, compute, storage, load balancer | Network, storage | Network and storage concepts retained |
| Typed inputs and validation | Yes | Yes | Reusable design convention |
| Outputs | Yes | Yes | Reusable interface convention |
| Naming and metadata | Tags | Labels | Same purpose, provider-specific mechanism |
| Lifecycle workflow | Validate through cleanup | Validate through cleanup | Reusable operational process |
| Verification automation | AWS scripts | GCP scripts | Same pattern, provider-specific API checks |
| Tool-specific resource-code fork | None | None | Same provider configuration works with Terraform and OpenTofu |

Measurements to add:

- `.tf` file count per implementation;
- `.tf` lines per implementation;
- common module/interface concepts;
- provider-specific modules and scripts;
- issues encountered while adding GCP;
- lines changed specifically for OpenTofu;
- lines changed specifically for Terraform.

The expected conclusion is that resource blocks are provider-specific, while architecture, interfaces, naming principles, metadata, lifecycle procedure, and CI conventions can be standardized.

### Task 3: Add GCP validation to GitHub Actions

Add four checks:

1. GCP verification-script Bash syntax.
2. GCP OpenTofu initialization and validation.
3. GCP Terraform initialization and validation.
4. GCP formatting validation.

The CI jobs should use backend-disabled initialization and must not deploy billable resources. Record the GitHub Actions run URL and final status.

### Task 4: Update research records

- Update `docs/migration-log.md` with the completed formal AWS comparison.
- Record the interrupted handoff separately from any successful retry.
- Add the final state-handoff result only after it meets every success criterion.
- Update `gcp-provider/implementation-log.md` if CI evidence or code measurements change.
- Update the professor-meeting document with the final evidence status.

## 4. Additional artifacts that make the implementation visible

The goal is not to inflate the work. Each artifact should make existing work easier to inspect and reproduce.

### High-value artifacts before the meeting

1. **Architecture diagram:** AWS modules and resources, plus the bounded GCP extension.
2. **Experiment lifecycle diagram:** init, validate, plan, apply, verify, idempotence, destroy, and cleanup.
3. **Compatibility matrix:** AWS and GCP operations supported by Terraform and OpenTofu, including warnings and required changes.
4. **Evidence index:** claim, command or test, evidence file, result, and related research question.
5. **Trial charts:** individual plan, apply, and destroy observations with medians clearly marked.
6. **Reproduction runbook:** exact prerequisites, safe execution order, expected outputs, stop conditions, and cleanup procedure.
7. **Short recorded or live demonstration:** validation, state inspection, a no-change plan, CI status, and processed results. Do not depend on a live cloud apply during the professor call.

These artifacts demonstrate research rigor more effectively than adding unrelated cloud resources.

## 5. Hybrid-cloud decision

AWS plus GCP is multi-cloud, not automatically hybrid cloud. A defensible hybrid experiment requires a private or on-premises component and a meaningful relationship with a public-cloud component.

### Recommended decision

Do not implement hybrid cloud before the professor approves the scope. Ask whether the term should be removed or retained as theoretical context.

### If the professor requires a hybrid implementation

Use one deliberately small case with predefined evaluation criteria. Possible design:

- a local private workload running in a virtual machine or local Kubernetes environment;
- one public-cloud service managed by the same OpenTofu workflow;
- a documented connection or interaction between the private workload and the cloud service;
- separate state and credentials;
- validation, deployment, connectivity, idempotence, and cleanup checks;
- an explicit statement that the local environment simulates the private/on-premises side.

A local Docker container beside unrelated AWS resources is not sufficient evidence of hybrid infrastructure. A site-to-site VPN or production-like private network would be stronger, but it adds networking, security, cost, and troubleshooting scope and is not recommended before the meeting.

## 6. Meeting explanation

### Two-minute implementation summary

> I built a modular AWS reference architecture and executed the same configuration with Terraform and OpenTofu. I completed three formal lifecycle trials per tool. Both tools achieved 100% deployment success, idempotence, and cleanup verification in the included trials. I measured each lifecycle stage and reported medians and ranges rather than claiming general performance superiority.
>
> I then evaluated multi-cloud extensibility. Azure deployment was blocked by subscription restrictions, which I documented as an external limitation. I implemented the bounded second-provider case on GCP, where Terraform and OpenTofu both completed validation, deployment, verification, idempotence, destruction, and cleanup. The provider-specific resource code was different, but module boundaries, inputs and outputs, naming, metadata, and lifecycle conventions were reusable.
>
> I also attempted a direct Terraform-to-OpenTofu state handoff. OpenTofu read the Terraform state and outputs, but the first run became invalid when the live AWS resources disappeared before the final no-change plan. I retained the run as interrupted evidence rather than reporting it as a success. I am completing one controlled retry and would like to confirm whether this migration-focused scope and the bounded GCP case are sufficient.

### Decisions to request from the professor

1. Approve the narrowed Terraform-to-OpenTofu migration and operational-comparison focus.
2. Confirm removal of the hybrid-cloud claim or approve a precisely bounded hybrid extension.
3. Confirm that the GCP network-and-storage case is sufficient for multi-cloud extensibility.
4. Confirm that security, secrets, and policy-as-code remain theoretical rather than a separate experiment.
5. Confirm removal of the manual provisioning baseline or define the required protocol.
6. Confirm whether three complete trials per tool are sufficient with clearly stated limitations.

## 7. Evidence locations

| Evidence | Location |
|---|---|
| Processed AWS dataset | `experiments/results/processed/comparison.csv` |
| AWS results analysis | `experiments/results/processed/analysis.md` |
| Raw private trial logs | `experiments/results/raw/` |
| Experiment protocol | `docs/experiment-protocol.md` |
| Metric definitions | `docs/metric-definitions.md` |
| Migration log | `docs/migration-log.md` |
| GCP implementation record | `gcp-provider/implementation-log.md` |
| GCP verification scripts | `gcp-provider/scripts/` |
| Professor meeting assessment | `docs/professor-meeting-results-and-research-gaps.md` |
| This working evidence register | `docs/implementation-evidence-register.md` |
