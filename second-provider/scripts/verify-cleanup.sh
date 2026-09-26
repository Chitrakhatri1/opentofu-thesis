#!/usr/bin/env bash
set -euo pipefail

resource_group="${1:-opentofu-thesis-azure-experiment-rg}"

if ! command -v az >/dev/null 2>&1; then
  echo "ERROR: Required command not found: az" >&2
  exit 1
fi

group_exists="$(az group exists --name "${resource_group}")"

if [[ "${group_exists}" != "false" ]]; then
  echo "ERROR: Azure resource group still exists: ${resource_group}" >&2
  exit 1
fi

echo "Azure cleanup verification passed."
echo "Resource group is absent: ${resource_group}"
