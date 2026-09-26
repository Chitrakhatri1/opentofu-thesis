# Architecture

## Phase 1

The root environment composes provider-specific modules for networking, compute, and storage. Two public subnets establish the multi-availability-zone network foundation. One EC2 instance provides a small demonstrable workload. One private S3 bucket represents object storage.

Direct HTTP ingress is disabled by default. Phase 2 will place the workload behind an Application Load Balancer and revise security-group relationships accordingly.

## Design rules

- The same root configuration is used with Terraform and OpenTofu.
- Provider versions and tool compatibility are declared in code.
- Account-specific values are variables, not embedded credentials.
- Every resource carries experiment-identifying tags.
- State, credentials, plan files, and raw logs are never committed.
- Cross-provider reuse means standardized interfaces and processes, not identical cloud resources.
