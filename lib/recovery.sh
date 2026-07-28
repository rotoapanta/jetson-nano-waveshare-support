#!/usr/bin/env bash

check_recovery() {
    local apx
    apx="$(lsusb | grep -i '0955:7f21' || true)"

    if [[ -n "$apx" ]]; then
        ok "Jetson detectada en Recovery/APX:"
        echo "$apx"
        return 0
    fi

    if lsusb | grep -qi '0955:7020'; then
        warn "La Jetson está en arranque normal, no en Recovery."
        lsusb | grep -i '0955:7020'
    else
        warn "No se detectó ninguna Jetson en Recovery."
    fi
    return 1
}

wait_for_recovery() {
    info "Esperando modo Recovery/APX..."
    while ! lsusb | grep -qi '0955:7f21'; do
        sleep 2
    done
    ok "Recovery/APX detectado."
    lsusb | grep -i '0955:7f21'
}
