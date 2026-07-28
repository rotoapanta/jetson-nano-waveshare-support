#!/usr/bin/env bash

verify_dtb() {
    require_bsp

    local output
    output="$(
        dtc -I dtb -O dts "$DTB_PATH" 2>/dev/null |
        sed -n '/sdhci@700b0400 {/,/};/p' |
        grep -E 'status|cd-gpios|sd-uhs|no-mmc|uhs-mask' || true
    )"

    echo "$output"

    local expected
    for expected in \
        'status = "okay";' \
        'cd-gpios = <0x5b 0xc2 0x00>;' \
        'sd-uhs-sdr104;' \
        'sd-uhs-sdr50;' \
        'sd-uhs-sdr25;' \
        'sd-uhs-sdr12;' \
        'no-mmc;' \
        'uhs-mask = <0x0c>;'
    do
        grep -Fq "$expected" <<<"$output" || die "No se encontró: $expected"
    done

    ok "El DTB contiene todas las propiedades requeridas."
}
