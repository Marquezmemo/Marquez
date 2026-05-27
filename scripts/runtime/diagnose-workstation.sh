#!/usr/bin/env bash
set -u

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
DISPLAY="${DISPLAY:-:0}"
LOG_DIR="${WORKSPACE_DIR}/logs"
DIAG_LOG="${LOG_DIR}/workstation-diagnostics.log"
SUMMARY_LOG="${LOG_DIR}/workstation-failure-summary.log"
BLENDER_GPU_SMOKE_LOG="${LOG_DIR}/blender-gpu-smoke.log"

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

run_blender_gpu_smoke() {
  if ! command -v blender >/dev/null 2>&1; then
    echo "blender not installed" > "${BLENDER_GPU_SMOKE_LOG}"
    return 0
  fi

  timeout "${BLENDER_GPU_SMOKE_TIMEOUT:-45}" blender --background --python-expr '
import bpy
print("BLENDER_VERSION", bpy.app.version_string)
prefs = bpy.context.preferences
cycles = prefs.addons.get("cycles")
if cycles is None:
    print("CYCLES_ADDON not-loaded")
else:
    cprefs = cycles.preferences
    for device_type in ("CUDA", "OPTIX", "HIP", "ONEAPI", "METAL", "NONE"):
        try:
            cprefs.compute_device_type = device_type
            devices = cprefs.get_devices()
            print("COMPUTE_DEVICE_TYPE", device_type)
            for device in cprefs.devices:
                print("DEVICE", device_type, device.name, device.type, device.use)
        except Exception as exc:
            print("DEVICE_QUERY_FAILED", device_type, repr(exc))
' > "${BLENDER_GPU_SMOKE_LOG}" 2>&1 || true
}

run_blender_gpu_smoke

{
  section "diagnostic timestamp"
  date -Is

  section "environment"
  env | sort

  section "display"
  echo "DISPLAY=${DISPLAY}"
  echo "XORG_DRIVER_MODE=${XORG_DRIVER_MODE:-unknown}"

  section "processes"
  ps aux 2>&1 | grep -E 'Xorg|openbox|sunshine|blender' || true

  section "xdpyinfo ${DISPLAY}"
  xdpyinfo -display "${DISPLAY}" 2>&1 || true

  section "xrandr ${DISPLAY}"
  xrandr -display "${DISPLAY}" 2>&1 || true

  section "listening ports"
  if command -v ss >/dev/null 2>&1; then
    ss -tulpn 2>&1 || true
  else
    echo "ss not installed"
  fi

  section "nvidia-smi"
  nvidia-smi 2>&1 || true

  section "ffmpeg nvenc encoders"
  ffmpeg -hide_banner -encoders 2>/dev/null | grep -i nvenc || true

  section "glxinfo -B"
  glxinfo -B 2>&1 || true

  section "vulkaninfo --summary"
  vulkaninfo --summary 2>&1 || true

  collect_file "${LOG_DIR}/workstation-session.log"
  collect_file "${LOG_DIR}/openbox.log"
  collect_file "${LOG_DIR}/openbox.err"
  collect_file "${LOG_DIR}/sunshine.log"
  collect_file "${LOG_DIR}/sunshine.err"
  collect_file "${LOG_DIR}/blender.log"
  collect_file "${LOG_DIR}/blender-supervisor.log"
  collect_file "${LOG_DIR}/blender-supervisor.err"
  collect_file "${BLENDER_GPU_SMOKE_LOG}"
} > "${DIAG_LOG}" 2>&1

{
  echo "Workstation failure summary"
  echo "Generated: $(date -Is)"
  echo
  echo "Primary log files:"
  echo "- ${DIAG_LOG}"
  echo "- ${SUMMARY_LOG}"
  echo "- ${BLENDER_GPU_SMOKE_LOG}"
  echo "- ${LOG_DIR}/sunshine.log"
  echo "- ${LOG_DIR}/openbox.log"
  echo "- ${LOG_DIR}/blender.log"
  echo
  echo "Likely workstation root-cause lines:"
  grep -Eini \
    'error|failed|fatal|permission denied|nvenc|encoder|capture|display|x11|cuda|optix|vulkan|glx|port|bind|pair' \
    "${DIAG_LOG}" "${LOG_DIR}/sunshine.log" "${LOG_DIR}/sunshine.err" "${BLENDER_GPU_SMOKE_LOG}" 2>/dev/null | head -n 160 || true
} > "${SUMMARY_LOG}" 2>&1

echo "Workstation diagnostics written to ${DIAG_LOG}"
echo "Workstation failure summary written to ${SUMMARY_LOG}"
echo "Blender GPU smoke written to ${BLENDER_GPU_SMOKE_LOG}"
