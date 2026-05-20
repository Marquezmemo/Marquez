# RunPod Template: Blender Renders

Imagen Docker:

```text
marquezmemo/blender-renders:latest
```

Puertos:

```text
3000 HTTP  - escritorio Blender en navegador
3001 HTTPS - escritorio Blender en navegador
```

Variables recomendadas en RunPod:

```text
PUID=1000
PGID=1000
TZ=America/Mexico_City
TITLE=Blender Renders
SELKIES_UI_TITLE=Blender Renders
AUTO_GPU=true
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=all
PASSWORD=<tu-password>
```

Volumen persistente:

```text
/config
```

Notas:

- Usa GPU NVIDIA en RunPod, idealmente RTX 3090 o RTX 4090.
- Abre el escritorio desde el proxy web de RunPod usando el puerto `3000`.
- No pongas el password dentro del Dockerfile ni del repositorio. Configuralo como variable del template.
- Esta imagen esta pensada para confirmar rapido que Blender abre en navegador. La imagen de entrenamiento de Gaussian Splatting debe ir separada en `marquezmemo/entorno-gs`.
- Importante: esta base es ideal para validar escritorio remoto. Si Cycles no detecta CUDA/OptiX dentro de RunPod, la siguiente version debe usar una base NVIDIA/OpenGL hecha especificamente para render GPU.
