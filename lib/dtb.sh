#!/usr/bin/env bash

build_dtb() {
    require_bsp

    info "Descompilando DTB..."
    dtc -I dtb -O dts \
        -o "$WORK_DTS" \
        "$DTB_PATH" \
        2>"$DTB_DIR/dtc-decompile-warnings.log" || \
        die "Falló la descompilación."

    info "Aplicando cambios para SDMMC3..."
    python3 - "$WORK_DTS" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()

pattern = re.compile(
    r'(?P<header>\bsdhci@700b0400\s*\{)(?P<body>.*?)(?P<footer>\n\s*\};)',
    re.S,
)
match = pattern.search(text)
if not match:
    raise SystemExit("No se encontró el nodo sdhci@700b0400.")

body = match.group("body")

def remove_property(body: str, name: str) -> str:
    patterns = [
        rf'(?m)^\s*{re.escape(name)}\s*=\s*<[^;]*>;\s*\n?',
        rf'(?m)^\s*{re.escape(name)}\s*=\s*"[^"]*";\s*\n?',
        rf'(?m)^\s*{re.escape(name)}\s*;\s*\n?',
    ]
    for p in patterns:
        body = re.sub(p, "", body)
    return body

properties = [
    "status",
    "cd-gpios",
    "sd-uhs-sdr104",
    "sd-uhs-sdr50",
    "sd-uhs-sdr25",
    "sd-uhs-sdr12",
    "no-mmc",
    "uhs-mask",
]

for prop in properties:
    body = remove_property(body, prop)

indent_match = re.search(r'\n([ \t]+)\S', body)
indent = indent_match.group(1) if indent_match else "\t\t"

insert = (
    f'\n{indent}status = "okay";\n'
    f'{indent}cd-gpios = <0x5b 0xc2 0x00>;\n'
    f'{indent}sd-uhs-sdr104;\n'
    f'{indent}sd-uhs-sdr50;\n'
    f'{indent}sd-uhs-sdr25;\n'
    f'{indent}sd-uhs-sdr12;\n'
    f'{indent}no-mmc;\n'
    f'{indent}uhs-mask = <0x0c>;\n'
)

bus_width = re.search(r'(?m)^(\s*bus-width\s*=\s*<[^;]*>;\s*)$', body)
if bus_width:
    pos = bus_width.end()
    body = body[:pos] + insert + body[pos:]
else:
    body = insert + body

new_node = match.group("header") + body + match.group("footer")
new_text = text[:match.start()] + new_node + text[match.end():]
path.write_text(new_text)
PY

    cp -a "$WORK_DTS" "$DTS_PATH"

    info "Compilando DTB..."
    dtc -I dts -O dtb \
        -o "$DTB_PATH" \
        "$DTS_PATH" \
        2>"$DTB_DIR/dtc-compile-warnings.log" || \
        die "Falló la compilación. Revisa dtc-compile-warnings.log."

    cp -a "$DTB_PATH" "$OUTPUT_COPY"
    ok "DTB compilado: $DTB_PATH"
    ok "Copia funcional: $OUTPUT_COPY"
}
