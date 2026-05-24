#!/usr/bin/env bash
set -euo pipefail

mkdir -p /workspace/logs
exec /usr/bin/supervisord -c /opt/pipeline/configs/supervisor/gs-training.conf
