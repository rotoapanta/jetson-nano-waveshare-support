#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

required=(
    "waveshare-tool.sh"
    "lib/common.sh"
    "lib/detect.sh"
    "lib/backup.sh"
    "lib/dtb.sh"
    "lib/verify.sh"
    "lib/recovery.sh"
    "lib/flash.sh"
    "patches/enable-microsd.patch"
)

for file in "${required[@]}"; do
    [[ -f "$ROOT/$file" ]] || {
        echo "Falta: $file" >&2
        exit 1
    }
done

echo "Estructura correcta."
