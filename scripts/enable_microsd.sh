#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BSP_ROOT="${1:-$HOME/Descargas/jetson/Linux_for_Tegra}"

"$SCRIPT_DIR/build_dtb.sh" "$BSP_ROOT"

echo
echo "Pon la Jetson en modo Recovery."
echo "Debe aparecer 0955:7f21 NVIDIA Corp. APX."
read -r -p "Presiona Enter cuando esté en Recovery..."

"$SCRIPT_DIR/flash_dtb.sh" "$BSP_ROOT"
