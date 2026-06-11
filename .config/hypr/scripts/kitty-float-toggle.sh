#!/usr/bin/env bash
if hyprctl clients -j 2>/dev/null | jq -e 'any(.[]; .class == "kitty-float")' >/dev/null 2>&1; then
    hyprctl dispatch closewindow kitty-float 2>/dev/null
    pkill -f "kitty.*--class kitty-float" 2>/dev/null
else
    kitty --class kitty-float
fi
