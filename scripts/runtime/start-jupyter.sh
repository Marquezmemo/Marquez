#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
JUPYTER_PORT="${JUPYTER_PORT:-8888}"
JUPYTER_TOKEN="${JUPYTER_TOKEN:-runpod}"

mkdir -p "${WORKSPACE_DIR}/logs"
cd "${WORKSPACE_DIR}"

exec python -m jupyter lab \
  --ip=0.0.0.0 \
  --port="${JUPYTER_PORT}" \
  --no-browser \
  --allow-root \
  --ServerApp.root_dir="${WORKSPACE_DIR}" \
  --ServerApp.token="${JUPYTER_TOKEN}" \
  --ServerApp.password=""
