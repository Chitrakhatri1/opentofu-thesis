#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  printf 'Usage: %s <terraform|tofu> <trial-id> <cache-condition>\n' "$0"
  exit 0
fi

configure_tool "${1:-}"
TRIAL_NUMBER=${2:-}
CACHE_CONDITION=${3:-}

[[ "${TRIAL_NUMBER}" =~ ^[A-Za-z0-9._-]+$ ]] || die "Trial ID must contain only letters, numbers, dots, underscores, or hyphens."
[[ "${CACHE_CONDITION}" =~ ^[A-Za-z0-9._-]+$ ]] || die "Cache condition must be a short label such as warm."

require_environment
select_expected_workspace

TRIAL_ID="${TOOL}-trial-${TRIAL_NUMBER}"
TRIAL_DIR="${RAW_RESULTS_DIR}/${TRIAL_ID}"
SUMMARY_FILE="${PROCESSED_RESULTS_DIR}/comparison.csv"
PLAN_FILE="${ENV_DIR}/${TOOL}-${TRIAL_NUMBER}.tfplan"

[[ ! -e "${TRIAL_DIR}" ]] || die "Trial directory already exists: ${TRIAL_DIR}"
mkdir -p "${TRIAL_DIR}" "${PROCESSED_RESULTS_DIR}"

git_commit=$(git -C "${REPO_ROOT}" rev-parse HEAD)
git_status=$(git -C "${REPO_ROOT}" status --porcelain -- . ':(exclude)experiments/results/processed/comparison.csv')
[[ -z "${git_status}" ]] || die "Git working tree must be clean before a formal trial."

printf 'trial_id=%s\n' "${TRIAL_ID}" >"${TRIAL_DIR}/metadata.txt"
printf 'tool=%s\n' "${TOOL}" >>"${TRIAL_DIR}/metadata.txt"
printf 'git_commit=%s\n' "${git_commit}" >>"${TRIAL_DIR}/metadata.txt"
printf 'region=%s\n' "${AWS_REGION}" >>"${TRIAL_DIR}/metadata.txt"
printf 'cache_condition=%s\n' "${CACHE_CONDITION}" >>"${TRIAL_DIR}/metadata.txt"
printf 'started_at_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >>"${TRIAL_DIR}/metadata.txt"
"${TOOL}" version >"${TRIAL_DIR}/tool-version.log" 2>&1
"${TOOL}" providers >"${TRIAL_DIR}/providers.log" 2>&1

init_seconds=0
init_exit=99
validate_seconds=0
validate_exit=99
plan_seconds=0
plan_exit=99
apply_seconds=0
apply_exit=99
verify_seconds=0
verify_exit=99
idempotence_seconds=0
idempotence_exit=99
destroy_seconds=0
destroy_exit=99
cleanup_seconds=0
cleanup_exit=99
trial_status=failed

write_summary() {
  if [[ ! -f "${SUMMARY_FILE}" ]]; then
    printf '%s\n' "${csv_header}" >"${SUMMARY_FILE}"
  fi

  printf '%s\n' "${TRIAL_ID},${TOOL},${git_commit},${AWS_REGION},${CACHE_CONDITION},${init_seconds},${init_exit},${validate_seconds},${validate_exit},${plan_seconds},${plan_exit},${apply_seconds},${apply_exit},${verify_seconds},${verify_exit},${idempotence_seconds},${idempotence_exit},${destroy_seconds},${destroy_exit},${cleanup_seconds},${cleanup_exit},${trial_status}" >>"${SUMMARY_FILE}"
}

summary_written=false
finish() {
  if [[ "${summary_written}" == "false" ]]; then
    write_summary
    summary_written=true
  fi
}
trap finish EXIT

run_step() {
  local step=$1
  shift
  local start end result duration

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

printf 'Checking that the environment is empty before %s...\n' "${TRIAL_ID}"
"${SCRIPT_DIR}/verify-cleanup.sh" "${TOOL}" | tee "${TRIAL_DIR}/preflight-cleanup.log"

cd "${ENV_DIR}"
run_step init "${TOOL}" init -no-color || die "Initialization failed. See ${TRIAL_DIR}/init.log"
run_step validate "${TOOL}" validate -no-color || die "Validation failed. See ${TRIAL_DIR}/validate.log"
run_step plan "${TOOL}" plan -no-color -out="${PLAN_FILE}" || die "Plan failed. See ${TRIAL_DIR}/plan.log"

"${TOOL}" show -no-color "${PLAN_FILE}" >"${TRIAL_DIR}/saved-plan.log"
tail -n 20 "${TRIAL_DIR}/plan.log"

printf '\nThis apply creates billable AWS resources, including an Application Load Balancer.\n'
read -r -p "Type APPLY ${TRIAL_ID} to continue: " apply_confirmation
[[ "${apply_confirmation}" == "APPLY ${TRIAL_ID}" ]] || die "Apply cancelled."

run_step apply "${TOOL}" apply -no-color -auto-approve "${PLAN_FILE}" || die "Apply failed. Inspect the log and clean up any partial resources."
run_step verify "${SCRIPT_DIR}/verify-deployment.sh" "${TOOL}" || true

start=$(epoch_seconds)
set +e
"${TOOL}" plan -detailed-exitcode -no-color >"${TRIAL_DIR}/idempotence.log" 2>&1
idempotence_exit=$?
set -e
end=$(epoch_seconds)
idempotence_seconds=$(elapsed_seconds "${start}" "${end}")
printf '%-14s exit=%s duration=%ss\n' idempotence "${idempotence_exit}" "${idempotence_seconds}"

if [[ "${idempotence_exit}" != "0" ]]; then
  printf 'WARNING: Idempotence did not pass. Review %s before interpreting this trial.\n' "${TRIAL_DIR}/idempotence.log" >&2
fi

printf '\nEvidence collection is complete. Destruction is required to stop charges and prepare the next trial.\n'
read -r -p "Type DESTROY ${TRIAL_ID} to continue: " destroy_confirmation
[[ "${destroy_confirmation}" == "DESTROY ${TRIAL_ID}" ]] || die "Destroy cancelled. Resources remain live."

run_step destroy "${TOOL}" destroy -no-color -auto-approve || die "Destroy failed. Inspect the log and clean up manually."
run_step cleanup "${SCRIPT_DIR}/verify-cleanup.sh" "${TOOL}" || die "Cleanup verification failed."

if [[ "${init_exit}" == "0" && "${validate_exit}" == "0" && "${plan_exit}" == "0" && "${apply_exit}" == "0" && "${verify_exit}" == "0" && "${idempotence_exit}" == "0" && "${destroy_exit}" == "0" && "${cleanup_exit}" == "0" ]]; then
  trial_status=success
fi

printf 'completed_at_utc=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" >>"${TRIAL_DIR}/metadata.txt"
finish

printf '\nTrial %s finished with status: %s\n' "${TRIAL_ID}" "${trial_status}"
printf 'Raw logs: %s\n' "${TRIAL_DIR}"
printf 'Summary:  %s\n' "${SUMMARY_FILE}"

[[ "${trial_status}" == "success" ]]
