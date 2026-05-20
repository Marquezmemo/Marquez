# syntax=docker/dockerfile:1

# Browser-accessible Blender desktop for RunPod.
# RunPod injects its own init process, so s6-overlay based images such as
# LinuxServer can crash before the desktop starts. This base is built for RunPod.
FROM runpod/desktop-blender:1.0.0

LABEL org.opencontainers.image.title="Blender Renders"
LABEL org.opencontainers.image.description="Cloud Blender desktop for RunPod browser access."
LABEL org.opencontainers.image.source="https://github.com/Marquezmemo/Marquez"

ENV TZ=America/Mexico_City \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

EXPOSE 6901

VOLUME ["/workspace", "/home"]
