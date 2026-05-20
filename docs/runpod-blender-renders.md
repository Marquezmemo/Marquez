# RunPod Template: Blender Renders

Imagen Docker:

```text
marquezmemo/blender-renders:latest
```

Puertos:

```text
6901 HTTP - escritorio Kasm/Blender en navegador
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
- Abre el puerto `6901`.
- No pongas usuario ni password dentro del Dockerfile ni del repositorio. Configuralos como variables del template.
- Esta imagen esta pensada para confirmar rapido que Blender abre en navegador. La imagen de entrenamiento de Gaussian Splatting debe ir separada en `marquezmemo/entorno-gs`.
- Si el login muestra valores por defecto, prueba `kasm_user` como usuario y `password` como password. Luego cambia el password desde las variables del template.

Diagnostico rapido si queda en pantalla blanca:

- Usa una password temporal simple en `VNC_PW`, por ejemplo letras y numeros sin simbolos.
- Entra con `kasm_user` exactamente, con guion bajo.
- Prueba Chrome o Edge en ventana incognito para evitar credenciales guardadas por Safari.
- Si el log dice `wrong password for user kasm_user`, el escritorio no acepto la password todavia; recrea el Pod despues de cambiar `VNC_PW`.
