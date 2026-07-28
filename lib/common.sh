#!/usr/bin/env bash

DTB_NAME="tegra210-p3448-0002-p3449-0000-b00.dtb"
DTS_NAME="tegra210-p3448-0002-p3449-0000-b00.dts"
SUPPORTED_L4T="R32.7.6"

BSP_ROOT="${BSP_ROOT:-}"
DTB_DIR=""
DTB_PATH=""
DTS_PATH=""
BACKUP_PATH=""
WORK_DTS=""
OUTPUT_COPY=""

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[AVISO]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }
die() { error "$*"; exit 1; }

print_header() {
    cat <<'EOF'
=============================================
 Jetson Nano Waveshare Support Tool
=============================================
EOF
}

set_bsp_root() {
    BSP_ROOT="$(readlink -f "$1")"
    DTB_DIR="$BSP_ROOT/kernel/dtb"
    DTB_PATH="$DTB_DIR/$DTB_NAME"
    DTS_PATH="$DTB_DIR/$DTS_NAME"
    BACKUP_PATH="$DTB_DIR/${DTB_NAME}.pre-waveshare-backup"
    WORK_DTS="$DTB_DIR/${DTS_NAME}.working"
    OUTPUT_COPY="$DTB_DIR/tegra210-p3448-0002-p3449-0000-b00-Waveshare-SD.dtb"
}

require_bsp() {
    [[ -n "$BSP_ROOT" ]] || die "No se detectó Linux_for_Tegra."
    [[ -d "$BSP_ROOT" ]] || die "No existe BSP: $BSP_ROOT"
    [[ -f "$BSP_ROOT/flash.sh" ]] || die "No se encontró flash.sh en: $BSP_ROOT"
    [[ -f "$DTB_PATH" ]] || die "No se encontró el DTB esperado: $DTB_PATH"
}

check_dependencies() {
    local missing=()
    for cmd in dtc python3 lsusb find grep sed awk readlink; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done

    if (( ${#missing[@]} > 0 )); then
        error "Faltan dependencias: ${missing[*]}"
        echo "Instala con:"
        echo "  sudo apt update"
        echo "  sudo apt install device-tree-compiler usbutils python3 findutils"
        exit 1
    fi
}
