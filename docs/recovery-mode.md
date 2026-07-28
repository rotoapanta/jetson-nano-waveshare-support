# Modo Recovery/APX

## Procedimiento

1. Apaga la Jetson.
2. Desconecta la alimentación.
3. Une temporalmente `FC REC` con `GND`.
4. Conecta el micro-USB al PC.
5. Alimenta la Jetson.
6. Espera unos segundos.
7. Retira el puente.
8. Ejecuta:

```bash
lsusb | grep 0955
```

Salida correcta:

```text
0955:7f21 NVIDIA Corp. APX
```

Salida de arranque normal:

```text
0955:7020 NVIDIA Corp. L4T running on Tegra
```
