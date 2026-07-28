#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/waveshare-tool.sh"

for file in "$ROOT"/lib/*.sh "$ROOT"/tests/*.sh; do
    bash -n "$file"
done

echo "Sintaxis Bash correcta."
