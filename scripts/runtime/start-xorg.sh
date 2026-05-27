#!/usr/bin/env bash
set -euo pipefail

DISPLAY_ID="${DISPLAY_ID:-0}"
WIDTH="${WORKSTATION_WIDTH:-1920}"
HEIGHT="${WORKSTATION_HEIGHT:-1080}"
DEPTH="${WORKSTATION_DEPTH:-24}"
REFRESH="${WORKSTATION_REFRESH:-60}"
XORG_DRIVER_MODE="${XORG_DRIVER_MODE:-dummy}"
VIDEO_RAM_KB="${XORG_DUMMY_VIDEO_RAM_KB:-256000}"
LOG_FILE="${WORKSPACE_DIR:-/workspace}/logs/xorg.log"
STDOUT_LOG="${WORKSPACE_DIR:-/workspace}/logs/xorg.stdout.log"
STDERR_LOG="${WORKSPACE_DIR:-/workspace}/logs/xorg.stderr.log"
MODELINE_NAME="${WIDTH}x${HEIGHT}"

mkdir -p "$(dirname "${LOG_FILE}")" /etc/X11

if command -v cvt >/dev/null 2>&1; then
  MODELINE="$(cvt "${WIDTH}" "${HEIGHT}" "${REFRESH}" | sed -n 's/^Modeline //p' | head -n 1)"
else
  MODELINE="\"1920x1080_60.00\" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync"
  MODELINE_NAME="1920x1080_60.00"
fi

{
  echo "XORG_DRIVER_MODE=${XORG_DRIVER_MODE}"
  echo "DISPLAY=:${DISPLAY_ID}"
  echo "WORKSTATION_WIDTH=${WIDTH}"
  echo "WORKSTATION_HEIGHT=${HEIGHT}"
  echo "WORKSTATION_REFRESH=${REFRESH}"
  echo "WORKSTATION_DEPTH=${DEPTH}"
  echo "XORG_DUMMY_VIDEO_RAM_KB=${VIDEO_RAM_KB}"
  echo "MODELINE=${MODELINE}"
} > "${WORKSPACE_DIR:-/workspace}/logs/xorg-config-summary.log"

cat > /etc/X11/xorg.conf <<EOF
Section "ServerLayout"
    Identifier "Layout0"
    Screen 0 "Screen0" 0 0
EndSection

Section "Device"
    Identifier "DummyGPU0"
    Driver "dummy"
    VideoRam ${VIDEO_RAM_KB}
EndSection

Section "Monitor"
    Identifier "DummyMonitor0"
    HorizSync 28.0-160.0
    VertRefresh 48.0-144.0
    Modeline ${MODELINE}
    Option "PreferredMode" "${MODELINE_NAME}"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "DummyGPU0"
    Monitor "DummyMonitor0"
    DefaultDepth ${DEPTH}
    SubSection "Display"
        Depth ${DEPTH}
        Modes "${MODELINE_NAME}"
        Virtual ${WIDTH} ${HEIGHT}
    EndSubSection
EndSection
EOF

set +e
Xorg ":${DISPLAY_ID}" \
  -noreset \
  -verbose 6 \
  -logverbose 6 \
  +extension GLX \
  +extension RANDR \
  +extension RENDER \
  -logfile "${LOG_FILE}" \
  -config /etc/X11/xorg.conf \
  > "${STDOUT_LOG}" \
  2> "${STDERR_LOG}"
status=$?
set -e

echo "Xorg exited with status ${status} at $(date -Is)" >> "${STDERR_LOG}"
/opt/pipeline/scripts/runtime/diagnose-xorg.sh || true
exit "${status}"
