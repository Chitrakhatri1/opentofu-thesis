# GCP extensibility case

This folder contains a bounded Google Cloud implementation for evaluating
multi-cloud extensibility when Azure region eligibility prevents deployment.
It deliberately implements the same small slice as the Azure case:

- one custom VPC network;
- one regional subnet with Private Google Access;
- one private, versioned Standard Cloud Storage bucket.

It does not create a VM, load balancer, database, public IP address, Google
Cloud project, or billing account.

## Prerequisites

- A Google Cloud project with billing enabled.
- Compute Engine and Cloud Storage APIs enabled.
- Google Cloud CLI authenticated to the intended project.
- Application Default Credentials created with
  `gcloud auth application-default login`.
- Terraform 1.5+ or OpenTofu 1.5+.

Confirm identity, project, and billing before continuing:

```bash
gcloud auth list
gcloud config get-value project
gcloud billing projects describe "$(gcloud config get-value project)"
```

## Configure

```bash
cd /Users/chitrakhatri/Documents/Thesis_Code/Aws/gcp-provider/environments/gcp-baseline
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` if the project ID is not `opentofu-thesis`. Replace
`bucket_suffix` with 4-12 lowercase letters or digits if the proposed bucket
name is already taken.

## Validate and deploy with OpenTofu

```bash
export TF_DATA_DIR=.tofu-data
tofu fmt -check -recursive ../../..
tofu init -backend=false
tofu validate
tofu plan -out=gcp.tfplan
tofu apply gcp.tfplan
tofu output
../../scripts/verify-deployment.sh tofu
```

The expected plan contains three resources: one VPC, one subnet, and one
bucket. Stop if the plan includes unexpected resources.

Check idempotence:

```bash
tofu plan -detailed-exitcode
echo $?
```

Exit code `0` means no changes are proposed. Exit code `2` means changes are
proposed. Exit code `1` means an error occurred.

## Destroy and verify cleanup

Capture the generated names before destroying:

```bash
project_id="$(tofu output -raw project_id)"
network_name="$(tofu output -raw network_name)"
bucket_name="$(tofu output -raw bucket_name)"
tofu destroy
tofu state list
../../scripts/verify-cleanup.sh "${project_id}" "${network_name}" "${bucket_name}"
```

Only `yes` confirms the interactive destroy. An empty `tofu state list` and a
successful cleanup script confirm that the experiment resources are gone.

## Cost and safety

This case does not deploy compute. The VPC and subnet do not incur standalone
hourly charges. The empty Standard bucket can incur storage, operation, or data
transfer charges if it is used. Review the plan before applying, keep the bucket
empty, and destroy the resources after verification.
