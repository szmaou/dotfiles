#!/usr/bin/env bash
if pgrep -x waypaper >/dev/null 2>&1; then
    hyprctl dispatch closewindow waypaper 2>/dev/null
    pkill -x waypaper 2>/dev/null
else
    waypaper
fi
