#!/usr/bin/env bash
set -euo pipefail

DISPLAY_ID="${DISPLAY_ID:-0}"
WIDTH="${WORKSTATION_WIDTH:-1920}"
HEIGHT="${WORKSTATION_HEIGHT:-1080}"
DEPTH="${WORKSTATION_DEPTH:-24}"
LOG_FILE="${WORKSPACE_DIR:-/workspace}/logs/xorg.log"

mkdir -p "$(dirname "${LOG_FILE}")" /etc/X11

cat > /etc/X11/xorg.conf <<EOF
Section "ServerLayout"
    Identifier "Layout0"
    Screen 0 "Screen0" 0 0
EndSection

Section "Device"
    Identifier "GPU0"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration" "true"
    Option "UseDisplayDevice" "None"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "GPU0"
    DefaultDepth ${DEPTH}
    SubSection "Display"
        Depth ${DEPTH}
        Virtual ${WIDTH} ${HEIGHT}
    EndSubSection
EndSection
EOF

exec Xorg ":${DISPLAY_ID}" \
  -noreset \
  +extension GLX \
  +extension RANDR \
  +extension RENDER \
  -logfile "${LOG_FILE}" \
  -config /etc/X11/xorg.conf
