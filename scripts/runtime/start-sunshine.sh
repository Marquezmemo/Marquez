#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:0}"
export HOME="${SUNSHINE_HOME:-/workspace/config/sunshine-home}"
CONFIG_DIR="${SUNSHINE_CONFIG_DIR:-/workspace/config/sunshine}"
CONFIG_FILE="${CONFIG_DIR}/sunshine.conf"

mkdir -p "${HOME}" "${CONFIG_DIR}" /workspace/logs

for _ in $(seq 1 90); do
  if xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

exec sunshine "${CONFIG_FILE}"
