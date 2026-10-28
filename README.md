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
./install.sh                       # pilih bahasa lalu paket lewat whiptail, backup, stow ke $HOME
./install.sh --lang=id             # pesan bahasa Indonesia
./install.sh --install-core        # install umbriel + noctalia + dependensi (official + AUR)
./install.sh --with-packages       # install SEMUA paket dari pkg.txt (official, AUR, flatpak)
./install.sh --dry-run             # lihat rencana tanpa mengubah apa pun
./install.sh --unlink              # lepas symlink
```

**Flags:**
- `--install-core` — install umbriel-git, noctalia, dan dependensi mereka saja (bukan pkg.txt lengkap). Butuh `sudo` dan `paru` (auto-bootstrap jika belum ada).
- `--with-packages` — install SEMUA paket dari `pkg.txt` via `pacman` (official), `paru` (AUR), `flatpak`. Butuh `sudo`.
- `--dry-run` — simulasi, tidak menulis file.
- `--yes` — non-interaktif, skip prompt (kombinasi `--dry-run --yes` aman untuk CI).
- `--only=global,umbriel` — batasi paket config yang di-link.
- `--unlink` — hapus symlink tanpa hapus file di repo.

Butuh `stow`. Backup file lama masuk `~/.dotfiles-backup/<timestamp>/`.