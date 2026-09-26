# Azure extensibility case

This folder contains the bounded second-provider implementation used to evaluate
multi-cloud extensibility. It deliberately implements a smaller slice than the
AWS baseline:

- one Azure resource group;
- one virtual network;
- one subnet;
- one private StorageV2 account with TLS 1.2 and blob versioning.

The Azure resources are provider-specific. Reuse is demonstrated through the
same module organization, naming inputs, metadata conventions, typed variables,
outputs, validation workflow, and Terraform/OpenTofu execution process used by
the AWS baseline.

## Structure

```text
second-provider/
  modules/
    network/                  Azure VNet and subnet
    storage/                  Azure StorageV2 account
  environments/
    azure-baseline/           Deployable root configuration
  implementation-log.md      Evidence and effort-recording template
```

## Prerequisites

- An Azure subscription with permission to create a resource group, virtual
  network, subnet, and storage account.
- Azure CLI authenticated to the intended subscription.
- Terraform 1.5+ or OpenTofu 1.5+.

Confirm the current Azure identity and subscription before continuing:

```bash
az login
az account show --output table
```

If the wrong subscription is selected:

```bash
az account set --subscription "<subscription-name-or-id>"
az account show --output table
```

The AzureRM 4.x provider requires the subscription ID. Set it without placing
the value in a committed file:

```bash
export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
```

## Configure

```bash
cd second-provider/environments/azure-baseline
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`. Replace `unique_suffix` with a short lowercase value
that helps make the globally named storage account unique, for example your
initials plus four random digits.

## Validate with OpenTofu

```bash
export TF_DATA_DIR=.tofu-data
tofu fmt -check -recursive ../../..
tofu init -backend=false
tofu validate
```

## Deploy with OpenTofu

```bash
tofu plan -out=azure.tfplan
tofu apply azure.tfplan
tofu output
../../scripts/verify-deployment.sh tofu
```

In the Azure portal, check the resource group printed by
`tofu output resource_group_name`. It should contain one virtual network and one
storage account. The VNet should contain one subnet. Public blob access and
public network access on the storage account should be disabled.

Check idempotence:

```bash
tofu plan -detailed-exitcode
echo $?
```

Exit code `0` means the deployed configuration is idempotent. Exit code `2`
means changes are proposed, and exit code `1` means an error occurred.

Destroy with the same tool and data directory used to apply:

```bash
tofu destroy
tofu state list
../../scripts/verify-cleanup.sh
```

The cleanup script must report that verification passed. An empty
`tofu state list` confirms that the local state no longer tracks resources.

## Terraform validation or deployment

Use a separate data directory so Terraform and OpenTofu plugin data do not
overlap:

```bash
export TF_DATA_DIR=.terraform-data
terraform init -backend=false
terraform validate
terraform plan -out=azure.tfplan
```

Do not apply Terraform and OpenTofu against the same mutable local state at the
same time. Never commit `terraform.tfvars`, state, plan files, or credentials.

## Cost and scope

This case does not deploy compute or a load balancer. It is intended to measure
extension effort and interface consistency, not to repeat the AWS performance
experiment. Review current Azure pricing and destroy the resource group after
verification.
