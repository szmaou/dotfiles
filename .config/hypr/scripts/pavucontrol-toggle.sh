#!/usr/bin/env bash
if pgrep -x pavucontrol >/dev/null 2>&1; then
    hyprctl dispatch closewindow pavucontrol 2>/dev/null
    pkill -x pavucontrol 2>/dev/null
else
    pavucontrol
fi
