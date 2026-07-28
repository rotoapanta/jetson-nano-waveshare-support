#!/usr/bin/env bash
set -Eeuo pipefail

BSP_ROOT="${1:-$HOME/Descargas/jetson/Linux_for_Tegra}"
DTB="$BSP_ROOT/kernel/dtb/tegra210-p3448-0002-p3449-0000-b00.dtb"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[[ -f "$BSP_ROOT/flash.sh" ]] || die "No se encontró flash.sh."
[[ -f "$DTB" ]] || die "No se encontró el DTB."
command -v lsusb >/dev/null 2>&1 || die "No se encontró lsusb."

USB_LINE="$(lsusb | grep -i '0955:7f21' || true)"

if [[ -z "$USB_LINE" ]]; then
    echo "La Jetson no está en Recovery/APX."
    echo "Debe aparecer: 0955:7f21 NVIDIA Corp. APX"
    lsusb | grep -i '0955' || true
    exit 2
fi

echo "$USB_LINE"
echo "Se actualizará únicamente la partición DTB."

cd "$BSP_ROOT"
sudo ./flash.sh -r -k DTB jetson-nano-emmc mmcblk0p1
