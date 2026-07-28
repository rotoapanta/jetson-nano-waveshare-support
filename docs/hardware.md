# Hardware compatible

## Plataforma validada

- NVIDIA Jetson Nano Production Module P3448-0002
- 16 GB eMMC
- Waveshare JETSON-IO-BASE-LITE
- JetPack 4.6.6
- L4T R32.7.6

## Nodo modificado

```dts
sdhci@700b0400
```

## Resultado esperado

```text
mmc1: SDHCI controller on sdhci-tegra.2
mmc1: new ultra high speed SDR104 SDXC card
mmcblk1: SD128 119 GiB
```
