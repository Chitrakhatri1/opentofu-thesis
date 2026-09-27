#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=enterprise-common.sh
source "${SCRIPT_DIR}/enterprise-common.sh"

configure_enterprise_tool "${1:-}"
TRIAL_NUMBER=${2:-}
CACHE_CONDITION=${3:-warm}

[[ "${TRIAL_NUMBER}" =~ ^[A-Za-z0-9._-]+$ ]] || die "Invalid trial ID."
[[ "${CACHE_CONDITION}" =~ ^[A-Za-z0-9._-]+$ ]] || die "Invalid cache label."

require_enterprise_environment

TRIAL_ID="enterprise-${TOOL}-trial-${TRIAL_NUMBER}"
TRIAL_DIR="${RAW_RESULTS_DIR}/${TRIAL_ID}"
SUMMARY_FILE="${PROCESSED_RESULTS_DIR}/enterprise-comparison.csv"
PLAN_FILE="${ENV_DIR}/${TOOL}-enterprise-${TRIAL_NUMBER}.tfplan"

[[ ! -e "${TRIAL_DIR}" ]] || die "Trial directory already exists: ${TRIAL_DIR}"
mkdir -p "${TRIAL_DIR}" "${PROCESSED_RESULTS_DIR}"

git_commit=$(git -C "${REPO_ROOT}" rev-parse HEAD)
git_status=$(git -C "${REPO_ROOT}" status --porcelain -- . ':(exclude)experiments/results/processed/enterprise-comparison.csv')
[[ -z "${git_status}" ]] || die "Git working tree must be clean before a formal trial."

# OpenTofu translates Terraform registry lock entries during initialization.
# Preserve the committed Terraform-form lock so each formal trial starts from
# the same dependency metadata and later trials see a clean working tree.
LOCK_FILE="${ENV_DIR}/.terraform.lock.hcl"
LOCK_BACKUP=$(mktemp "${TMPDIR:-/tmp}/enterprise-lock.XXXXXX")
cp "${LOCK_FILE}" "${LOCK_BACKUP}"

printf 'trial_id=%s\ntool=%s\ngit_commit=%s\nregion=%s\ncache_condition=%s\nstarted_at_utc=%s\n' \
  "${TRIAL_ID}" "${TOOL}" "${git_commit}" "${AWS_REGION}" "${CACHE_CONDITION}" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >"${TRIAL_DIR}/metadata.txt"
"${TOOL}" version >"${TRIAL_DIR}/tool-version.log" 2>&1

for step in init validate plan apply verify idempotence destroy cleanup; do
  printf -v "${step}_seconds" '%s' 0
  printf -v "${step}_exit" '%s' 99
done
trial_status=failed
summary_written=false

write_summary() {
  [[ -f "${SUMMARY_FILE}" ]] || printf '%s\n' "${enterprise_csv_header}" >"${SUMMARY_FILE}"
  printf '%s\n' "${TRIAL_ID},${TOOL},${git_commit},${AWS_REGION},${CACHE_CONDITION},${init_seconds},${init_exit},${validate_seconds},${validate_exit},${plan_seconds},${plan_exit},${apply_seconds},${apply_exit},${verify_seconds},${verify_exit},${idempotence_seconds},${idempotence_exit},${destroy_seconds},${destroy_exit},${cleanup_seconds},${cleanup_exit},${trial_status}" >>"${SUMMARY_FILE}"
}
finish() { if [[ "${summary_written}" == false ]]; then write_summary; summary_written=true; fi; }
finalize_trial() {
  local exit_code=$?
  finish
  cp "${LOCK_BACKUP}" "${LOCK_FILE}"
  rm -f "${LOCK_BACKUP}"
  return "${exit_code}"
}
trap finalize_trial EXIT

run_step() {
  local step=$1 start end result duration
  shift
  start=$(epoch_seconds)
  set +e
  "$@" >"${TRIAL_DIR}/${step}.log" 2>&1
  result=$?
  set -e
  end=$(epoch_seconds)
  duration=$(elapsed_seconds "${start}" "${end}")
  printf -v "${step}_seconds" '%s' "${duration}"
  printf -v "${step}_exit" '%s' "${result}"
  printf '%-14s exit=%s duration=%ss\n' "${step}" "${result}" "${duration}"
  return "${result}"
}

"${SCRIPT_DIR}/verify-cleanup.sh" opentofu-thesis | tee "${TRIAL_DIR}/preflight-cleanup.log"
cd "${ENV_DIR}"
run_step init "${TOOL}" init -no-color || die "Initialization failed."
select_enterprise_workspace
"${TOOL}" providers >"${TRIAL_DIR}/providers.log" 2>&1
run_step validate "${TOOL}" validate -no-color || die "Validation failed."
run_step plan "${TOOL}" plan -no-color -out="${PLAN_FILE}" || die "Plan failed."
"${TOOL}" show -no-color "${PLAN_FILE}" >"${TRIAL_DIR}/saved-plan.log"

[[ "${ENTERPRISE_TRIAL_CONFIRM:-}" == "YES" ]] || die "Set ENTERPRISE_TRIAL_CONFIRM=YES to authorize billable apply and mandatory cleanup."
run_step apply "${TOOL}" apply -no-color -auto-approve "${PLAN_FILE}" || die "Apply failed; inspect and clean up."
run_step verify "${SCRIPT_DIR}/verify-deployment.sh" "${TOOL}" "${ENV_DIR}" || true

start=$(epoch_seconds)
set +e
"${TOOL}" plan -detailed-exitcode -no-color >"${TRIAL_DIR}/idempotence.log" 2>&1
idempotence_exit=$?
set -e
end=$(epoch_seconds)
idempotence_seconds=$(elapsed_seconds "${start}" "${end}")
printf '%-14s exit=%s duration=%ss\n' idempotence "${idempotence_exit}" "${idempotence_seconds}"

run_step destroy "${TOOL}" destroy -no-color -auto-approve || die "Destroy failed; clean up immediately."
run_step cleanup "${SCRIPT_DIR}/verify-cleanup.sh" opentofu-thesis || die "Cleanup verification failed."

if [[ "${init_exit}" == 0 && "${validate_exit}" == 0 && "${plan_exit}" == 0 && "${apply_exit}" == 0 && "${verify_exit}" == 0 && "${idempotence_exit}" == 0 && "${destroy_exit}" == 0 && "${cleanup_exit}" == 0 ]]; then
  trial_status=success
fi

printf 'completed_at_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >>"${TRIAL_DIR}/metadata.txt"
finish
printf 'Trial %s finished with status: %s\n' "${TRIAL_ID}" "${trial_status}"
[[ "${trial_status}" == success ]]
