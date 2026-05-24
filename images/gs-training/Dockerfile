# syntax=docker/dockerfile:1

FROM ghcr.io/nerfstudio-project/nerfstudio:latest

LABEL org.opencontainers.image.title="GS Training"
LABEL org.opencontainers.image.description="RunPod Gaussian Splatting training node with Nerfstudio, Jupyter, and persistent stack manifests."
LABEL org.opencontainers.image.source="https://github.com/Marquezmemo/Marquez"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Mexico_City \
    PIPELINE_PHASE=DISCOVERY \
    IMAGE_NAME=gs-training \
    IMAGE_TAG=discovery \
    GS_STACK_VERSION=DISCOVERY-1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all \
    WORKSPACE_DIR=/workspace \
    JUPYTER_PORT=8888

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    supervisor \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir jupyterlab ipywidgets

COPY scripts /opt/pipeline/scripts
COPY configs /opt/pipeline/configs

RUN chmod +x /opt/pipeline/scripts/bootstrap/*.sh \
    /opt/pipeline/scripts/runtime/*.sh \
    /opt/pipeline/scripts/validation/*.sh

EXPOSE 8888 7007

VOLUME ["/workspace"]

ENTRYPOINT ["/opt/pipeline/scripts/runtime/entrypoint-gs-training.sh"]
