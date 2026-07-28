#!/usr/bin/env bash

flash_dtb() {
    require_bsp
    check_recovery || die "Coloca la Jetson en modo Recovery antes de flashear."

    warn "Se actualizará únicamente la partición DTB."
    warn "No desconectes alimentación ni USB durante el proceso."

    cd "$BSP_ROOT"
    sudo ./flash.sh -r -k DTB jetson-nano-emmc mmcblk0p1

    ok "Proceso de flasheo finalizado."
}
