#!/usr/bin/env bash
set -euo pipefail

/opt/pipeline/scripts/runtime/wait-for-workspace.sh

mkdir -p /workspace/logs /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

exec /usr/bin/supervisord -c /opt/pipeline/configs/supervisor/blender-workstation.conf
