# 1. Base profesional para entornos visuales
FROM ghcr.io/ai-dock/pytorch:latest-cuda-12.1.1

USER root
ENV DEBIAN_FRONTEND=noninteractive

# 2. Instalación de herramientas, limpieza de caché de paquetes apt
RUN apt-get update && apt-get install -y \
    cmake ninja-build build-essential g++ git wget curl unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Instalación de Blender 5.1.2 y limpieza de temporales
RUN wget https://download.blender.org/release/Blender5.1/blender-5.1.2-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-5.1.2-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 4. Compilación de GLOMAP y limpieza de fuentes y build
RUN git clone https://github.com/colmap/glomap.git /tmp/glomap && \
    mkdir -p /tmp/glomap/build && cd /tmp/glomap/build && \
    cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=89 && \
    ninja install && \
    rm -rf /tmp/glomap

# 5. Instalación de Nerfstudio con purga de caché de pip
RUN pip install --no-cache-dir nerfstudio && \
    pip cache purge
