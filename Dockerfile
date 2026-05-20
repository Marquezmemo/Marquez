# 1. Base profesional para entornos visuales en RunPod (Ya trae X11, VNC, noVNC, XFCE y Drivers NVIDIA)
FROM ghcr.io/ai-dock/pytorch:2.2.1-cuda-12.1.1

# 2. Instalación de Blender 5.1.2
RUN wget https://download.blender.org/release/Blender5.1/blender-5.1.2-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-5.1.2-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 3. Instalación de GLOMAP y dependencias de compilación
RUN apt-get update && apt-get install -y cmake ninja-build && \
    git clone https://github.com/colmap/glomap.git /tmp/glomap && \
    cd /tmp/glomap && mkdir build && cd build && \
    cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=89 && \
    ninja install && rm -rf /tmp/glomap && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Instalación de utilidades visuales finales
RUN pip install --no-cache-dir nerfstudio
