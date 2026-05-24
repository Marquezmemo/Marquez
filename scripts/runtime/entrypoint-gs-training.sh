#!/usr/bin/env bash
set -euo pipefail

/opt/pipeline/scripts/runtime/wait-for-workspace.sh

mkdir -p /workspace/logs
exec /usr/bin/supervisord -c /opt/pipeline/configs/supervisor/gs-training.conf
