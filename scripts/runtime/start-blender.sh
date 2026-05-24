#!/usr/bin/env bash
set -euo pipefail

if [ "${BLENDER_AUTOSTART:-true}" != "true" ]; then
  echo "BLENDER_AUTOSTART is not true; Blender will not autostart."
  exit 0
fi

export DISPLAY="${DISPLAY:-:0}"
BLENDER_VERSION="${BLENDER_VERSION:-5.1.2}"
BLENDER_CONFIG_DIR="${BLENDER_CONFIG_DIR:-${WORKSPACE_DIR:-/workspace}/config/blender/${BLENDER_VERSION}}"
LOG_FILE="${WORKSPACE_DIR:-/workspace}/logs/blender.log"
mkdir -p "$(dirname "${LOG_FILE}")"
mkdir -p "${BLENDER_CONFIG_DIR}"
export BLENDER_USER_CONFIG="${BLENDER_CONFIG_DIR}/config"
export BLENDER_USER_SCRIPTS="${BLENDER_CONFIG_DIR}/scripts"
export BLENDER_USER_DATAFILES="${BLENDER_CONFIG_DIR}/datafiles"
mkdir -p "${BLENDER_USER_CONFIG}" "${BLENDER_USER_SCRIPTS}" "${BLENDER_USER_DATAFILES}"

for _ in $(seq 1 90); do
  if xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

cd "${WORKSPACE_DIR:-/workspace}/projects"
exec blender >> "${LOG_FILE}" 2>&1
