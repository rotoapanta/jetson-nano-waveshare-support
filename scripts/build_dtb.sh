#!/usr/bin/env bash
set -Eeuo pipefail

DTB_NAME="tegra210-p3448-0002-p3449-0000-b00.dtb"
DTS_NAME="tegra210-p3448-0002-p3449-0000-b00.dts"

BSP_ROOT="${1:-$HOME/Descargas/jetson/Linux_for_Tegra}"
DTB_DIR="$BSP_ROOT/kernel/dtb"
DTB="$DTB_DIR/$DTB_NAME"
DTS="$DTB_DIR/$DTS_NAME"
BACKUP="$DTB_DIR/${DTB_NAME}.pre-waveshare-backup"
WORK_DTS="$DTB_DIR/${DTS_NAME}.working"
OUTPUT_COPY="$DTB_DIR/tegra210-p3448-0002-p3449-0000-b00-Waveshare-SD.dtb"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

command -v dtc >/dev/null 2>&1 || die "Instala dtc con: sudo apt install device-tree-compiler"
command -v python3 >/dev/null 2>&1 || die "No se encontró python3."

[[ -d "$BSP_ROOT" ]] || die "No existe: $BSP_ROOT"
[[ -f "$BSP_ROOT/flash.sh" ]] || die "No se encontró flash.sh."
[[ -f "$DTB" ]] || die "No se encontró: $DTB"

if [[ ! -f "$BACKUP" ]]; then
    cp -a "$DTB" "$BACKUP"
    echo "Respaldo creado: $BACKUP"
else
    echo "Respaldo existente: $BACKUP"
fi

dtc -I dtb -O dts -o "$WORK_DTS" "$DTB" 2>"$DTB_DIR/dtc-decompile-warnings.log"

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
    raise SystemExit("No se encontró sdhci@700b0400.")

body = match.group("body")

def remove_prop(body, name):
    body = re.sub(rf'(?m)^\s*{re.escape(name)}\s*=\s*<[^;]*>;\s*\n?', '', body)
    body = re.sub(rf'(?m)^\s*{re.escape(name)}\s*=\s*"[^"]*";\s*\n?', '', body)
    body = re.sub(rf'(?m)^\s*{re.escape(name)}\s*;\s*\n?', '', body)
    return body

for prop in (
    "status", "cd-gpios", "sd-uhs-sdr104", "sd-uhs-sdr50",
    "sd-uhs-sdr25", "sd-uhs-sdr12", "no-mmc", "uhs-mask"
):
    body = remove_prop(body, prop)

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
path.write_text(text[:match.start()] + new_node + text[match.end():])
PY

cp -a "$WORK_DTS" "$DTS"

dtc -I dts -O dtb -o "$DTB" "$DTS" 2>"$DTB_DIR/dtc-compile-warnings.log"

VERIFY="$(
    dtc -I dtb -O dts "$DTB" 2>/dev/null |
    sed -n '/sdhci@700b0400 {/,/};/p' |
    grep -E 'status|cd-gpios|sd-uhs|no-mmc|uhs-mask' || true
)"

echo "$VERIFY"

for expected in \
    'status = "okay";' \
    'cd-gpios = <0x5b 0xc2 0x00>;' \
    'sd-uhs-sdr104;' \
    'sd-uhs-sdr50;' \
    'sd-uhs-sdr25;' \
    'sd-uhs-sdr12;' \
    'no-mmc;' \
    'uhs-mask = <0x0c>;'
do
    grep -Fq "$expected" <<<"$VERIFY" || die "Falta: $expected"
done

cp -a "$DTB" "$OUTPUT_COPY"

echo "DTB compilado y verificado correctamente."
echo "Archivo: $DTB"
