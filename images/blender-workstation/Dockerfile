# syntax=docker/dockerfile:1

FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu22.04

LABEL org.opencontainers.image.title="Blender Workstation"
LABEL org.opencontainers.image.description="RunPod GPU workstation for Blender, Sunshine/Moonlight, and asset workflows."
LABEL org.opencontainers.image.source="https://github.com/Marquezmemo/Marquez"

ARG BLENDER_VERSION=5.1.2
ARG BLENDER_MAJOR_MINOR=5.1
ARG SUNSHINE_DEB_URL=https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-22.04-amd64.deb

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Mexico_City \
    PIPELINE_PHASE=DISCOVERY \
    IMAGE_NAME=blender-workstation \
    IMAGE_TAG=discovery \
    BLENDER_VERSION=${BLENDER_VERSION} \
    BLENDER_STACK_VERSION=DISCOVERY-1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all \
    XORG_DRIVER_MODE=dummy \
    DISPLAY=:0 \
    WORKSPACE_DIR=/workspace

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dbus-x11 \
    ffmpeg \
    file \
    jq \
    kmod \
    libasound2 \
    libdbus-1-3 \
    libegl1 \
    libgl1 \
    libgl1-mesa-dri \
    libglib2.0-0 \
    libglu1-mesa \
    libsm6 \
    libvulkan1 \
    libx11-6 \
    libxext6 \
    libxi6 \
    libxkbcommon0 \
    libxrender1 \
    libxxf86vm1 \
    mesa-utils \
    mesa-vulkan-drivers \
    openbox \
    procps \
    pulseaudio \
    rclone \
    iproute2 \
    supervisor \
    vulkan-tools \
    wget \
    x11-utils \
    x11-xserver-utils \
    xauth \
    xinit \
    xserver-xorg-core \
    xserver-xorg-video-dummy \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    wget --progress=dot:giga \
      "https://download.blender.org/release/Blender${BLENDER_MAJOR_MINOR}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" \
      -O /tmp/blender.tar.xz; \
    tar -xf /tmp/blender.tar.xz -C /opt; \
    rm /tmp/blender.tar.xz; \
    ln -sf "/opt/blender-${BLENDER_VERSION}-linux-x64/blender" /usr/local/bin/blender; \
    test -x "/opt/blender-${BLENDER_VERSION}-linux-x64/blender"

RUN set -eux; \
    wget --progress=dot:giga "${SUNSHINE_DEB_URL}" -O /tmp/sunshine.deb; \
    apt-get update; \
    apt-get install -y --no-install-recommends /tmp/sunshine.deb; \
    rm /tmp/sunshine.deb; \
    rm -rf /var/lib/apt/lists/*

COPY scripts /opt/pipeline/scripts
COPY configs /opt/pipeline/configs

RUN chmod +x /opt/pipeline/scripts/bootstrap/*.sh \
    /opt/pipeline/scripts/runtime/*.sh \
    /opt/pipeline/scripts/validation/*.sh

EXPOSE 47984/tcp 47989/tcp 47990/tcp 48010/tcp
EXPOSE 47998/udp 47999/udp 48000/udp 48002/udp 48010/udp

VOLUME ["/workspace"]

ENTRYPOINT ["/opt/pipeline/scripts/runtime/entrypoint-blender-workstation.sh"]
