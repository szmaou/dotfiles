#!/usr/bin/env bash

pkill -x fuzzel 2>/dev/null && exit 0

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

choice=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%f\n" | sort | grep -v "^$" | fuzzel -d -a center -l 10 --minimal-lines ) || exit 0

selected="$WALLPAPER_DIR/$choice"
[[ ! -f "$selected" ]] && exit 0

awww img --transition-type random "$selected"
matugen -q image --prefer saturation "$selected"
