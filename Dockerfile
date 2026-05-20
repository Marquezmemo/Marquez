# Usamos la base oficial de PyTorch/CUDA optimizada nativamente para RunPod
FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-developer-ubuntu22.04

# Configurar entorno no interactivo para evitar bloqueos en la instalación
USER root
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar dependencias esenciales del sistema, compiladores avanzados y utilerías gráficas
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    build-essential \
    g++ \
    git \
    wget \
    curl \
    unzip \
    # Librerías X11/Mesa requeridas para que herramientas visuales (como Blender) corran headless en el servidor
    libxrender1 \
    libxi6 \
    libxkf0 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libice6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar COLMAP de manera directa vía paquetes del sistema para evitar horas de compilación
RUN apt-get update && apt-get install -y colmap && rm -rf /var/lib/apt/lists/*

# 3. Descargar e instalar Blender de manera automatizada y crear el enlace simbólico global
RUN wget https://download.blender.org/release/Blender4.2/blender-4.2.0-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-4.2.0-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 4. Actualizar pip e instalar Nerfstudio junto con dependencias optimizadas para CUDA 12.1
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torchao --index-url https://download.pytorch.org/whl/cu121 && \
    pip install --no-cache-dir nerfstudio

# Apuntar por defecto al espacio de trabajo persistente y estándar de RunPod
WORKDIR /workspace
