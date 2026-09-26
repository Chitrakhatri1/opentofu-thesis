# Architecture

## Phase 1

The root environment composes provider-specific modules for networking, compute, storage, and load balancing. Two public subnets establish the multi-availability-zone network foundation. A public Application Load Balancer forwards HTTP requests to one EC2 demonstration instance. One private S3 bucket represents object storage.

The load balancer accepts HTTP only from the configured test CIDR blocks. The EC2 security group accepts HTTP only from the load-balancer security group, so the instance cannot be reached directly from the internet on port 80.

## Design rules

- The same root configuration is used with Terraform and OpenTofu.
- Provider versions and tool compatibility are declared in code.
- Account-specific values are variables, not embedded credentials.
- Every resource carries experiment-identifying tags.
- State, credentials, plan files, and raw logs are never committed.
- Cross-provider reuse means standardized interfaces and processes, not identical cloud resources.
