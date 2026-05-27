#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
DISPLAY="${DISPLAY:-:0}"
LOG_DIR="${WORKSPACE_DIR}/logs"
mkdir -p "${LOG_DIR}"

echo "workstation-session: waiting for healthy Xorg" | tee -a "${LOG_DIR}/workstation-session.log"
if ! /opt/pipeline/scripts/runtime/wait-for-xorg-ready.sh; then
  echo "workstation-session: Xorg failed readiness gate; not starting Openbox/Sunshine/Blender" | tee -a "${LOG_DIR}/workstation-session.log"
  exit 1
fi

/opt/pipeline/scripts/runtime/diagnose-workstation.sh || true

echo "workstation-session: Xorg healthy; starting Openbox" | tee -a "${LOG_DIR}/workstation-session.log"
DISPLAY="${DISPLAY}" /opt/pipeline/scripts/runtime/start-openbox.sh >> "${LOG_DIR}/openbox.log" 2>> "${LOG_DIR}/openbox.err" &
openbox_pid=$!

sleep 2

echo "workstation-session: starting Sunshine" | tee -a "${LOG_DIR}/workstation-session.log"
DISPLAY="${DISPLAY}" /opt/pipeline/scripts/runtime/start-sunshine.sh >> "${LOG_DIR}/sunshine.log" 2>> "${LOG_DIR}/sunshine.err" &
sunshine_pid=$!

sleep 2
/opt/pipeline/scripts/runtime/diagnose-workstation.sh || true

if [ "${BLENDER_AUTOSTART:-true}" = "true" ]; then
  sleep 2
  echo "workstation-session: starting Blender" | tee -a "${LOG_DIR}/workstation-session.log"
  DISPLAY="${DISPLAY}" /opt/pipeline/scripts/runtime/start-blender.sh >> "${LOG_DIR}/blender-supervisor.log" 2>> "${LOG_DIR}/blender-supervisor.err" &
  blender_pid=$!
else
  blender_pid=""
  echo "workstation-session: BLENDER_AUTOSTART is not true; skipping Blender autostart" | tee -a "${LOG_DIR}/workstation-session.log"
fi

terminate_children() {
  echo "workstation-session: terminating child processes" | tee -a "${LOG_DIR}/workstation-session.log"
  kill "${openbox_pid}" "${sunshine_pid}" ${blender_pid:+"${blender_pid}"} 2>/dev/null || true
}

trap terminate_children TERM INT

while true; do
  if ! pgrep -x Xorg >/dev/null 2>&1; then
    echo "workstation-session: Xorg exited after session start" | tee -a "${LOG_DIR}/workstation-session.log"
    /opt/pipeline/scripts/runtime/diagnose-xorg.sh || true
    /opt/pipeline/scripts/runtime/diagnose-workstation.sh || true
    terminate_children
    exit 1
  fi

  if ! kill -0 "${openbox_pid}" 2>/dev/null; then
    echo "workstation-session: Openbox exited" | tee -a "${LOG_DIR}/workstation-session.log"
    /opt/pipeline/scripts/runtime/diagnose-workstation.sh || true
    terminate_children
    exit 1
  fi

  if ! kill -0 "${sunshine_pid}" 2>/dev/null; then
    echo "workstation-session: Sunshine exited" | tee -a "${LOG_DIR}/workstation-session.log"
    /opt/pipeline/scripts/runtime/diagnose-workstation.sh || true
    terminate_children
    exit 1
  fi

  sleep 5
done
