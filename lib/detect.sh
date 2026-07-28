#!/usr/bin/env bash

candidate_is_bsp() {
    local path="$1"
    [[ -f "$path/flash.sh" && -f "$path/kernel/dtb/$DTB_NAME" ]]
}

detect_bsp_root() {
    local candidates=()
    local base

    for base in \
        "$PWD" \
        "$HOME/Descargas" \
        "$HOME/Downloads" \
        "$HOME/Documentos" \
        "$HOME/Documents" \
        "$HOME"
    do
        [[ -d "$base" ]] || continue
        while IFS= read -r path; do
            candidates+=("$path")
        done < <(find "$base" -maxdepth 5 -type d -name Linux_for_Tegra 2>/dev/null)
    done

    local unique=()
    local item seen
    for item in "${candidates[@]}"; do
        seen=0
        for u in "${unique[@]}"; do
            [[ "$u" == "$item" ]] && seen=1 && break
        done
        (( seen == 0 )) && unique+=("$item")
    done

    local valid=()
    for item in "${unique[@]}"; do
        candidate_is_bsp "$item" && valid+=("$item")
    done

    if (( ${#valid[@]} == 0 )); then
        return 1
    fi

    if (( ${#valid[@]} == 1 )); then
        set_bsp_root "${valid[0]}"
        return 0
    fi

    # Preferir la ruta más recientemente modificada.
    local newest
    newest="$(
        for item in "${valid[@]}"; do
            printf '%s %s\n' "$(stat -c %Y "$item" 2>/dev/null || echo 0)" "$item"
        done | sort -nr | head -n1 | cut -d' ' -f2-
    )"
    set_bsp_root "$newest"
}

detect_bsp_interactive() {
    if detect_bsp_root; then
        ok "BSP detectado: $BSP_ROOT"
    else
        warn "No se detectó automáticamente Linux_for_Tegra."
        read -r -p "Introduce la ruta completa del BSP: " manual
        set_bsp_root "$manual"
        require_bsp
        ok "BSP configurado: $BSP_ROOT"
    fi
}

detect_l4t_version() {
    local version=""
    if [[ -f "$BSP_ROOT/nv_tegra/nv-apply-debs.sh" ]]; then
        version="$(grep -RhoE 'R[0-9]+\.[0-9]+\.[0-9]+' "$BSP_ROOT" 2>/dev/null | sort -V | tail -n1 || true)"
    fi
    [[ -n "$version" ]] && echo "$version" || echo "desconocida"
}

recovery_status() {
    if lsusb | grep -qi '0955:7f21'; then
        echo "APX detectado"
    elif lsusb | grep -qi '0955:7020'; then
        echo "arranque normal"
    else
        echo "no detectado"
    fi
}

show_status_summary() {
    local l4t="no disponible"
    if [[ -n "$BSP_ROOT" ]]; then
        l4t="$(detect_l4t_version)"
    fi
    printf '\n%-14s: %s\n' "BSP detectado" "${BSP_ROOT:-no detectado}"
    printf '%-14s: %s\n' "L4T" "$l4t"
    printf '%-14s: %s\n' "DTB" "$DTB_NAME"
    printf '%-14s: %s\n' "Recovery" "$(recovery_status)"
}

diagnose() {
    print_header
    show_status_summary
    echo
    echo "USB NVIDIA:"
    lsusb | grep -i '0955' || echo "  No se detectaron dispositivos NVIDIA."
    echo
    if [[ -n "$BSP_ROOT" ]]; then
        echo "Archivos principales:"
        ls -lh "$BSP_ROOT/flash.sh" "$DTB_PATH" 2>/dev/null || true
        echo
        echo "Versión:"
        detect_l4t_version
    fi
}
