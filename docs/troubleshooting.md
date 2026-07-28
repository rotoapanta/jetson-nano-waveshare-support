# Solución de problemas

## No aparece `0955:7f21`

- Verifica el cable micro-USB.
- Usa un cable con datos, no solo carga.
- Comprueba el puente `FC REC-GND`.
- Apaga completamente la Jetson antes de repetir.
- Prueba otro puerto USB del PC.

## Aparece `0955:7020`

La Jetson inició Linux normalmente. Repite el procedimiento de Recovery.

## `dtc` no está instalado

```bash
sudo apt update
sudo apt install device-tree-compiler
```

## El script no encuentra `flash.sh`

Indica la ruta correcta:

```bash
./scripts/enable_microsd.sh ~/Descargas/jetson/Linux_for_Tegra
```

## La microSD no aparece después del flasheo

Ejecuta en la Jetson:

```bash
dmesg | grep -i mmc
ls /dev/mmc*
lsblk
```

Debes ver `mmc1` y `mmcblk1`.

## Restaurar

```bash
./scripts/restore_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

Después coloca la Jetson en Recovery y ejecuta:

```bash
./scripts/flash_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```
