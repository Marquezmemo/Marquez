# RunPod Template: Blender Renders

Imagen Docker:

```text
marquezmemo/blender-renders:latest
```

Puertos:

```text
3000 HTTP  - escritorio Blender en navegador
6901 HTTP  - escritorio Kasm/noVNC alterno
```

Variables recomendadas en RunPod:

```text
TZ=America/Mexico_City
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=all
VNC_PW=<tu-password>
```

Login del escritorio:

```text
Usuario: kasm_user
Password: el valor que pusiste en VNC_PW
```

Volumen persistente:

```text
/workspace
/home
```

Notas:

- Usa GPU NVIDIA en RunPod, idealmente RTX 3090 o RTX 4090.
- Abre primero el puerto `3000`. Si queda en blanco, prueba el puerto `6901`.
- No pongas usuario ni password dentro del Dockerfile ni del repositorio. Configuralos como variables del template.
- Esta imagen esta pensada para confirmar rapido que Blender abre en navegador. La imagen de entrenamiento de Gaussian Splatting debe ir separada en `marquezmemo/entorno-gs`.
- Si el login muestra valores por defecto, prueba `kasm_user` como usuario y `password` como password. Luego cambia el password desde las variables del template.
