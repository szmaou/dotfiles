<h1 align="center">Dotfiles</h1>

### Stack

| Category        | Program                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------ |
| WM / Compositor | [umbriel](https://github.com/noctalia-dev/umbriel)                                                |
| Desktop shell   | [noctalia](https://github.com/noctalia-dev/noctalia)                                             |
| Shell           | [fish](https://github.com/fish-shell/fish-shell) + [starship](https://github.com/starship/starship) |
| File manager    | [yazi](https://github.com/sxyazi/yazi)                                                           |

### Layout

- `global/` — shared configs (fish, starship, yazi, foot, fastfetch, noctalia, yt-dlp)
- `umbriel/` — Umbriel config (compositor, keybinds, window rules), autostart on tty1

### Quick install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/szmaou/dotfiles/main/install.sh)
```

Clone repo ke `~/.dotfiles` (atau `$DOTFILES_DIR`) lalu langsung menjalankan installer. Butuh `git` dan `stow`.

### Install

```bash
git clone https://github.com/szmaou/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
./install.sh              # pilih bahasa lalu paket lewat whiptail, backup, stow ke $HOME
./install.sh --lang=id    # pesan bahasa Indonesia
./install.sh --dry-run    # lihat rencana tanpa mengubah apa pun
./install.sh --unlink     # lepas symlink
```

Butuh `stow`. Backup file lama masuk `~/.dotfiles-backup/<timestamp>/`.