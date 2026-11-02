<h1 align="center">Dotfiles</h1>

### Stack

| Category        | Program                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------ |
| WM / Compositor | [umbriel](https://github.com/noctalia-dev/umbriel)                                                |
| Compositor (alt.) | [Hyprland](https://hypr.land)                                                                     |
| Desktop shell   | [noctalia](https://github.com/noctalia-dev/noctalia)                                             |
| Shell           | [fish](https://github.com/fish-shell/fish-shell) + [starship](https://github.com/starship/starship) |
| File manager    | [yazi](https://github.com/sxyazi/yazi)                                                           |

### Layout

- `global/` — shared configs (fish, starship, yazi, foot, fastfetch, noctalia, yt-dlp)
- `umbriel/` — Umbriel config (compositor, keybinds, window rules), autostart on tty1
- `hyprland/` — Hyprland Lua config (kompositor alternatif), autostart on tty1

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
./install.sh --dry-run             # lihat rencana tanpa mengubah apa pun
./install.sh --unlink              # lepas symlink
```

**Flags:**
- `--install-core` — install umbriel-git, noctalia, dan dependensi mereka saja. Butuh `sudo` dan `paru` (auto-bootstrap jika belum ada).
- `--dry-run` — simulasi, tidak menulis file.
- `--yes` — non-interaktif, skip prompt (kombinasi `--dry-run --yes` aman untuk CI).
- `--only=global,umbriel` — batasi paket config yang di-link.
- `--unlink` — hapus symlink tanpa hapus file di repo.

Butuh `stow`. Backup file lama masuk `~/.dotfiles-backup/<timestamp>/`.

### Hyprland (alternatif)
`hyprland/` berisi config Lua untuk Hyprland sebagai alternatif `umbriel/`. Keduanya sama-sama menyediakan `~/.config/fish/conf.d/autostart.fish`, jadi **hanya satu yang boleh ter-stow**. Installer menolak memilih keduanya sekaligus.

Ganti kompositor dengan stow manual:
```bash
cd ~/.dotfiles

# umbriel -> hyprland
stow --no-folding -d . -t ~ -D umbriel
stow --no-folding -d . -t ~ hyprland

# hyprland -> umbriel
stow --no-folding -d . -t ~ -D hyprland
stow --no-folding -d . -t ~ umbriel
```
Keduanya autostart di tty1. Runtime Hyprland butuh `hyprland` + `xdg-desktop-portal-hyprland`. Portal umbriel dan Hyprland boleh terpasang bersamaan: tidak ada konflik paket, dan `xdg-desktop-portal` memilih backend dari `XDG_CURRENT_DESKTOP` (`umbriel` vs `Hyprland`). Install sekali:
```bash
sudo pacman -S --needed xdg-desktop-portal-hyprland
```
Setelah ganti kompositor, logout penuh agar sesi systemd/portal lama tidak dipakai ulang. Noctalia membuat tema di `~/.config/hypr/noctalia.lua` (mode Lua) atau `noctalia.conf` (mode hyprlang); config memuat keduanya dengan fallback statis.
