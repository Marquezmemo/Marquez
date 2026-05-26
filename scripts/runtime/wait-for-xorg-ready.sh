#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
DISPLAY="${DISPLAY:-:0}"
XORG_READY_TIMEOUT="${XORG_READY_TIMEOUT:-45}"
XORG_STABLE_SECONDS="${XORG_STABLE_SECONDS:-5}"
LOG_DIR="${WORKSPACE_DIR}/logs"
READY_LOG="${LOG_DIR}/xorg-ready.log"
deadline=$((SECONDS + XORG_READY_TIMEOUT))

mkdir -p "${LOG_DIR}"

echo "Waiting for Xorg on ${DISPLAY}; timeout=${XORG_READY_TIMEOUT}s stable=${XORG_STABLE_SECONDS}s" > "${READY_LOG}"

while true; do
  if pgrep -x Xorg >/dev/null 2>&1 && xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
    echo "Xorg responded to xdpyinfo at $(date -Is); checking stability..." >> "${READY_LOG}"
    sleep "${XORG_STABLE_SECONDS}"

    if pgrep -x Xorg >/dev/null 2>&1 && xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
      echo "Xorg is ready and stable at $(date -Is)" >> "${READY_LOG}"
      exit 0
    fi

    echo "Xorg responded but did not remain stable at $(date -Is)" >> "${READY_LOG}"
  fi

  if [ "${SECONDS}" -ge "${deadline}" ]; then
    echo "Xorg did not become ready before timeout at $(date -Is)" >> "${READY_LOG}"
    /opt/pipeline/scripts/runtime/diagnose-xorg.sh || true
    exit 1
  fi

  sleep 1
done
