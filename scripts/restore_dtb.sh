#!/usr/bin/env bash
set -Eeuo pipefail

DTB_NAME="tegra210-p3448-0002-p3449-0000-b00.dtb"
BSP_ROOT="${1:-$HOME/Descargas/jetson/Linux_for_Tegra}"
DTB_DIR="$BSP_ROOT/kernel/dtb"
DTB="$DTB_DIR/$DTB_NAME"
BACKUP="$DTB_DIR/${DTB_NAME}.pre-waveshare-backup"

[[ -f "$BACKUP" ]] || {
    echo "ERROR: No existe $BACKUP" >&2
    exit 1
}

cp -a "$DTB" "$DTB_DIR/${DTB_NAME}.waveshare-current"
cp -a "$BACKUP" "$DTB"

echo "DTB original restaurado."
echo "Pon la Jetson en Recovery y ejecuta flash_dtb.sh."
