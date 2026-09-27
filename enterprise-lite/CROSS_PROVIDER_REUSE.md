# Cross-Provider Standardization and Duplication

## Measured implementation size

| Measure | AWS enterprise-lite | GCP enterprise-lite |
|---|---:|---:|
| Terraform-language files | 25 | 21 |
| Terraform-language lines | 571 | 303 |
| Provider resource blocks | 25 | 7 |
| Data-source blocks | 1 | 0 |
| Root module calls | 5 | 4 |
| Tool-specific resource-code copies | 0 | 0 |

Counts were produced from the committed `enterprise-lite` source with `find`, `wc`, and `rg`. Resource-block counts describe source definitions; runtime resource instances can be higher because `for_each` expands subnet and route-association blocks.

## Reusable conventions

| Convention | AWS realization | GCP realization | Reuse type |
|---|---|---|---|
| Root composition | Five child modules | Four child modules | Structural |
| Network boundary | VPC, public/private subnets | Custom VPC and private-access subnet | Conceptual/interface |
| Workload identity | IAM role and instance profile | Keyless service account | Security pattern |
| Least privilege | Inline S3 object policy | Bucket IAM membership | Security intent |
| Object storage | S3 | Cloud Storage | Capability |
| Storage protection | Public-access block, encryption, versioning | Public-access prevention, uniform access, versioning | Policy intent |
| Lifecycle control | Noncurrent-version expiry | Archived-version deletion | Governance pattern |
| Replaceable/bounded compute | Launch template and one-instance ASG | Optional private `e2-micro` | Workload pattern |
| Metadata | Tags | Labels | Governance convention |
| Lifecycle workflow | init through cleanup | init through cleanup | Operational |
| Dual-tool execution | Same files for Terraform/OpenTofu | Same files for Terraform/OpenTofu | IaC compatibility |

## Provider-specific code

AWS and GCP resource blocks are not portable because the providers expose different schemas and managed services. AWS requires explicit resources for the ALB, target group, listener, launch template, Auto Scaling Group, instance profile, route tables, and S3 controls. GCP expresses the bounded case with Google network, subnetwork, firewall, service-account, bucket-IAM, storage, and optional VM resources.

The correct conclusion is therefore not “one module deploys unchanged to every cloud.” The evidence supports standardization of architecture, interfaces, naming, governance intent, validation, evidence collection, idempotence, and cleanup while concrete cloud resources remain provider-specific.

## Relation to the professor-provided Azure reference

The industry reference influenced the separation of networking, workload identity, replaceable compute, private storage, lifecycle governance, and post-deployment automation. Expensive Azure Firewall, Virtual WAN, VPN, AVD, premium profile storage, and Windows-domain services were deliberately not copied. Their architectural intent was represented with bounded AWS/GCP services suitable for a thesis experiment.
