#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
STACK_VERSION="${BLENDER_STACK_VERSION:-DISCOVERY-1}"
BLENDER_VERSION="${BLENDER_VERSION:-5.1.2}"
LOG_DIR="${WORKSPACE_DIR}/logs"
BLENDER_CONFIG_DIR="${WORKSPACE_DIR}/config/blender/${BLENDER_VERSION}"

/opt/pipeline/scripts/runtime/wait-for-workspace.sh

mkdir -p \
  "${WORKSPACE_DIR}/projects" \
  "${WORKSPACE_DIR}/renders" \
  "${WORKSPACE_DIR}/assets" \
  "${WORKSPACE_DIR}/config/sunshine" \
  "${BLENDER_CONFIG_DIR}" \
  "${WORKSPACE_DIR}/cache" \
  "${WORKSPACE_DIR}/backups" \
  "${WORKSPACE_DIR}/manifests" \
  "${LOG_DIR}"

echo "BLENDER_STACK_VERSION=${STACK_VERSION}" > "${WORKSPACE_DIR}/.blender-stack-version"

if [ ! -f "${WORKSPACE_DIR}/config/sunshine/sunshine.conf" ]; then
  cp /opt/pipeline/configs/sunshine/sunshine.conf "${WORKSPACE_DIR}/config/sunshine/sunshine.conf"
fi

if [ ! -f "${WORKSPACE_DIR}/config/sunshine/apps.json" ]; then
  cp /opt/pipeline/configs/sunshine/apps.json "${WORKSPACE_DIR}/config/sunshine/apps.json"
fi

echo "BLENDER_VERSION=${BLENDER_VERSION}" > "${BLENDER_CONFIG_DIR}/.blender-config-version"

SMOKE_TEST_LOG="${LOG_DIR}/blender-validation.log"
if /opt/pipeline/scripts/validation/validate-blender-workstation.sh > "${SMOKE_TEST_LOG}" 2>&1; then
  SMOKE_TEST_RESULT="completed"
else
  SMOKE_TEST_RESULT="failed"
fi

SMOKE_TEST_RESULT="${SMOKE_TEST_RESULT}" \
SMOKE_TEST_LOG="${SMOKE_TEST_LOG}" \
BLENDER_CONFIG_DIR="${BLENDER_CONFIG_DIR}" \
XORG_FAILURE_SUMMARY="${LOG_DIR}/xorg-failure-summary.log" \
XORG_DIAGNOSTICS_LOG="${LOG_DIR}/xorg-diagnostics.log" \
  /opt/pipeline/scripts/runtime/write-stack-manifest.sh blender-workstation || true

echo "Blender workstation bootstrap complete"
