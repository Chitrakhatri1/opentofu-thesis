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

Timing results will be summarized only after three successful trials per tool. The pilot runs are feasibility evidence and are not mixed with the formal timing dataset.

## Interpretation boundary

The enterprise-lite case is company-inspired but remains a bounded experiment. It does not reproduce the Azure reference's managed firewall, Virtual WAN, VPN, virtual desktop, premium profile-storage, monitoring, or Windows-domain estate. It demonstrates transfer of engineering patterns rather than feature-for-feature cloud equivalence.
