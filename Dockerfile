# Usamos la base oficial de desarrollo de NVIDIA con CUDA 12.1 compatible globalmente
FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-devel

# Configurar entorno no interactivo para evitar bloqueos en la instalación
USER root
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar herramientas, dependencias gráficas, Escritorio y VirtualGL
RUN apt-get update && apt-get install -y \
    cmake ninja-build build-essential g++ git wget curl unzip \
    libxrender1 libxi6 libgl1-mesa-glx libglib2.0-0 libsm6 libice6 libxext6 libxkbcommon0 \
    xfce4 xfce4-goodies dbus-x11 x11-xserver-utils tigervnc-standalone-server tigervnc-common novnc websockify \
    && wget https://sourceforge.net/projects/virtualgl/files/3.1.1/virtualgl_3.1.1_amd64.deb -O /tmp/vgl.deb \
    && dpkg -i /tmp/vgl.deb || apt-get -f install -y \
    && rm /tmp/vgl.deb \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar COLMAP de manera directa vía paquetes del sistema
RUN apt-get update && apt-get install -y colmap && rm -rf /var/lib/apt/lists/*

# 3. Descargar e instalar Blender 5.1.2 oficial para paridad total con tu Mac
RUN wget https://download.blender.org/release/Blender5.1/blender-5.1.2-linux-x64.tar.xz -O /tmp/blender.tar.xz && \
    tar -xf /tmp/blender.tar.xz -C /opt/ && \
    ln -s /opt/blender-5.1.2-linux-x64/blender /usr/local/bin/blender && \
    rm /tmp/blender.tar.xz

# 4. Instalar Nerfstudio, JupyterLab y supervisor (Usando el Python del entorno base de PyTorch)
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torchao --index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install --no-cache-dir nerfstudio jupyterlab supervisor

WORKDIR /workspace

# 5. Configurar VNC xstartup y script maestro de supervisord
RUN mkdir -p /root/.vnc && echo '#!/bin/bash\nstartxfce4 &' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

RUN echo '[supervisord]\nnodaemon=true\n\n[program:jupyter]\ncommand=jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token="" --ServerApp.password=""\nautorestart=true\n\n[program:vnc]\ncommand=tigervncserver :1 -geometry 1920x1080 -depth 24 -localhost no -SecurityTypes None\nautorestart=true\n\n[program:novnc]\ncommand=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080\nautorestart=true' > /etc/supervisord.conf

# Lanzar el gestor de servicios global
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
