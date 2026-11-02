# Auto-start Hyprland on tty1 after login
if status is-login
    and test -z "$WAYLAND_DISPLAY"
    and test "$XDG_VTNR" = 1
    exec start-hyprland
end
