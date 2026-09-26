#!/usr/bin/env bash
set -euo pipefail

tool="${1:-tofu}"

if [[ "${tool}" != "tofu" && "${tool}" != "terraform" ]]; then
  echo "Usage: $0 [tofu|terraform]" >&2
  exit 2
fi

for command_name in "${tool}" az; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "ERROR: Required command not found: ${command_name}" >&2
    exit 1
  fi
done

resource_group="$(${tool} output -raw resource_group_name)"
storage_account="$(${tool} output -raw storage_account_name)"

if [[ "$(az group exists --name "${resource_group}")" != "true" ]]; then
  echo "ERROR: Azure resource group does not exist: ${resource_group}" >&2
  exit 1
fi

vnet_count="$(az network vnet list \
  --resource-group "${resource_group}" \
  --query 'length(@)' \
  --output tsv)"

subnet_count="$(az network vnet subnet list \
  --resource-group "${resource_group}" \
  --vnet-name "${resource_group%-rg}-vnet" \
  --query 'length(@)' \
  --output tsv)"

read -r public_network_access blob_public_access minimum_tls <<<"$(az storage account show \
  --name "${storage_account}" \
  --resource-group "${resource_group}" \
  --query '[publicNetworkAccess, allowBlobPublicAccess, minimumTlsVersion]' \
  --output tsv)"

versioning_enabled="$(az storage account blob-service-properties show \
  --account-name "${storage_account}" \
  --resource-group "${resource_group}" \
  --query 'isVersioningEnabled' \
  --output tsv)"

[[ "${vnet_count}" == "1" ]] || {
  echo "ERROR: Expected one VNet, found ${vnet_count}." >&2
  exit 1
}

[[ "${subnet_count}" == "1" ]] || {
  echo "ERROR: Expected one subnet, found ${subnet_count}." >&2
  exit 1
}

[[ "${public_network_access}" == "Disabled" ]] || {
  echo "ERROR: Storage public network access is not disabled." >&2
  exit 1
}

[[ "${blob_public_access,,}" == "false" ]] || {
  echo "ERROR: Public blob access is not disabled." >&2
  exit 1
}

[[ "${minimum_tls}" == "TLS1_2" ]] || {
  echo "ERROR: Minimum storage TLS version is not TLS1_2." >&2
  exit 1
}

[[ "${versioning_enabled,,}" == "true" ]] || {
  echo "ERROR: Blob versioning is not enabled." >&2
  exit 1
}

echo "Azure deployment verification passed."
echo "Resource group: ${resource_group}"
echo "Virtual networks: ${vnet_count}"
echo "Subnets: ${subnet_count}"
echo "Storage account: ${storage_account}"
echo "Storage controls: public network disabled, public blobs disabled, TLS1_2, versioning enabled"
