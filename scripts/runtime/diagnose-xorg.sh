#!/usr/bin/env bash
set -u

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
DISPLAY="${DISPLAY:-:0}"
LOG_DIR="${WORKSPACE_DIR}/logs"
DIAG_LOG="${LOG_DIR}/xorg-diagnostics.log"
SUMMARY_LOG="${LOG_DIR}/xorg-failure-summary.log"

mkdir -p "${LOG_DIR}"

section() {
  printf '\n\n===== %s =====\n' "$1"
}

collect_file() {
  local file="$1"
  if [ -f "${file}" ]; then
    section "${file}"
    sed -n '1,260p' "${file}" 2>&1
  else
    section "${file}"
    echo "not-found"
  fi
}

{
  section "diagnostic timestamp"
  date -Is

  section "environment"
  env | sort

  section "processes"
  ps aux 2>&1 || true

  section "nvidia-smi"
  nvidia-smi 2>&1 || true

  section "/dev/nvidia*"
  ls -la /dev/nvidia* 2>&1 || true

  section "nvidia modules"
  lsmod 2>/dev/null | grep -i nvidia 2>&1 || true

  section "ldconfig nvidia/glx/vulkan"
  ldconfig -p 2>/dev/null | grep -Ei 'nvidia|glx|vulkan' 2>&1 || true

  section "glxinfo -B"
  if command -v glxinfo >/dev/null 2>&1; then
    glxinfo -B 2>&1 || true
  else
    echo "glxinfo not installed"
  fi

  section "xdpyinfo ${DISPLAY}"
  if command -v xdpyinfo >/dev/null 2>&1; then
    xdpyinfo -display "${DISPLAY}" 2>&1 || true
  else
    echo "xdpyinfo not installed"
  fi

  collect_file "${LOG_DIR}/xorg.log"
  collect_file "${LOG_DIR}/xorg.stdout.log"
  collect_file "${LOG_DIR}/xorg.stderr.log"
  collect_file "${LOG_DIR}/xorg-supervisor.log"
  collect_file "${LOG_DIR}/xorg-supervisor.err"
  collect_file "/var/log/Xorg.0.log"

  section "user xorg logs"
  find /root/.local/share/xorg /home -path '*/.local/share/xorg/*.log' -type f -print 2>/dev/null | while read -r log_file; do
    collect_file "${log_file}"
  done
} > "${DIAG_LOG}" 2>&1

{
  echo "Xorg failure summary"
  echo "Generated: $(date -Is)"
  echo
  echo "Primary log files:"
  echo "- ${LOG_DIR}/xorg.log"
  echo "- ${LOG_DIR}/xorg.stdout.log"
  echo "- ${LOG_DIR}/xorg.stderr.log"
  echo "- ${DIAG_LOG}"
  echo
  echo "Likely root-cause lines:"
  grep -Eini \
    'no screens found|failed to load.*nvidia|nvidia.*failed|glx.*failed|no devices detected|no display devices|module.*not found|permission denied|fatal server error|failed to initialize|cannot open|not found|error' \
    "${LOG_DIR}/xorg.log" \
    "${LOG_DIR}/xorg.stdout.log" \
    "${LOG_DIR}/xorg.stderr.log" \
    /var/log/Xorg.0.log \
    "${DIAG_LOG}" 2>/dev/null | head -n 120 || true
} > "${SUMMARY_LOG}" 2>&1

echo "Xorg diagnostics written to ${DIAG_LOG}"
echo "Xorg failure summary written to ${SUMMARY_LOG}"
