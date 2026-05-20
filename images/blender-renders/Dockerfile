# syntax=docker/dockerfile:1

# Browser-accessible Blender desktop.
# LinuxServer already ships Blender with a web desktop, so this image stays tiny
# and starts much faster than rebuilding a full desktop stack from scratch.
FROM lscr.io/linuxserver/blender:latest

LABEL org.opencontainers.image.title="Blender Renders"
LABEL org.opencontainers.image.description="Cloud Blender desktop for RunPod browser access."
LABEL org.opencontainers.image.source="https://github.com/Marquezmemo/Marquez"

ENV TZ=America/Mexico_City \
    PUID=1000 \
    PGID=1000 \
    TITLE="Blender Renders" \
    SELKIES_UI_TITLE="Blender Renders" \
    SELKIES_FRAMERATE="30-60" \
    PIXELFLUX_WAYLAND=false \
    AUTO_GPU=false \
    SELKIES_USE_CPU=true \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

EXPOSE 3000 3001

VOLUME ["/config"]
