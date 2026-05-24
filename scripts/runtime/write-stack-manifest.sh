#!/usr/bin/env bash
set -u

STACK_NAME="${1:-unknown}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
LOG_DIR="${WORKSPACE_DIR}/logs"
MANIFEST_PATH="${WORKSPACE_DIR}/.stack-manifest.json"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
MANIFEST_COPY="${LOG_DIR}/stack-manifest-${STACK_NAME}-${TIMESTAMP}.json"

mkdir -p "${LOG_DIR}"

cmd_or_unknown() {
  local command="$1"
  if command -v "${command}" >/dev/null 2>&1; then
    "${command}" --version 2>&1 | head -n 1 || true
  else
    echo "not-found"
  fi
}

python_version="$(python --version 2>&1 || true)"
gpu_name="$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1 || true)"
driver_version="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n 1 || true)"
cuda_version="$(nvidia-smi 2>/dev/null | sed -n 's/.*CUDA Version: \([^ |]*\).*/\1/p' | head -n 1 || true)"
torch_info="$(python - <<'PY' 2>/dev/null || true
try:
    import torch
    print(f"{torch.__version__}; cuda_available={torch.cuda.is_available()}; torch_cuda={torch.version.cuda}")
except Exception as exc:
    print(f"not-available: {exc}")
PY
)"
nerfstudio_info="$(python - <<'PY' 2>/dev/null || true
try:
    import nerfstudio
    print(getattr(nerfstudio, "__version__", "installed"))
except Exception as exc:
    print(f"not-available: {exc}")
PY
)"
gsplat_info="$(python - <<'PY' 2>/dev/null || true
try:
    import gsplat
    print(getattr(gsplat, "__version__", "installed"))
except Exception as exc:
    print(f"not-available: {exc}")
PY
)"
tinycudann_info="$(python - <<'PY' 2>/dev/null || true
try:
    import tinycudann
    print("installed")
except Exception as exc:
    print(f"not-available: {exc}")
PY
)"

jq -n \
  --arg stack_name "${STACK_NAME}" \
  --arg phase "${PIPELINE_PHASE:-DISCOVERY}" \
  --arg image_name "${IMAGE_NAME:-unknown}" \
  --arg image_tag "${IMAGE_TAG:-unknown}" \
  --arg created_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --arg hostname "$(hostname 2>/dev/null || true)" \
  --arg ubuntu "$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"' || true)" \
  --arg gpu "${gpu_name:-not-detected}" \
  --arg driver "${driver_version:-not-detected}" \
  --arg cuda "${cuda_version:-not-detected}" \
  --arg python "${python_version:-not-detected}" \
  --arg torch "${torch_info:-not-detected}" \
  --arg blender "$(cmd_or_unknown blender)" \
  --arg sunshine "$(cmd_or_unknown sunshine)" \
  --arg ffmpeg "$(ffmpeg -hide_banner -version 2>/dev/null | head -n 1 || echo not-found)" \
  --arg colmap "$(cmd_or_unknown colmap)" \
  --arg nerfstudio "${nerfstudio_info:-not-detected}" \
  --arg gsplat "${gsplat_info:-not-detected}" \
  --arg tinycudann "${tinycudann_info:-not-detected}" \
  --arg smoke_result "${SMOKE_TEST_RESULT:-not-run}" \
  --arg smoke_log "${SMOKE_TEST_LOG:-not-set}" \
  '{
    stack_name: $stack_name,
    phase: $phase,
    image: { name: $image_name, tag: $image_tag },
    created_at: $created_at,
    hostname: $hostname,
    os: $ubuntu,
    gpu: { name: $gpu, driver: $driver, cuda: $cuda },
    runtimes: {
      python: $python,
      torch: $torch,
      blender: $blender,
      sunshine: $sunshine,
      ffmpeg: $ffmpeg,
      colmap: $colmap,
      nerfstudio: $nerfstudio,
      gsplat: $gsplat,
      tinycudann: $tinycudann
    },
    smoke_tests: {
      result: $smoke_result,
      log: $smoke_log
    }
  }' > "${MANIFEST_PATH}"

cp "${MANIFEST_PATH}" "${MANIFEST_COPY}"
echo "Stack manifest written to ${MANIFEST_PATH} and ${MANIFEST_COPY}"
