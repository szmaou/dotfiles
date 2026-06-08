# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Custom exports
set -gx CARGO_HOME "$HOME/.local/share/cargo"
set -gx RUSTUP_HOME "$HOME/.local/share/rustup"
set -gx GOPATH "$HOME/.local/share/go"

# PATH
fish_add_path "$CARGO_HOME/bin" "$GOPATH/bin"

# UWSM
if status is-login; and test (tty) = "/dev/tty1"
    if uwsm check may-start
        exec uwsm start hyprland.desktop
    end
end

if status is-interactive

    # No greeting
    set fish_greeting

    # Aliases
    alias dot='/usr/bin/git --git-dir=$HOME/Public/dotfiles/ --work-tree=$HOME'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias cls "printf '\033[2J\033[3J\033[1;1H'"
    alias syu "sudo pacman -Syu"
    alias rns "paru -Rns"
    alias ss "paru -Ss"
    alias s "pacman -Ss"
    alias pacs "sudo pacman -S"
    alias pars "paru -S"
    alias qs "pacman -Qs"
    alias qi "pacman -Qi"
    alias qdt "pacman -Qdt"
    alias edit sudoedit
    alias n nvim
    alias ff fastfetch

    # Starship
    function starship_transient_prompt_func
        starship module character
    end
    starship init fish | source

    # Yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
            builtin cd -- "$cwd"
        end
        command rm -f -- "$tmp"
    end
end
