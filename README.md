# Jetson Nano Waveshare Support Tool

Herramienta interactiva para habilitar y administrar el soporte de la ranura microSD en:

- NVIDIA Jetson Nano Production Module P3448-0002 con eMMC
- Waveshare JETSON-IO-BASE-LITE
- JetPack 4.6.6
- L4T R32.7.6

## Funciones

- Detección automática del BSP `Linux_for_Tegra`
- Detección del DTB compatible
- Respaldo automático
- Modificación idempotente del Device Tree
- Compilación y verificación del DTB
- Detección de modo Recovery/APX
- Flasheo exclusivo de la partición DTB
- Restauración del DTB original
- Menú interactivo
- Ejecución no interactiva mediante parámetros

## Uso rápido

```bash
chmod +x waveshare-tool.sh lib/*.sh tests/*.sh
./waveshare-tool.sh
```

## Menú

```text
=============================================
 Jetson Nano Waveshare Support Tool
=============================================

BSP detectado : /home/usuario/Descargas/jetson/Linux_for_Tegra
L4T           : R32.7.6
DTB           : tegra210-p3448-0002-p3449-0000-b00.dtb
Recovery      : no detectado

1) Detectar BSP
2) Crear respaldo del DTB
3) Compilar DTB modificado
4) Verificar DTB
5) Comprobar modo Recovery
6) Flashear DTB
7) Compilar + flashear
8) Restaurar DTB original
9) Mostrar diagnóstico
0) Salir
```

## Uso no interactivo

```bash
./waveshare-tool.sh detect
./waveshare-tool.sh backup
./waveshare-tool.sh build
./waveshare-tool.sh verify
./waveshare-tool.sh recovery
./waveshare-tool.sh flash
./waveshare-tool.sh all
./waveshare-tool.sh restore
./waveshare-tool.sh diagnose
```

También puedes especificar el BSP:

```bash
./waveshare-tool.sh --bsp ~/Descargas/jetson/Linux_for_Tegra build
```

## Requisitos

```bash
sudo apt update
sudo apt install device-tree-compiler usbutils python3
```

## Modo Recovery

La Jetson debe aparecer como:

```text
0955:7f21 NVIDIA Corp. APX
```

Comprueba con:

```bash
lsusb | grep 0955
```

## Verificación en la Jetson

```bash
dmesg | grep -i mmc
ls /dev/mmc*
lsblk
```

Resultado esperado:

```text
mmc0     eMMC interna
mmc1     ranura microSD
mmcblk1  tarjeta microSD
```

## Hardware validado

- Jetson Nano P3448-0002
- Waveshare JETSON-IO-BASE-LITE
- JetPack 4.6.6
- L4T R32.7.6
- microSD SDXC 128 GB
- Modo SDR104

## Advertencia

Este proyecto fue validado para el hardware y versiones indicados. El flasheo modifica únicamente la partición `DTB`, pero debes evitar cualquier desconexión de alimentación o USB durante el proceso.
