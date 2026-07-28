# Jetson Nano Waveshare microSD Enable

Automatiza la habilitación de la ranura microSD en:

- NVIDIA Jetson Nano Production Module P3448-0002 (16 GB eMMC)
- Waveshare JETSON-IO-BASE-LITE
- JetPack 4.6.6 / L4T R32.7.6
- DTB: `tegra210-p3448-0002-p3449-0000-b00.dtb`

## Cambios aplicados

En el nodo `sdhci@700b0400`:

```dts
status = "okay";
cd-gpios = <0x5b 0xc2 0x00>;
sd-uhs-sdr104;
sd-uhs-sdr50;
sd-uhs-sdr25;
sd-uhs-sdr12;
no-mmc;
uhs-mask = <0x0c>;
```

## Uso recomendado

### 1. Copiar este repositorio al PC Ubuntu

Descomprime el archivo y entra en la carpeta:

```bash
cd jetson-nano-waveshare-microsd
```

### 2. Aplicar cambios y compilar automáticamente

```bash
chmod +x scripts/*.sh
./scripts/build_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

El script:

- comprueba la estructura del BSP;
- respalda el DTB original;
- descompila el DTB;
- modifica el nodo SDMMC3 de forma idempotente;
- recompila el DTB;
- verifica las propiedades finales;
- conserva una copia funcional con sufijo `-Waveshare-SD`.

### 3. Poner la Jetson en modo Recovery

Debe aparecer:

```bash
lsusb | grep 0955
```

Salida esperada:

```text
0955:7f21 NVIDIA Corp. APX
```

### 4. Flashear únicamente el DTB

```bash
./scripts/flash_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

Este comando no reinstala Ubuntu ni formatea la eMMC. Actualiza únicamente la partición `DTB`.

### 5. Verificar en la Jetson

```bash
dmesg | grep -i mmc
ls /dev/mmc*
lsblk
```

Resultado esperado:

```text
mmc0: eMMC interna
mmc1: ranura microSD
mmcblk1: tarjeta microSD
```

## Ejecución completa

También puedes usar:

```bash
./scripts/enable_microsd.sh ~/Descargas/jetson/Linux_for_Tegra
```

Primero compila y verifica. Luego espera a que pongas la Jetson en modo Recovery antes de flashear.

## Restaurar el DTB original

```bash
./scripts/restore_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

Después coloca la Jetson en Recovery y vuelve a ejecutar:

```bash
./scripts/flash_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

## Archivo `.patch`

Se incluye `patches/enable-microsd.patch` como referencia documental. El método recomendado es `build_dtb.sh`, porque funciona directamente sobre el DTB del BSP y no depende de que el archivo DTS tenga exactamente las mismas líneas o el mismo formato.

## Advertencias

- Usa este procedimiento únicamente para el hardware y versión indicados.
- No desconectes alimentación ni USB durante el flasheo.
- Confirma siempre que `lsusb` muestre `0955:7f21 NVIDIA Corp. APX`.
- Guarda una copia del BSP original.
