#!/usr/bin/env bash
set -euo pipefail

BLENDER_BIN="/opt/blender-5.1.2-linux-x64/blender"
LOG_DIR="${BLENDER_LOG_DIR:-/workspace/logs}"

mkdir -p "${LOG_DIR}" 2>/dev/null || LOG_DIR="/tmp"
LOG_FILE="${LOG_DIR}/blender-startup.log"

{
  echo "==== Blender startup $(date -Is) ===="
  echo "User: $(id)"
  echo "Display: ${DISPLAY:-unset}"
  echo "PATH: ${PATH:-unset}"
  echo "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH:-unset}"
  echo "Blender binary: ${BLENDER_BIN}"
  ldd "${BLENDER_BIN}" | grep -E "vulkan|GL|cuda|nvidia" || true
} >>"${LOG_FILE}" 2>&1

export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH:-}"

exec "${BLENDER_BIN}" "$@" >>"${LOG_FILE}" 2>&1
