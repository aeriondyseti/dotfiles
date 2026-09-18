#!/bin/bash
# Usage: build-theme.sh WIDTH HEIGHT   -> regenerates ./omarchy-green for that GRUB resolution
set -euo pipefail
W=$1; H=$2; SRC_IMG="$(cd "$(dirname "$0")" && pwd)/bootloader.png"
cd "$(dirname "$0")"; rm -rf omarchy-green; mkdir -p omarchy-green/icons; cd omarchy-green
s() { echo $(( ($1 * H + 384) / 768 )); }   # scale a 768p value to this height
R=/usr/share/fonts/noto/NotoSans-Regular.ttf; B=/usr/share/fonts/noto/NotoSans-Bold.ttf
FT=$(s 30); FI=$(s 20); FS=$(s 14)
grub-mkfont -s $FT -o title.pf2 $B 2>/dev/null; grub-mkfont -s $FI -o item.pf2 $R 2>/dev/null
grub-mkfont -s $FI -o itemsel.pf2 $B 2>/dev/null; grub-mkfont -s $FS -o small.pf2 $R 2>/dev/null
magick "$SRC_IMG" -filter Lanczos -resize ${W}x${H}! -strip -depth 8 PNG24:background.png
IC=$(s 52); q=$((IC/16)); h=$((IC/2)); g=$((IC/32+1))
magick /usr/share/pixmaps/omarchy.png -fill '#2ee6a8' -colorize 100 -resize ${IC}x${IC} -depth 8 PNG32:icons/omarchy.png
magick -size ${IC}x${IC} xc:none -fill '#2ee6a8' -draw "rectangle $q,$q $((h-g)),$((h-g))" -draw "rectangle $((h+g)),$q $((IC-q-1)),$((h-g))" \
  -draw "rectangle $q,$((h+g)) $((h-g)),$((IC-q-1))" -draw "rectangle $((h+g)),$((h+g)) $((IC-q-1)),$((IC-q-1))" -depth 8 PNG32:icons/windows.png
C=$(s 6); [ $C -lt 4 ] && C=4; F=$((C*3)); SW=$(awk "BEGIN{print 1.5*$H/768}")
magick -size ${F}x${F} xc:none -fill 'rgba(46,230,168,0.18)' -stroke 'rgba(46,230,168,0.85)' -strokewidth $SW -draw "roundrectangle 1,1 $((F-2)),$((F-2)) $((C-1)),$((C-1))" full.png
i=0; for n in nw n ne w c e sw s se; do magick full.png -crop ${C}x${C}+$(( (i%3)*C ))+$(( (i/3)*C )) +repage -depth 8 PNG32:select_$n.png; i=$((i+1)); done; rm full.png
cat > theme.txt <<THEME
# Omarchy green - GRUB theme (generated for ${W}x${H} by build-theme.sh)
title-text: ""
desktop-image: "background.png"
desktop-image-scale-method: "stretch"
desktop-color: "#000202"
terminal-font: "Noto Sans Regular $FS"
terminal-box: "select_*.png"

+ label {
    left = 60%
    top = 55%
    width = 36%
    height = $(s 40)
    text = "Select your OS"
    font = "Noto Sans Bold $FT"
    color = "#2ee6a8"
}

+ boot_menu {
    left = 60%
    top = 62%
    width = 34%
    height = $(s 130)
    selected_item_pixmap_style = "select_*.png"
    item_font = "Noto Sans Regular $FI"
    selected_item_font = "Noto Sans Bold $FI"
    item_color = "#a8c9ba"
    selected_item_color = "#ffffff"
    item_height = $(s 40)
    item_padding = $(s 10)
    item_spacing = $(s 22)
    icon_width = $(s 26)
    icon_height = $(s 26)
    item_icon_space = $(s 14)
    scrollbar = false
}

+ label {
    id = "__timeout__"
    left = 60%
    top = 83%
    width = 36%
    height = $(s 20)
    text = "Windows starts in %d seconds"
    font = "Noto Sans Regular $FS"
    color = "#3a9c76"
}

+ label {
    left = 60%
    top = 87%
    width = 36%
    height = $(s 20)
    text = "Arrow keys to choose, Enter to boot"
    font = "Noto Sans Regular $FS"
    color = "#24634b"
}
THEME
echo "Built theme for ${W}x${H}"
