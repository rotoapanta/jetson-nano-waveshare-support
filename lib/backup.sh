#!/usr/bin/env bash

backup_dtb() {
    require_bsp

    if [[ -f "$BACKUP_PATH" ]]; then
        ok "El respaldo ya existe: $BACKUP_PATH"
        return 0
    fi

    cp -a "$DTB_PATH" "$BACKUP_PATH"
    ok "Respaldo creado: $BACKUP_PATH"
}

restore_dtb() {
    require_bsp
    [[ -f "$BACKUP_PATH" ]] || die "No existe el respaldo: $BACKUP_PATH"

    cp -a "$DTB_PATH" "$DTB_DIR/${DTB_NAME}.waveshare-current"
    cp -a "$BACKUP_PATH" "$DTB_PATH"

    ok "DTB original restaurado."
    info "Para aplicarlo, coloca la Jetson en Recovery y selecciona Flashear DTB."
}
