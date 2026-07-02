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

# UWSM
if status is-login; and test (string match -r '/dev/tty1$' (tty))
    if uwsm check may-start; and uwsm select
        exec uwsm start default
    end
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

    # Starship
    function starship_transient_prompt_func
        starship module character
    end
    starship init fish | source

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
