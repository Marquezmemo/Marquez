#!/usr/bin/env bash
set -u

echo "== Blender workstation validation =="
nvidia-smi || true
blender --version || true
sunshine --version || true
ffmpeg -hide_banner -encoders 2>/dev/null | grep -i nvenc || true
xdpyinfo -display "${DISPLAY:-:0}" || true
xrandr -display "${DISPLAY:-:0}" || true
ss -tulpn || true
glxinfo -B || true
vulkaninfo --summary || true
rclone version || true
echo "== End validation =="
