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
/workspace/manifests/stack-manifest-<stack>-<timestamp>.json
```

The manifest records detected GPU, NVIDIA driver, CUDA, Python, Torch, Blender/Nerfstudio, COLMAP, gsplat, tiny-cuda-nn, Sunshine, and other runtime details.

Bootstrap and runtime scripts refuse to initialize until `/workspace` is mounted and writable.

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
/workspace/backups
/workspace/manifests
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
/workspace/backups
/workspace/manifests
/workspace/logs
```

Blender configuration is version-aware:

```text
/workspace/config/blender/5.1.2/
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
WORKSPACE_WAIT_TIMEOUT=120
BLENDER_AUTOSTART=true
```

## Reliability and Recovery

- `/workspace` must be a mounted writable persistent volume before any bootstrap or runtime initialization.
- Historical stack manifests are retained in `/workspace/manifests`.
- Logs are retained in `/workspace/logs`.
- Manual backup targets should use `/workspace/backups`.
- Rollback is controlled and manifest-driven: recreate the Pod with a previous image tag and restore matching config/assets from the persistent volume or backup.

## Sunshine Security

Sunshine must not be treated as safe on unrestricted public endpoints.

Minimum V1 posture:

- keep Sunshine pairing/authentication enabled,
- expose only required Sunshine ports,
- prefer RunPod/private networking restrictions where available,
- move to SSH tunnels, Tailscale, VPN, or private networking for sustained use.

Advanced hardening is deferred until the workstation path is validated in RunPod.

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

### Xorg Diagnostics

The workstation starts in an Xorg-first sequence:

- `/workspace` is validated first.
- Xorg starts with verbose logs.
- Openbox, Sunshine, and Blender start only after Xorg is stable and `xdpyinfo` works.
- If Xorg fails, downstream processes are not launched.

Expected Xorg diagnostic files:

```text
/workspace/logs/xorg.log
/workspace/logs/xorg.stdout.log
/workspace/logs/xorg.stderr.log
/workspace/logs/xorg-ready.log
/workspace/logs/xorg-diagnostics.log
/workspace/logs/xorg-failure-summary.log
/workspace/logs/workstation-session.log
```
