#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/lib/detect.sh"
# shellcheck source=lib/backup.sh
source "$SCRIPT_DIR/lib/backup.sh"
# shellcheck source=lib/dtb.sh
source "$SCRIPT_DIR/lib/dtb.sh"
# shellcheck source=lib/verify.sh
source "$SCRIPT_DIR/lib/verify.sh"
# shellcheck source=lib/recovery.sh
source "$SCRIPT_DIR/lib/recovery.sh"
# shellcheck source=lib/flash.sh
source "$SCRIPT_DIR/lib/flash.sh"

BSP_ROOT_OVERRIDE=""
COMMAND=""

usage() {
    cat <<EOF
Uso:
  ./waveshare-tool.sh
  ./waveshare-tool.sh [--bsp RUTA] COMANDO

Comandos:
  detect      Detectar BSP
  backup      Crear respaldo
  build       Modificar y compilar DTB
  verify      Verificar DTB
  recovery    Comprobar modo Recovery/APX
  flash       Flashear únicamente DTB
  all         Compilar, verificar y flashear
  restore     Restaurar DTB original
  diagnose    Mostrar diagnóstico
  help        Mostrar esta ayuda
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --bsp)
                [[ $# -ge 2 ]] || die "Falta la ruta después de --bsp"
                BSP_ROOT_OVERRIDE="$2"
                shift 2
                ;;
            -h|--help|help)
                COMMAND="help"
                shift
                ;;
            *)
                if [[ -z "$COMMAND" ]]; then
                    COMMAND="$1"
                    shift
                else
                    die "Argumento no reconocido: $1"
                fi
                ;;
        esac
    done
}

initialize_context() {
    check_dependencies
    if [[ -n "$BSP_ROOT_OVERRIDE" ]]; then
        set_bsp_root "$BSP_ROOT_OVERRIDE"
    else
        detect_bsp_root || true
    fi
}

run_all() {
    require_bsp
    backup_dtb
    build_dtb
    verify_dtb
    echo
    info "Pon ahora la Jetson en modo Recovery/APX."
    info "Debe aparecer: 0955:7f21 NVIDIA Corp. APX"
    wait_for_recovery
    flash_dtb
}

show_menu() {
    while true; do
        clear || true
        print_header
        show_status_summary
        cat <<'EOF'

1) Detectar BSP
2) Crear respaldo del DTB
3) Compilar DTB modificado
4) Verificar DTB
5) Comprobar modo Recovery
6) Flashear DTB
7) Compilar + flashear
8) Restaurar DTB original
9) Mostrar diagnóstico
0) Salir
EOF
        echo
        read -r -p "Seleccione una opción: " option
        echo
        case "$option" in
            1) detect_bsp_interactive ;;
            2) require_bsp; backup_dtb ;;
            3) require_bsp; backup_dtb; build_dtb ;;
            4) require_bsp; verify_dtb ;;
            5) check_recovery ;;
            6) require_bsp; flash_dtb ;;
            7) run_all ;;
            8) require_bsp; restore_dtb ;;
            9) diagnose ;;
            0) exit 0 ;;
            *) warn "Opción no válida." ;;
        esac
        echo
        read -r -p "Presiona Enter para continuar..." _
    done
}

main() {
    parse_args "$@"
    initialize_context

    if [[ -z "$COMMAND" ]]; then
        show_menu
        exit 0
    fi

    case "$COMMAND" in
        detect) detect_bsp_interactive ;;
        backup) require_bsp; backup_dtb ;;
        build) require_bsp; backup_dtb; build_dtb ;;
        verify) require_bsp; verify_dtb ;;
        recovery) check_recovery ;;
        flash) require_bsp; flash_dtb ;;
        all) run_all ;;
        restore) require_bsp; restore_dtb ;;
        diagnose) diagnose ;;
        help) usage ;;
        *) usage; die "Comando desconocido: $COMMAND" ;;
    esac
}

main "$@"
