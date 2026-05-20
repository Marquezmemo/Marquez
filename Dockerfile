# Usamos la base oficial de desarrollo de NVIDIA con CUDA 12.1 compatible globalmente
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Configurar entorno no interactivo para evitar bloqueos en la instalación
USER root
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar Python, instaladores, compiladores avanzados y utilerías gráficas
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    cmake \
    ninja-build \
    build-essential \
    g++ \
    git \
    wget \
    curl \
    unzip \
    # Librerías X11/Mesa requeridas para herramientas visuales (Corregido paquete de teclado)
    libxrender1 \
    libxi6 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libice6 \
    libxext6 \
    libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar COLMAP de manera directa vía paquetes del sistema
RUN apt-get update && apt-get install -y colmap && rm -rf /var/lib/apt/lists/*

# 3. Descargar e instalar Blender de manera automatizada y crear el enlace simbólico global
RUN wget https://download.blender.org/release/Blender4.2/blender-4.2.0-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-4.2.0-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 4. Actualizar pip, instalar PyTorch oficial para CUDA 12.1 y luego Nerfstudio
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install --no-cache-dir torchao --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install --no-cache-dir nerfstudio

# Apuntar por defecto al espacio de trabajo persistente y estándar de RunPod
WORKDIR /workspace
