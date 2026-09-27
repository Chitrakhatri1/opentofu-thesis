# Enterprise-Lite Results

## Purpose

The enterprise-lite case extends the original baseline with patterns derived from the professor-provided industry Terraform reference. It tests whether the earlier Terraform/OpenTofu compatibility finding continues across identity, private networking, replaceable compute, least-privilege storage access, and lifecycle governance.

## Completed pilot evidence

### AWS OpenTofu pilot

- Planned and created 29 resource instances.
- Used two public and two private subnets.
- Created an S3 gateway endpoint without a NAT Gateway.
- Created a workload IAM role and instance profile.
- Created a launch template and Auto Scaling Group fixed at one private instance.
- Passed deployment checks during the run.
- Produced a no-change idempotence plan.
- Destroyed the environment.
- Final local state and independent AWS VPC, active-instance, ALB, and bucket counts were zero.

### GCP OpenTofu pilot

- Created six network, firewall, identity, IAM, and storage resources with compute disabled.
- Apply result: six added, zero changed, zero destroyed.
- Idempotence exit code: zero; OpenTofu reported no changes.
- Destroy result: six destroyed.
- Final state was empty and cloud cleanup verification passed.
- The deployment-verification capture file was empty, so the formal runner must capture that phase again before it is counted as a successful formal trial.

## Formal comparison

Formal AWS enterprise-lite results are stored in `experiments/results/processed/enterprise-comparison.csv`. A trial counts as successful only if initialization, validation, plan, apply, deployment verification, idempotence, destroy, and cleanup all return exit code zero.

`enterprise-terraform-trial-01` is retained as an excluded automation pilot. Apply, idempotence, destroy, and cleanup succeeded, but the first verifier attempted HTTP before the Auto Scaling target was healthy. The verifier was changed to wait for an `InService` instance and healthy target before testing HTTP. The run is not counted as a successful formal observation.

`enterprise-terraform-trial-04` is also excluded because the AWS SSO session expired before planning; no infrastructure was created. An initial OpenTofu invocation exposed that the runner attempted to select a workspace before initializing the OpenTofu provider cache. The runner now initializes first, then selects the isolated workspace and records provider metadata. That pre-execution automation check created no infrastructure and is not a performance observation.

The included dataset contains three successful Terraform trials (`02`, `03`, and `05`) and three successful OpenTofu trials (`02`, `03`, and `04`). Every included run passed initialization, validation, planning, apply, live deployment verification, no-change idempotence, destroy, and independent cleanup verification.

Times are wall-clock seconds. For each phase, the three measurements were sorted and the middle value was reported as the median. Ranges show the minimum and maximum successful observations.

| Phase | Terraform median (range), s | OpenTofu median (range), s | OpenTofu relative to Terraform median |
|---|---:|---:|---:|
| Initialize | 1.090 (1.011–1.121) | 9.579 (8.864–13.530) | +778.8% |
| Validate | 2.023 (1.920–2.035) | 1.517 (1.497–1.552) | -25.0% |
| Plan | 3.857 (3.483–4.381) | 2.949 (2.603–3.021) | -23.5% |
| Apply | 161.087 (160.726–163.646) | 164.148 (158.194–179.440) | +1.9% |
| Verify | 27.794 (27.281–28.233) | 27.528 (17.305–27.768) | -1.0% |
| Idempotence plan | 7.091 (6.171–9.043) | 5.328 (5.188–6.773) | -24.9% |
| Destroy | 354.925 (352.056–385.068) | 360.418 (352.264–377.799) | +1.5% |
| Cleanup verification | 1.898 (1.892–1.939) | 1.973 (1.940–2.012) | +4.0% |
| Complete lifecycle | 560.914 (558.529–590.328) | 588.386 (555.812–588.992) | descriptive only |

| Reliability measure | Terraform | OpenTofu |
|---|---:|---:|
| Included trials | 3 | 3 |
| Successful trials | 3 | 3 |
| Successful idempotence checks | 3 | 3 |
| Successful cleanup checks | 3 | 3 |

The infrastructure source did not change between the included Terraform and OpenTofu groups. The runner-order correction was committed before the OpenTofu group. OpenTofu initialization was intentionally measured from the committed Terraform-form dependency lock file on each trial, so its larger initialization median includes provider-registry lock translation relevant to the migration scenario. Apply, verification, destroy, and cleanup medians were close; with only three runs per tool, these values are descriptive and do not establish general performance superiority.

## Interpretation boundary

The enterprise-lite case is company-inspired but remains a bounded experiment. It does not reproduce the Azure reference's managed firewall, Virtual WAN, VPN, virtual desktop, premium profile-storage, monitoring, or Windows-domain estate. It demonstrates transfer of engineering patterns rather than feature-for-feature cloud equivalence.
