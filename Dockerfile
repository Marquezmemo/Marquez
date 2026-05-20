# 1. Base profesional
FROM ghcr.io/ai-dock/pytorch:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# 2. Instalación de dependencias de compilación y limpieza
RUN apt-get update && apt-get install -y \
    ninja-build build-essential g++ git wget curl unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Asegurar versión de CMake y actualizar pip
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "cmake>=3.28"

# 4. Instalación de Blender 5.1.2
RUN wget https://download.blender.org/release/Blender5.1/blender-5.1.2-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-5.1.2-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 5. Compilación de GLOMAP (Ahora con el CMake correcto)
RUN git clone https://github.com/colmap/glomap.git /tmp/glomap && \
    mkdir -p /tmp/glomap/build && cd /tmp/glomap/build && \
    cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=89 && \
    ninja install && \
    rm -rf /tmp/glomap

# 6. Instalación de Nerfstudio
RUN pip install --no-cache-dir nerfstudio && \
    pip cache purge
