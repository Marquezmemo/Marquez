# syntax=docker/dockerfile:1

# Browser-accessible Blender desktop for RunPod.
# RunPod injects its own init process, so s6-overlay based images such as
# LinuxServer can crash before the desktop starts. This base is built for RunPod.
FROM runpod/desktop-blender:1.0.0

LABEL org.opencontainers.image.title="Blender Renders"
LABEL org.opencontainers.image.description="Cloud Blender desktop for RunPod browser access."
LABEL org.opencontainers.image.source="https://github.com/Marquezmemo/Marquez"

USER root

ARG BLENDER_VERSION=5.1.2
ARG BLENDER_MAJOR_MINOR=5.1

ENV TZ=America/Mexico_City \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    file \
    thunar \
    wget \
    xfce4-terminal \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    wget --progress=dot:giga \
      "https://download.blender.org/release/Blender${BLENDER_MAJOR_MINOR}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" \
      -O /tmp/blender.tar.xz; \
    rm -rf /opt/blender-*; \
    tar -xf /tmp/blender.tar.xz -C /opt; \
    rm /tmp/blender.tar.xz; \
    ln -sf "/opt/blender-${BLENDER_VERSION}-linux-x64/blender" /usr/local/bin/blender; \
    blender --version

EXPOSE 6901

VOLUME ["/workspace", "/home"]
