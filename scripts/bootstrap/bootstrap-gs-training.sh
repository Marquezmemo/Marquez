#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
STACK_VERSION="${GS_STACK_VERSION:-DISCOVERY-1}"
LOG_DIR="${WORKSPACE_DIR}/logs"

/opt/pipeline/scripts/runtime/wait-for-workspace.sh

mkdir -p \
  "${WORKSPACE_DIR}/envs" \
  "${WORKSPACE_DIR}/datasets" \
  "${WORKSPACE_DIR}/outputs" \
  "${WORKSPACE_DIR}/checkpoints" \
  "${WORKSPACE_DIR}/cache" \
  "${WORKSPACE_DIR}/tmp" \
  "${WORKSPACE_DIR}/backups" \
  "${WORKSPACE_DIR}/manifests" \
  "${LOG_DIR}"

echo "GS_STACK_VERSION=${STACK_VERSION}" > "${WORKSPACE_DIR}/.gs-stack-version"

SMOKE_TEST_LOG="${LOG_DIR}/gs-training-validation.log"
if /opt/pipeline/scripts/validation/validate-gs-training.sh > "${SMOKE_TEST_LOG}" 2>&1; then
  SMOKE_TEST_RESULT="completed"
else
  SMOKE_TEST_RESULT="failed"
fi

SMOKE_TEST_RESULT="${SMOKE_TEST_RESULT}" \
SMOKE_TEST_LOG="${SMOKE_TEST_LOG}" \
  /opt/pipeline/scripts/runtime/write-stack-manifest.sh gs-training || true

echo "GS training bootstrap complete"
