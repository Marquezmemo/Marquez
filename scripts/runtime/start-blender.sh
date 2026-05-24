#!/usr/bin/env bash
set -euo pipefail

if [ "${BLENDER_AUTOSTART:-true}" != "true" ]; then
  echo "BLENDER_AUTOSTART is not true; Blender will not autostart."
  exit 0
fi

export DISPLAY="${DISPLAY:-:0}"
LOG_FILE="${WORKSPACE_DIR:-/workspace}/logs/blender.log"
mkdir -p "$(dirname "${LOG_FILE}")"

for _ in $(seq 1 90); do
  if xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

cd "${WORKSPACE_DIR:-/workspace}/projects"
exec blender >> "${LOG_FILE}" 2>&1
