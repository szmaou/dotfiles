# Auto-start Hyprland on tty2 after login (umbriel keeps tty1)
if status is-login
    and test -z "$WAYLAND_DISPLAY"
    and test "$XDG_VTNR" = 2
    exec start-hyprland
end
