#!/usr/bin/env bash
set -u

echo "== GS training validation =="
nvidia-smi || true
python --version || true
python - <<'PY' || true
import torch
print("torch", torch.__version__)
print("cuda available", torch.cuda.is_available())
print("torch cuda", torch.version.cuda)
PY
ns-train --help >/dev/null && echo "ns-train available" || true
colmap -h >/dev/null && echo "colmap available" || true
python - <<'PY' || true
for name in ("nerfstudio", "gsplat", "tinycudann"):
    try:
        module = __import__(name)
        print(name, getattr(module, "__version__", "installed"))
    except Exception as exc:
        print(name, "not-available", exc)
PY
echo "== End validation =="
