# Updated Thesis Working Plan and Results for Professor Meeting

## 1. Thesis focus

### Proposed title

**Applied Evaluation of Terraform-to-OpenTofu Migration and Multi-Cloud Extensibility**

### Practical problem

The thesis studies a realistic company scenario. A company already manages infrastructure with Terraform and wants to evaluate OpenTofu as an alternative Infrastructure-as-Code (IaC) solution without rewriting its existing infrastructure definitions or losing compatibility with its workflows.

The implementation evaluates whether:

- existing Terraform configuration and state can be used by OpenTofu;
- both tools can deploy the same infrastructure reliably;
- the same engineering approach can be extended from AWS to GCP; and
- common module interfaces and operational processes can be standardized even when cloud resources remain provider-specific.

This focus responds to the professor's recommendation to reduce the research questions, make the company use case central, investigate Terraform-to-OpenTofu migration, define measurable criteria, and avoid an oversized security or policy-as-code experiment.

The empirical study covers **multi-cloud infrastructure through AWS and GCP**. It does not currently claim to evaluate hybrid cloud because no private or on-premises environment has been connected to the public-cloud infrastructure.

## 2. Research questions

### Main research question

> How does OpenTofu compare with Terraform when migrating, deploying, and extending a representative Infrastructure-as-Code solution across AWS and GCP?

### RQ1 - Migration and compatibility

> What compatibility issues and configuration changes arise when an existing Terraform configuration and Terraform-created state are used with OpenTofu?

This evaluates whether a company can move an existing Terraform codebase and state to OpenTofu. It measures required source-code changes, state readability, provider compatibility, dependency-lock changes, warnings, and the result of an OpenTofu plan against Terraform-created infrastructure.

### RQ2 - Operational comparison

> Under controlled conditions, how do Terraform and OpenTofu compare in deployment success, execution time, verification, idempotence, and cleanup?

This compares the same AWS configuration, provider version, region, computer, cache condition, commands, and verification rules. The aim is to establish bounded functional equivalence and describe observed timing differences, not to claim that either tool is universally faster.

### RQ3 - Multi-cloud extensibility

> What provider-specific effort and duplication are required to extend the solution from AWS to GCP while retaining standardized module interfaces and deployment workflows?

This separates what can be standardized across providers from what must be rewritten. AWS and GCP use different resource schemas, but the study evaluates whether repository organization, module boundaries, typed variables, outputs, naming, metadata, lifecycle steps, and verification patterns can remain consistent.

## 3. Research methodology

The work is an applied **Design Science Research** study supported by a controlled comparative experiment and a systematic literature review.

The designed artifact consists of:

- a modular AWS reference implementation;
- a bounded GCP extension;
- scripts for repeatable deployment, verification, idempotence, destruction, and cleanup;
- a CI workflow for non-credentialed validation;
- a Terraform-to-OpenTofu state-handoff procedure; and
- processed results and traceable evidence logs.

The evaluation uses observable measures instead of the broad term “effectiveness.”

| Criterion | Measurement |
|---|---|
| Configuration compatibility | Required source-code changes and observed warnings |
| State compatibility | Whether OpenTofu reads Terraform-created state, addresses, and outputs |
| Deployment success | Successful complete trials divided by included trials |
| Execution time | Wall-clock seconds for each lifecycle phase |
| Verification | Expected web response, healthy load-balancer target, and storage controls |
| Idempotence | A second plan proposes no infrastructure changes |
| Cleanup | Destroy succeeds and managed state/resources are absent |
| Extensibility | Reusable conventions versus provider-specific code and issues |
| Reproducibility | Fixed versions, commands, commit identifiers, scripts, and saved results |

Security controls are present in the artifact, but security superiority and policy-as-code are not separate empirical research questions. The manual-provisioning baseline is also removed because the original plan did not define a controlled, repeatable measurement procedure and the professor advised focusing the study.

## 4. Implementation and evaluation phases

### Phase 1 - AWS reference infrastructure

The first phase created a representative AWS environment in `eu-central-1`. It contains:

- one VPC;
- two public subnets in separate availability zones;
- an internet gateway, route table, and route associations;
- one EC2 instance running an Apache demonstration page;
- EC2 and load-balancer security groups;
- one Application Load Balancer, HTTP listener, target group, and target attachment; and
- one S3 bucket with ownership controls, public-access blocking, AES-256 encryption, and versioning.

The configuration is divided into `network`, `compute`, `storage`, and `load-balancer` modules. The root environment connects the modules and exposes outputs such as the VPC ID, instance URL, load-balancer URL, and bucket name.

This phase established the artifact used for both the operational comparison and migration experiment.

### Phase 2 - Modularization and reproducibility

Typed variables, outputs, version constraints, a dependency lock file, consistent resource tags, separate workspaces, and separate tool data directories were added. Terraform and OpenTofu therefore executed the same `.tf` source files without maintaining an OpenTofu-specific copy.

The controlled lifecycle was:

```text
init -> validate -> plan -> apply -> verify -> idempotence plan -> destroy -> cleanup verification
```

Each phase saved its duration and exit code. A trial was included as successful only when all required phases completed successfully.

### Phase 3 - Automated AWS comparison

The experiment runner executed three complete warm-cache trials with Terraform and three with OpenTofu. The important commands represented in the runner were:

```bash
terraform init
terraform validate
terraform plan -out=terraform.tfplan
terraform apply terraform.tfplan
terraform plan -detailed-exitcode
terraform destroy
```

The same lifecycle was executed with the `tofu` command for OpenTofu.

| Command | Purpose | Expected result |
|---|---|---|
| `init` | Initialize providers and modules | Exit code `0` |
| `validate` | Check syntax and internal validity | Exit code `0` |
| `plan` | Calculate intended infrastructure changes | Expected creation plan |
| `apply` | Create the saved plan | All resources created |
| verification script | Test the infrastructure and storage controls | All checks pass |
| `plan -detailed-exitcode` | Test idempotence after apply | Exit code `0`, meaning no changes |
| `destroy` | Remove managed infrastructure | All managed resources destroyed |
| cleanup script | Check state and cloud inventory | No experiment resources remain |

### Phase 4 - CI/CD integration

GitHub Actions was added to run formatting, initialization, and validation without cloud credentials or billable deployment. The AWS configuration is checked with Terraform and OpenTofu. The Azure configuration from the feasibility attempt is also validated.

Credentialed cloud apply and destroy operations remain controlled local experiments because they depend on cloud accounts, can incur cost, and require immediate cleanup.

### Phase 5 - Multi-cloud extension

Azure was attempted first. Authentication and static validation worked, but the free-trial subscription rejected basic resource creation in the tested regions with `RequestDisallowedByAzure`. This is an external subscription constraint and is not counted as a Terraform or OpenTofu failure.

GCP was then used as the deployable second provider. The bounded GCP artifact contains:

- one custom VPC network;
- one regional subnet with Private Google Access; and
- one private, versioned Cloud Storage bucket with uniform bucket-level access and public-access prevention.

Terraform and OpenTofu both completed validation, apply, deployment verification, idempotence, destroy, and cleanup. Both idempotence plans returned exit code `0`, and cleanup verification reported that the network and bucket were absent.

The GCP extension contains 13 `.tf` files and approximately 261 lines. It demonstrates that the engineering method can be standardized across providers, but it does not claim that AWS resource blocks are directly reusable for GCP.

### Phase 6 - Direct Terraform-to-OpenTofu state handoff

This experiment directly tests the company migration scenario in RQ1.

#### Objective

Terraform first creates the AWS infrastructure and state. OpenTofu then uses the same configuration, workspace, and Terraform-created state. A successful handoff requires OpenTofu to recognize the existing resources and produce a no-change plan rather than proposing replacement infrastructure.

#### Procedure and commands

Terraform created the infrastructure in the `state-handoff-2` workspace:

```bash
terraform workspace select state-handoff-2
terraform plan -out=state-handoff-2-terraform.tfplan
terraform apply state-handoff-2-terraform.tfplan
terraform state list
terraform output
```

Purpose: create the reference AWS environment, confirm the state inventory, and record the outputs. Terraform state contained 20 addresses: 19 managed resources and one AMI data source.

The state was protected before changing tools:

```bash
cp terraform.tfstate.d/state-handoff-2/terraform.tfstate \
  ../../experiments/results/raw/state-handoff-2/terraform-before-opentofu.tfstate

shasum -a 256 terraform.tfstate.d/state-handoff-2/terraform.tfstate
```

Purpose: preserve the exact pre-migration state and record a checksum for evidence integrity. The recorded SHA-256 checksum was:

```text
c5714be6ab43666eb655d5c39e06cc799b3a3aac0c5402170c6da73b4706f1ae
```

OpenTofu was then initialized and pointed to the same workspace and state:

```bash
tofu init
tofu workspace select state-handoff-2
tofu state list
tofu output
```

Purpose: test whether OpenTofu could initialize the provider and understand the state written by Terraform. OpenTofu listed the same 20 addresses and returned the same VPC, subnet, EC2, ALB, and S3 outputs.

The decisive compatibility test was:

```bash
tofu plan -detailed-exitcode -no-color \
  > ../../experiments/results/raw/state-handoff-2/opentofu-handoff-plan.txt 2>&1
echo $?
```

Purpose: compare the Terraform-created state and live AWS infrastructure with the unchanged configuration. With `-detailed-exitcode`, exit code `0` means no changes, `1` means an error, and `2` means that changes are proposed.

#### Result

OpenTofu returned exit code `0` and reported:

```text
No changes. Your infrastructure matches the configuration.
```

This is the strongest direct migration result in the thesis. It shows that, for the tested AWS artifact and tool/provider versions, OpenTofu could read Terraform-created state and manage the same live resources without changing the infrastructure source code.

During `tofu init`, OpenTofu translated the provider registry lock entry from `registry.terraform.io/hashicorp/aws` to `registry.opentofu.org/hashicorp/aws`. The AWS provider version remained `5.100.0`, but hashes were rewritten because the provider distributions were not byte-for-byte identical. This is a migration consideration, not an infrastructure compatibility failure.

Finally, OpenTofu destroyed the infrastructure created by Terraform:

```bash
tofu destroy
tofu state list
```

OpenTofu reported `Destroy complete! Resources: 19 destroyed.` The local handoff state was empty afterward. This demonstrates lifecycle control across the tool boundary: Terraform created the resources, OpenTofu adopted the state without changes, and OpenTofu removed the resources.

An earlier handoff attempt was interrupted when the live AWS resources disappeared before the final plan. Its cause was not established, so it is retained as an excluded pilot and is not used as successful migration evidence. Repeating the experiment with explicit workspaces, an immediate state backup, checksum, saved outputs, and a fixed command order produced the valid result above.

### Phase 7 - Enterprise-lite multi-cloud case

The professor-provided Azure project was used as an industry reference for architectural patterns rather than copied feature for feature. A separate `enterprise-lite/` implementation was created so the validated baseline remained unchanged. The bounded AWS case adds private workload subnets, workload identity, least-privilege object-storage access, an S3 gateway endpoint, a launch template, and a one-instance Auto Scaling Group behind an Application Load Balancer. The GCP case applies the same architectural intent through a custom network, private-access subnet, service account, bucket IAM, protected versioned storage, and optional private compute.

The formal AWS enterprise runner executes the same lifecycle for both tools and accepts a trial only when all eight phases return exit code zero. Three Terraform and three OpenTofu trials passed apply, live target/HTTP verification, no-change idempotence, destroy, and independent cleanup. Median apply time was 161.087 seconds for Terraform and 164.148 seconds for OpenTofu; median destroy time was 354.925 and 360.418 seconds respectively. OpenTofu initialization was higher because every trial intentionally began from the committed Terraform-form lock file and included registry-lock translation relevant to migration. The small sample supports functional equivalence for this case, not a universal speed ranking.

Cross-provider analysis counted 25 Terraform-language files and 25 provider resource blocks in AWS, compared with 21 files and seven resource blocks in GCP. There were zero Terraform-specific versus OpenTofu-specific resource-code forks: each provider implementation is shared by both tools. Resource schemas remain cloud-specific, while module composition, naming, inputs/outputs, workload-identity intent, storage protection, lifecycle workflow, idempotence, and cleanup conventions are reused.

## 5. Results

### 5.1 AWS operational comparison

| Item | Value |
|---|---|
| Terraform | `1.5.7` |
| OpenTofu | `1.10.7` |
| AWS provider | `5.100.0` |
| Region | `eu-central-1` |
| Cache condition | Warm |
| Complete trials | 3 per tool |
| Managed resources per trial | 19 |

The timings are wall-clock seconds from immediately before a phase started until the command completed. For each tool and phase, the three successful measurements were sorted and the middle value was used as the median. Medians were chosen because the sample is small and cloud API latency can produce variable observations.

| Operation | Terraform median (s) | OpenTofu median (s) | Observed difference |
|---|---:|---:|---|
| Initialize | 0.872 | 0.861 | OpenTofu lower by 0.011 s |
| Validate | 1.896 | 1.466 | OpenTofu lower by 0.430 s |
| Plan | 6.298 | 2.626 | OpenTofu lower by 3.672 s |
| Apply | 157.630 | 166.953 | Terraform lower by 9.323 s |
| Deployment verification | 26.943 | 15.290 | OpenTofu lower by 11.653 s |
| Idempotence plan | 5.928 | 4.986 | OpenTofu lower by 0.942 s |
| Destroy | 41.352 | 38.774 | OpenTofu lower by 2.578 s |
| Cleanup verification | 5.508 | 3.608 | OpenTofu lower by 1.900 s |

| Reliability measure | Terraform | OpenTofu |
|---|---:|---:|
| Included formal trials | 3 | 3 |
| Successful formal trials | 3 | 3 |
| Success rate | 100% | 100% |
| Idempotent trials | 3 | 3 |
| Successful cleanup checks | 3 | 3 |

The main result is functional equivalence for the bounded AWS use case. Both tools completed every included trial, produced no-change second plans, passed deployment verification, and cleaned up successfully. The timing results are descriptive only. Three trials in one region on one computer are not sufficient to establish general performance superiority, and apply, verification, and destroy times include AWS control-plane latency.

### 5.2 Answers currently supported by the evidence

#### RQ1 - Migration and compatibility

- OpenTofu executed the same AWS `.tf` source without resource-code changes.
- OpenTofu read all 20 addresses and outputs from Terraform-created state.
- The direct handoff plan returned exit code `0` and proposed no infrastructure changes.
- OpenTofu destroyed all 19 resources created by Terraform.
- The provider version was preserved, while provider-registry lock metadata and hashes were translated.

Supported conclusion: for this artifact, tool versions, and local-state workflow, migration from Terraform to OpenTofu was technically feasible without rewriting the infrastructure definitions. The lock-file transition must be reviewed and version controlled as part of a real migration.

#### RQ2 - Operational comparison

- Both tools achieved 100% success and idempotence in the three included AWS trials.
- Both passed the same functional verification and cleanup rules.
- Observed median phase times differed, but the small sample and cloud latency prevent a universal speed claim.

Supported conclusion: OpenTofu was a functionally equivalent alternative to Terraform for the tested AWS lifecycle. The experiment does not demonstrate that either tool is universally faster, more usable, or more reliable.

#### RQ3 - Multi-cloud extensibility

- AWS and GCP resource blocks were provider-specific.
- Network and storage module boundaries were retained.
- Typed inputs, outputs, naming intent, tags/labels, lifecycle steps, evidence collection, idempotence checks, and cleanup rules followed the same pattern.
- Both tools executed the same GCP configuration without a tool-specific resource-code fork.

Supported conclusion: OpenTofu does not make AWS and GCP resources provider-neutral. It supports a standardized Terraform-compatible engineering workflow in which interfaces and processes can be reused while provider implementations remain cloud-specific.

## 6. Scope and limitations

- The empirical work evaluates AWS and GCP, so the supported term is multi-cloud, not hybrid cloud.
- GCP is a bounded network-and-storage extension rather than a feature-for-feature copy of AWS.
- Azure deployment was blocked by the subscription and is reported only as a feasibility limitation.
- Three warm-cache trials per tool provide descriptive evidence, not statistical generalization.
- No user study was conducted, so usability and learning effort are not quantitatively measured.
- No remote-state backend comparison, secrets-manager experiment, or policy-as-code evaluation was performed.
- No manual-console baseline was performed.
- Results apply to the tested versions, providers, configurations, region, and local execution environment.

## 7. Remaining work

The implementation is complete for the proposed AWS/GCP scope. GCP and both enterprise-lite environments are included in GitHub Actions for backend-disabled Terraform/OpenTofu validation; cross-provider reuse is quantified; the successful state handoff is logged; and formal enterprise-lite comparison results are recorded.

1. **Confirm the pushed GitHub Actions run is green.** CI performs static initialization and validation without cloud credentials or billable deployment.
2. **Create meeting visuals.** Prepare the AWS/GCP architecture, experiment lifecycle, and median-duration chart with a small-sample warning.
3. **Freeze scope after professor approval.** Do not add Azure, hybrid connectivity, a manual baseline, or a separate security experiment unless required.
4. **Begin thesis writing.** Complete the methodology, literature review, artifact description, results, threats to validity, and final research-question answers.

## 8. Decisions requested from the professor

1. Is the narrowed migration and operational-comparison focus appropriate for the thesis?
2. Can AWS plus GCP be accepted as the complete multi-cloud scope, with hybrid cloud removed from the empirical claim?
3. Is the bounded GCP network-and-storage extension sufficient to evaluate extensibility?
4. Is the completed direct Terraform-to-OpenTofu state handoff sufficient migration evidence?
5. May security, secrets/state strategy, and policy-as-code remain background or theoretical discussion rather than separate experiments?
6. May the manual-provisioning baseline be removed?
7. Are three complete trials per tool acceptable if the small sample and other limitations are stated clearly?

## 9. Short meeting summary

> I evaluated a realistic company migration from Terraform to OpenTofu. I built a modular AWS reference architecture and ran three complete controlled lifecycle trials with each tool using the same configuration and AWS provider version. Both tools achieved 100% success, idempotence, verification, and cleanup in the included trials. The timing results are descriptive, and I do not claim general performance superiority.
>
> I then tested multi-cloud extensibility with a bounded GCP network-and-storage implementation. Terraform and OpenTofu both completed its full lifecycle. The concrete cloud resource blocks were different, but the module interfaces, naming, inputs and outputs, validation, verification, idempotence, and cleanup approach were standardized.
>
> Finally, I completed a direct state-handoff experiment. Terraform created 19 AWS resources and a state containing 20 addresses. OpenTofu read the same state and outputs, returned a no-change plan with exit code zero, and then destroyed the Terraform-created resources. No infrastructure source-code changes were required. The main migration observation was the translation of provider lock metadata while retaining the provider version.
>
> The evidence therefore supports bounded Terraform-to-OpenTofu migration compatibility, operational equivalence for the tested AWS artifact, and multi-cloud extensibility across AWS and GCP. It does not support a hybrid-cloud or broad security claim. I would like approval to freeze this implementation scope and begin the thesis writing phase.

## 10. Evidence locations

| Evidence | Repository location |
|---|---|
| AWS configuration | `environments/aws-baseline/` and `modules/` |
| Experiment protocol | `docs/experiment-protocol.md` |
| Metric definitions | `docs/metric-definitions.md` |
| Processed AWS comparison | `experiments/results/processed/comparison.csv` |
| AWS result interpretation | `experiments/results/processed/analysis.md` |
| Formal trial evidence | `experiments/results/raw/terraform-trial-*` and `experiments/results/raw/tofu-trial-*` |
| Successful handoff evidence | `experiments/results/raw/state-handoff-2/` |
| Handoff no-change plan | `experiments/results/raw/state-handoff-2/opentofu-handoff-plan.txt` |
| Handoff exit code | `experiments/results/raw/state-handoff-2/opentofu-handoff-exit-code.txt` |
| Terraform state checksum | `experiments/results/raw/state-handoff-2/terraform-state-before-opentofu.sha256` |
| OpenTofu cross-tool destroy | `experiments/results/raw/state-handoff-2/opentofu-destroy-after-handoff.txt` |
| GCP implementation | `gcp-provider/` |
| GCP evidence log | `gcp-provider/implementation-log.md` |
| Migration record | `docs/migration-log.md` |
| Enterprise-lite AWS/GCP implementation | `enterprise-lite/` |
| Enterprise comparison dataset | `experiments/results/processed/enterprise-comparison.csv` |
| Enterprise results | `enterprise-lite/RESULTS.md` |
| Cross-provider reuse calculation | `enterprise-lite/CROSS_PROVIDER_REUSE.md` |
| CI workflow | `.github/workflows/validate.yml` |

## 11. Current thesis position

The thesis does not attempt to prove that OpenTofu is universally better than Terraform. It provides a reproducible, applied evaluation of whether OpenTofu can serve as an alternative IaC engine for a company with an existing Terraform codebase.

Within the tested scope, OpenTofu used the same infrastructure definitions, successfully completed the same AWS and GCP workflows, read Terraform-created state without proposing infrastructure changes, and controlled the remaining lifecycle. The practical contribution is a documented migration procedure, controlled comparison, multi-cloud extension, limitations, and evidence package that a similar organization can use when evaluating an OpenTofu migration.
