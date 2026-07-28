# Solución de problemas

## No se detecta el BSP

Ejecuta:

```bash
./waveshare-tool.sh --bsp ~/Descargas/jetson/Linux_for_Tegra diagnose
```

## No aparece APX

Comprueba el cable USB y repite el procedimiento de Recovery.

## Aparece 0955:7020

La Jetson arrancó Linux normalmente. Debes volver a entrar en Recovery.

## No aparece mmc1

En la Jetson ejecuta:

```bash
dmesg | grep -i mmc
ls /dev/mmc*
lsblk
```

## Restaurar

```bash
./waveshare-tool.sh restore
./waveshare-tool.sh flash
```
