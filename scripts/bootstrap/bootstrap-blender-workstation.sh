#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
STACK_VERSION="${BLENDER_STACK_VERSION:-DISCOVERY-1}"
LOG_DIR="${WORKSPACE_DIR}/logs"

mkdir -p \
  "${WORKSPACE_DIR}/projects" \
  "${WORKSPACE_DIR}/renders" \
  "${WORKSPACE_DIR}/assets" \
  "${WORKSPACE_DIR}/config/sunshine" \
  "${WORKSPACE_DIR}/cache" \
  "${LOG_DIR}"

echo "BLENDER_STACK_VERSION=${STACK_VERSION}" > "${WORKSPACE_DIR}/.blender-stack-version"

if [ ! -f "${WORKSPACE_DIR}/config/sunshine/sunshine.conf" ]; then
  cp /opt/pipeline/configs/sunshine/sunshine.conf "${WORKSPACE_DIR}/config/sunshine/sunshine.conf"
fi

if [ ! -f "${WORKSPACE_DIR}/config/sunshine/apps.json" ]; then
  cp /opt/pipeline/configs/sunshine/apps.json "${WORKSPACE_DIR}/config/sunshine/apps.json"
fi

SMOKE_TEST_LOG="${LOG_DIR}/blender-validation.log"
if /opt/pipeline/scripts/validation/validate-blender-workstation.sh > "${SMOKE_TEST_LOG}" 2>&1; then
  SMOKE_TEST_RESULT="completed"
else
  SMOKE_TEST_RESULT="failed"
fi

SMOKE_TEST_RESULT="${SMOKE_TEST_RESULT}" \
SMOKE_TEST_LOG="${SMOKE_TEST_LOG}" \
  /opt/pipeline/scripts/runtime/write-stack-manifest.sh blender-workstation || true

echo "Blender workstation bootstrap complete"
