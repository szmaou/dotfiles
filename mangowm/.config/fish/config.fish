# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Custom exports
set -gx CARGO_HOME "$HOME/.local/share/cargo"
set -gx RUSTUP_HOME "$HOME/.local/share/rustup"
set -gx GOPATH "$HOME/.local/share/go"

# Format man pages
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# PATH
fish_add_path "$CARGO_HOME/bin" "$GOPATH/bin"

# Auto-start Mango on tty1 after login
if status is-login
    and test -z "$WAYLAND_DISPLAY"
    and test "$XDG_VTNR" = 1
    exec mango
end

if status is-interactive

    # No greeting
    set fish_greeting

    # Aliases
    alias ls "eza --icons --group-directories-first"
    alias ll "eza -l --icons --group-directories-first"
    alias la "eza -la --icons --group-directories-first"
    alias tree "eza --tree --icons"
    alias dot '/usr/bin/git --git-dir=$HOME/Public/dotfiles/ --work-tree=$HOME'
    alias cls "printf '\033[2J\033[3J\033[1;1H'"
    alias edit sudoedit
    alias n nvim
    alias ff fastfetch
    alias fs "fastfetch -c ~/.config/fastfetch/simple.jsonc"

    # Abbreviation
    abbr i "sudo pacman -S"
    abbr s "pacman -Ss"
    abbr si "pacman -Si"
    abbr syu "sudo pacman -Syu"
    abbr rns "sudo pacman -Rns"
    abbr qs "pacman -Qs"
    abbr qi "pacman -Qi"
    abbr qm "pacman -Qm"
    abbr qdt "pacman -Qdt"
    abbr ii "paru -S"
    abbr ss "paru -Ss"
    abbr sua "paru -Sua"
    abbr qua "paru -Qua"
    abbr fi "flatpak --installation=extra"

    # Starship
    function starship_transient_prompt_func
        starship module character
    end
    starship init fish | source
    enable_transience

    # Smart cd
    zoxide init fish | source

    # FZF integration
    fzf --fish | source

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
