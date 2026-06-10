#!/usr/bin/env bash

pkill -x fuzzel 2>/dev/null && exit 0

menu="   Lock\n󰗽   Log Out\n   Reboot\n󰐥   Shutdown"
choice=$(printf "$menu" | fuzzel -d -a top-right -w 12 --x-margin 5 --y-margin 5 -r 5 -l 4 --hide-prompt --only-match)

case $choice in
    *"Lock") (
            sleep 0.15
            hyprlock
        ) & ;;
    *"Log Out") loginctl terminate-user "" ;;
    *"Reboot") systemctl reboot ;;
    *"Shutdown") systemctl poweroff ;;
esac
exit 0
