# Enterprise-Lite Implementation Plan

## Already completed in the original baselines

- AWS network, EC2, S3, ALB, security controls, verification, idempotence, cleanup, timing trials, and direct Terraform-to-OpenTofu state handoff.
- GCP network, subnet, private versioned storage, verification, idempotence, and cleanup with both tools.

## New implementation in this isolated directory

### AWS

- Public/private subnet separation.
- No-NAT private application tier.
- S3 gateway endpoint.
- Workload IAM role and instance profile.
- Least-privilege bucket access.
- Launch template and one-instance Auto Scaling Group.
- Storage lifecycle policy.
- Enterprise-specific deployment and cleanup verification.

### GCP

- Separate Free Tier eligible regional environment.
- Keyless service account.
- Least-privilege bucket role.
- Storage lifecycle policy.
- Internal-only firewall rule.
- Optional private `e2-micro`, disabled by default.
- Enterprise-specific deployment and cleanup verification.

## Remaining before live execution

1. Run formatting and static validation with Terraform and OpenTofu.
2. Review both plans and confirm that no prohibited paid gateway/firewall/directory services appear.
3. Check AWS credits/free-plan state and GCP billing/free-tier eligibility.
4. Create real untracked `terraform.tfvars` files from the examples.
5. Run one tool at a time in dedicated workspaces and data directories.
6. Save plan, apply, verification, idempotence, destroy, and cleanup evidence.
7. Only after one safe pilot, add a separate set of three trials per tool.
8. Add static validation for both enterprise-lite environments to GitHub Actions.

## Thesis comparison

Keep the existing baseline dataset unchanged. Report the enterprise-lite artifact as a second case study that tests compatibility across additional resource categories: identity, private networking, replaceable compute, and lifecycle governance.
