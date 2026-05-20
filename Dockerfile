# Usamos la base oficial de desarrollo de NVIDIA con CUDA 12.1 compatible globalmente
FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-devel

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

# 3. Descargar e instalar Blender 5.1.2 oficial para paridad total con tu Mac
RUN wget https://download.blender.org/release/Blender5.1/blender-5.1.2-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-5.1.2-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 4. Actualizar pip, instalar PyTorch oficial para CUDA 12.1 y luego Nerfstudio
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torchao --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install --no-cache-dir nerfstudio
    pip3 install --no-cache-dir jupyterlab
    pip3 install --no-cache-dir supervisor

# 5. Configurar el script de arranque maestro para encender TODO al mismo tiempo
RUN echo '[supervisord]\nnodaemon=true\n\n[program:jupyter]\ncommand=jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token="" --NotebookApp.password=""\nautorestart=true\n\n[program:vnc]\ncommand=vncserver :1 -geometry 1920x1080 -depth 24 -rfbport 5901 -localhost no -SecurityTypes None\nautorestart=true\n\n[program:novnc]\ncommand=websockify --web /usr/share/novnc/ 6080 localhost:5901\nautorestart=true' > /etc/supervisord.conf

# Lanzar el gestor de servicios globales
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

# Apuntar por defecto al espacio de trabajo persistente y estándar de RunPod
WORKDIR /workspace
