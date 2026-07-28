# Jetson Nano Waveshare Support

Soporte automatizado para habilitar la ranura microSD en:

- NVIDIA Jetson Nano Production Module P3448-0002 (16 GB eMMC)
- Waveshare JETSON-IO-BASE-LITE
- JetPack 4.6.6
- L4T R32.7.6

## Qué incluye

- Parche del Device Tree.
- Script para descompilar, modificar, compilar y verificar el DTB.
- Script para detectar la Jetson en modo Recovery.
- Flasheo exclusivo de la partición DTB.
- Restauración del DTB original.
- Documentación de hardware, recovery y solución de problemas.

## Estructura

```text
jetson-nano-waveshare-support/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .gitignore
├── scripts/
│   ├── build_dtb.sh
│   ├── flash_dtb.sh
│   ├── enable_microsd.sh
│   └── restore_dtb.sh
├── patches/
│   └── enable-microsd.patch
└── docs/
    ├── hardware.md
    ├── recovery-mode.md
    ├── troubleshooting.md
    └── images/
        └── .gitkeep
```

## Uso rápido

```bash
chmod +x scripts/*.sh
./scripts/enable_microsd.sh ~/Descargas/jetson/Linux_for_Tegra
```

El proceso realiza:

1. Respaldo del DTB original.
2. Descompilación del DTB.
3. Habilitación de `sdhci@700b0400`.
4. Compilación y verificación.
5. Espera a que la Jetson entre en modo Recovery.
6. Flasheo únicamente de la partición `DTB`.

## Uso por etapas

### Compilar y verificar

```bash
./scripts/build_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

### Flashear

La Jetson debe aparecer así:

```bash
lsusb | grep 0955
```

```text
0955:7f21 NVIDIA Corp. APX
```

Luego:

```bash
./scripts/flash_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
```

### Restaurar DTB original

```bash
./scripts/restore_dtb.sh ~/Descargas/jetson/Linux_for_Tegra
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

## Configuración validada

- Módulo: P3448-0002
- Carrier: Waveshare JETSON-IO-BASE-LITE
- JetPack: 4.6.6
- L4T: R32.7.6
- Tarjeta probada: SDXC 128 GB
- Modo detectado: SDR104

## Advertencia

Este proyecto fue validado específicamente para el hardware y versiones indicadas. No desconectes alimentación ni USB durante el flasheo.
