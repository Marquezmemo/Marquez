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
    libvulkan1 \
    mesa-vulkan-drivers \
    thunar \
    vulkan-tools \
    wget \
    xfce4-terminal \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

COPY blender-wrapper.sh /usr/local/bin/blender
COPY Blender.desktop Terminal.desktop Workspace.desktop /home/kasm-user/Desktop/

RUN set -eux; \
    wget --progress=dot:giga \
      "https://download.blender.org/release/Blender${BLENDER_MAJOR_MINOR}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" \
      -O /tmp/blender.tar.xz; \
    rm -rf /opt/blender-*; \
    tar -xf /tmp/blender.tar.xz -C /opt; \
    rm /tmp/blender.tar.xz; \
    chmod +x /usr/local/bin/blender; \
    ln -sf /usr/local/bin/blender /usr/bin/blender; \
    chmod +x /home/kasm-user/Desktop/*.desktop; \
    chown -R kasm-user:kasm-user /home/kasm-user/Desktop; \
    test -x "/opt/blender-${BLENDER_VERSION}-linux-x64/blender"

USER kasm-user

EXPOSE 6901

VOLUME ["/workspace", "/home"]
