# Hardware compatible

## Plataforma validada

- NVIDIA Jetson Nano Production Module
- Modelo: P3448-0002
- Almacenamiento interno: 16 GB eMMC
- Carrier board: Waveshare JETSON-IO-BASE-LITE
- JetPack: 4.6.6
- L4T: R32.7.6
- Kernel: 4.9

## Problema

El BSP estándar de NVIDIA deja deshabilitado el controlador SDMMC3 en el DTB usado por el módulo eMMC.

Nodo afectado:

```dts
sdhci@700b0400
```

## Cambios aplicados

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

## Resultado validado

```text
mmc1: SDHCI controller on sdhci-tegra.2
mmc1: new ultra high speed SDR104 SDXC card
mmcblk1: SD128 119 GiB
```
