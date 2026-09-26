#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/../.." && pwd)
ENV_DIR="${REPO_ROOT}/environments/aws-baseline"
RAW_RESULTS_DIR="${REPO_ROOT}/experiments/results/raw"
PROCESSED_RESULTS_DIR="${REPO_ROOT}/experiments/results/processed"

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

configure_tool() {
  local requested_tool=${1:-}

  case "${requested_tool}" in
    terraform)
      TOOL=terraform
      EXPECTED_WORKSPACE=phase1-terraform
      TOOL_DATA_DIR="${ENV_DIR}/.terraform-data"
      ;;
    tofu)
      TOOL=tofu
      EXPECTED_WORKSPACE=phase1-tofu
      TOOL_DATA_DIR="${ENV_DIR}/.tofu-data"
      ;;
    *)
      die "Tool must be terraform or tofu."
      ;;
  esac

  export TF_DATA_DIR="${TOOL_DATA_DIR}"
}

require_environment() {
  [[ -n "${AWS_PROFILE:-}" ]] || die "Set AWS_PROFILE explicitly, for example: export AWS_PROFILE=thesis"
  [[ -n "${AWS_REGION:-}" ]] || die "Set AWS_REGION explicitly, for example: export AWS_REGION=eu-central-1"
  [[ -f "${ENV_DIR}/terraform.tfvars" ]] || die "Missing private environments/aws-baseline/terraform.tfvars file."

  require_command aws
  require_command git
  require_command curl
  require_command "${TOOL}"

  aws sts get-caller-identity >/dev/null
}

select_expected_workspace() {
  local workspace

  cd "${ENV_DIR}"
  if ! "${TOOL}" workspace select "${EXPECTED_WORKSPACE}" >/dev/null 2>&1; then
    "${TOOL}" workspace new "${EXPECTED_WORKSPACE}" >/dev/null
  fi

  workspace=$("${TOOL}" workspace show)
  [[ "${workspace}" == "${EXPECTED_WORKSPACE}" ]] || die "Expected workspace ${EXPECTED_WORKSPACE}, found ${workspace}."
}

epoch_seconds() {
  perl -MTime::HiRes=time -e 'printf "%.6f", time'
}

elapsed_seconds() {
  perl -e 'printf "%.3f", $ARGV[1] - $ARGV[0]' "$1" "$2"
}

csv_header='trial_id,tool,git_commit,region,cache_condition,init_seconds,init_exit,validate_seconds,validate_exit,plan_seconds,plan_exit,apply_seconds,apply_exit,verify_seconds,verify_exit,idempotence_seconds,idempotence_exit,destroy_seconds,destroy_exit,cleanup_seconds,cleanup_exit,status'
