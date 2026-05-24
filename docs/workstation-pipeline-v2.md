# Workstation Pipeline Architecture V2

This repository now builds two independent RunPod images:

- `blender-workstation`: GPU workstation for Blender, Sunshine/Moonlight, rendering, and visual asset workflows.
- `gs-training`: Gaussian Splatting training node for Nerfstudio, COLMAP, Jupyter, and long-running compute.

Both images publish to Docker Hub and GitHub Container Registry.

## Version Policy

### DISCOVERY

Initial validation uses modern recommended base images and may use `latest` tags.

Every Pod writes:

```text
/workspace/.stack-manifest.json
/workspace/logs/stack-manifest-<stack>-<timestamp>.json
```

The manifest records detected GPU, NVIDIA driver, CUDA, Python, Torch, Blender/Nerfstudio, COLMAP, gsplat, tiny-cuda-nn, Sunshine, and other runtime details.

### LOCKED

After successful RunPod smoke tests, all critical versions must be pinned:

- CUDA
- Ubuntu
- Python
- Torch
- Nerfstudio
- Blender
- Sunshine
- COLMAP
- gsplat
- tiny-cuda-nn

`latest` may remain as a convenience alias, but must not be the operational source of truth.

## Pod A: GS Training

Image:

```text
marquezmemo/gs-training:discovery
ghcr.io/marquezmemo/marquez/gs-training:discovery
```

Ports:

```text
8888  JupyterLab
7007  Nerfstudio viewer, when used
```

RunPod volume mount:

```text
/workspace
```

Expected layout:

```text
/workspace/envs
/workspace/datasets
/workspace/outputs
/workspace/checkpoints
/workspace/cache
/workspace/tmp
/workspace/logs
```

Recommended env vars:

```text
JUPYTER_TOKEN=<your-token>
```

## Pod B: Blender Workstation

Image:

```text
marquezmemo/blender-workstation:discovery
ghcr.io/marquezmemo/marquez/blender-workstation:discovery
```

RunPod volume mount:

```text
/workspace
```

Expected layout:

```text
/workspace/projects
/workspace/renders
/workspace/assets
/workspace/config
/workspace/cache
/workspace/logs
```

Primary access is Sunshine + Moonlight. Kasm/noVNC is fallback-only and is not the target workstation UX.

Important Sunshine ports:

```text
TCP: 47984, 47989, 47990, 48010
UDP: 47998, 47999, 48000, 48002, 48010
```

Useful env vars:

```text
WORKSTATION_WIDTH=1920
WORKSTATION_HEIGHT=1080
WORKSTATION_DEPTH=24
BLENDER_AUTOSTART=true
```

## RunPod Smoke Tests

### GS Training

- Jupyter opens on `8888`.
- `nvidia-smi` detects GPU.
- Torch reports CUDA available.
- `ns-train --help` works.
- COLMAP is available or recorded missing in the manifest.
- `/workspace/.stack-manifest.json` exists.

### Blender Workstation

- Sunshine starts and allows Moonlight pairing.
- Blender 5.1.2 opens.
- RTX 4090/3090 appears in Blender CUDA/OptiX.
- Viewport interaction is smooth enough for real editing.
- GPU render works.
- NVENC appears in ffmpeg encoders.
- `/workspace/.stack-manifest.json` exists.
