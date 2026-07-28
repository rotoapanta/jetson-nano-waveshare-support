# Modo Recovery

## Identificación correcta

La Jetson debe aparecer en el PC Ubuntu como:

```text
0955:7f21 NVIDIA Corp. APX
```

Comprueba con:

```bash
lsusb | grep 0955
```

## Procedimiento

1. Apaga completamente la Jetson.
2. Desconecta su alimentación.
3. Conecta temporalmente `FC REC` con `GND`.
4. Conecta el cable micro-USB al PC.
5. Conecta la alimentación de la Jetson.
6. Espera unos segundos.
7. Retira el puente `FC REC-GND`.
8. Ejecuta `lsusb | grep 0955`.

## No confundir

Esto indica arranque normal, no Recovery:

```text
0955:7020 NVIDIA Corp. L4T running on Tegra
```

No ejecutes el flasheo mientras aparezca `0955:7020`.
