#!/usr/bin/env bash
# Link the dotfiles packages (global/, umbriel/) into $HOME with GNU stow.
# Optional: install packages via --with-packages (all from pkg.txt) or --install-core (umbriel + noctalia + deps).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
REPO_URL="https://github.com/szmaou/dotfiles.git"

# Run through curl (script alone, no repo around it): clone, then re-exec.
if [[ ! -d "$REPO/global/.config" ]]; then
  command -v git >/dev/null || { echo "error: git is missing: sudo pacman -S git" >&2; exit 1; }
  command -v stow >/dev/null || { echo "error: stow is missing: sudo pacman -S stow" >&2; exit 1; }
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    printf 'updating %s\n' "$DOTFILES_DIR" >&2
    git -C "$DOTFILES_DIR" pull --ff-only >&2
  else
    printf 'cloning %s -> %s\n' "$REPO_URL" "$DOTFILES_DIR" >&2
    git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR" >&2
  fi
  exec "$DOTFILES_DIR/install.sh" "$@"
fi

ALL_PKGS=(global umbriel)
PKGS=()
DRY=0
YES=0
BACKUP=1
UNLINK=0
ONLY=""
LANG_CODE=""
WITH_PACKAGES=0
INSTALL_CORE=0
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/.dotfiles-backup"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-link.log"

# ── Core packages: umbriel-git + noctalia + their deps ───────────────────────
# From pacman -Qi (official repo + AUR)
CORE_OFFICIAL=(
  # umbriel deps (official)
  cairo gcc-libs glibc jemalloc lcms2 libdrm libdisplay-info libglvnd
  libinput libxcb libxkbcommon mesa pango pixman systemd-libs tomlplusplus
  wayland xcb-util-wm xorg-xwayland wlroots
  # noctalia deps (official)
  bash curl fontconfig freetype2 git glib2 glibc harfbuzz hicolor-icon-theme
  libical libjxl libpipewire libqalculate librsvg libsecret libsndfile
  libsodium libwebp libwireplumber libxml2 md4c pam polkit sdbus-cpp
  # noctalia optional deps
  ddcutil power-profiles-daemon upower
)
CORE_AUR=(umbriel-git xdg-desktop-portal-umbriel-git)
# Note: wlroots0.20 is in official as 'wlroots' now (>=0.20.1)

# ── i18n ────────────────────────────────────────────────────────────────────
declare -A MSG_EN=(
  [usage]='usage: ./install.sh [options]

  --lang=en|id            language, default en
  --only=global,umbriel   limit to these packages (default: both)
  --with-packages         install ALL packages from pkg.txt (official, AUR, flatpak)
  --install-core          install umbriel + noctalia + their dependencies only
  --dry-run               print actions, change nothing
  --yes                   no prompts (skip files owned by another user)
  --no-backup             do not move conflicting files to ~/.dotfiles-backup
  --unlink                remove the symlinks instead of creating them
  -h, --help'
  [lang_title]='Language'
  [lang_prompt]='Choose language:'
  [err_repo]='%s is not the dotfiles repo root (global/.config or umbriel/.config missing)'
  [err_root]='run as a normal user, not root'
  [err_home]='HOME is not writable'
  [err_stow]='stow is missing: sudo pacman -S stow'
  [err_unknown_opt]='unknown option: %s'
  [err_unknown_pkg]='unknown package: %s'
  [err_cancel]='cancelled'
  [err_no_pkg]='no package selected'
  [err_conflict_nobackup]='conflict on %s; drop --no-backup to back it up'
  [err_validate]='validation failed, see %s'
  [err_unlinked]='some targets are not linked, see %s'
  [pick_title]='Dotfiles installer'
  [pick_prompt]='Select packages to link into $HOME:'
  [desc_global]='fish, starship, foot, yazi, btop, fastfetch, noctalia, yt-dlp, bunfig'
  [desc_umbriel]='compositor config + tty1 autostart'
  [repo]='repo: %s'
  [packages]='packages: %s'
  [st_new]='+ %s'
  [st_linked]='= %s'
  [st_owned]='! %s is owned by another user (uid %s)'
  [st_ask]='Back up that file? [y/N] '
  [st_skip]='- %s skipped'
  [st_skip_yes]='- %s skipped (--yes)'
  [st_backup]='backup %s -> %s'
  [sim_conflict]='(stow simulation: conflicts remain)'
  [missing]='MISSING %s'
  [ok_umbriel]='ok umbriel config'
  [fail_umbriel]='FAIL umbriel config'
  [miss_include]='MISSING include %s'
  [ok_fish]='ok fish syntax'
  [fail_fish]='FAIL fish syntax'
  [unlink_done]='unlink done. log: %s'
  [done]='done. log: %s'
  [pkg_title]='Package installation'
  [pkg_prompt]='Install packages?'
  [pkg_official]='official repo'
  [pkg_aur]='AUR'
  [pkg_flatpak]='Flatpak'
  [pkg_installing]='installing %s packages...'
  [pkg_already]='already installed'
  [pkg_paru_missing]='paru not found; bootstrapping from AUR...'
  [pkg_flatpak_missing]='flatpak not found; skipping Flatpak packages'
  [pkg_sudo]='sudo required for package installation'
  [core_title]='Core installation (umbriel + noctalia)'
  [core_prompt]='Install umbriel-git, noctalia, and their dependencies?'
  [core_desc]='Official repo: %d packages\nAUR: %d packages'
)
declare -A MSG_ID=(
  [usage]='penggunaan: ./install.sh [opsi]

  --lang=en|id            bahasa, default en
  --only=global,umbriel   batasi ke paket ini (default: keduanya)
  --with-packages         install SEMUA paket dari pkg.txt (official, AUR, flatpak)
  --install-core          install umbriel + noctalia + dependensi mereka saja
  --dry-run               cetak aksi, tidak mengubah apa pun
  --yes                   tanpa tanya (lewati file milik user lain)
  --no-backup             jangan pindahkan file konflik ke ~/.dotfiles-backup
  --unlink                lepas symlink, bukan membuatnya
  -h, --help'
  [lang_title]='Bahasa'
  [lang_prompt]='Pilih bahasa:'
  [err_repo]='%s bukan root repo dotfiles (global/.config atau umbriel/.config tidak ada)'
  [err_root]='jalankan sebagai user biasa, bukan root'
  [err_home]='HOME tidak writable'
  [err_stow]='stow tidak ada: sudo pacman -S stow'
  [err_unknown_opt]='opsi tidak dikenal: %s'
  [err_unknown_pkg]='paket tidak dikenal: %s'
  [err_cancel]='dibatalkan'
  [err_no_pkg]='tidak ada paket dipilih'
  [err_conflict_nobackup]='konflik pada %s; pakai --no-backup untuk melewati backup otomatis'
  [err_validate]='validasi gagal, cek %s'
  [err_unlinked]='ada target yang tidak ter-link, cek %s'
  [pick_title]='Installer dotfiles'
  [pick_prompt]='Pilih paket yang dilink ke $HOME:'
  [desc_global]='fish, starship, foot, yazi, btop, fastfetch, noctalia, yt-dlp, bunfig'
  [desc_umbriel]='config compositor + autostart tty1'
  [repo]='repo: %s'
  [packages]='paket: %s'
  [st_new]='+ %s'
  [st_linked]='= %s'
  [st_owned]='! %s dimiliki user lain (uid %s)'
  [st_ask]='Backup file itu? [y/N] '
  [st_skip]='- %s dilewati'
  [st_skip_yes]='- %s dilewati (--yes)'
  [st_backup]='backup %s -> %s'
  [sim_conflict]='(simulasi stow: masih ada konflik)'
  [missing]='HILANG %s'
  [ok_umbriel]='ok umbriel config'
  [fail_umbriel]='GAGAL umbriel config'
  [miss_include]='HILANG include %s'
  [ok_fish]='ok fish syntax'
  [fail_fish]='GAGAL fish syntax'
  [unlink_done]='unlink selesai. log: %s'
  [done]='selesai. log: %s'
  [pkg_title]='Instalasi paket'
  [pkg_prompt]='Install paket dari pkg.txt?'
  [pkg_official]='repo resmi'
  [pkg_aur]='AUR'
  [pkg_flatpak]='Flatpak'
  [pkg_installing]='menginstall %s paket...'
  [pkg_already]='sudah terinstall'
  [pkg_paru_missing]='paru tidak ditemukan; bootstrap dari AUR...'
  [pkg_flatpak_missing]='flatpak tidak ditemukan; melewati paket Flatpak'
  [pkg_sudo]='sudo diperlukan untuk instalasi paket'
  [core_title]='Instalasi core (umbriel + noctalia)'
  [core_prompt]='Install umbriel-git, noctalia, dan dependensi mereka?'
  [core_desc]='Repo resmi: %d paket\nAUR: %d paket'
)

# t <key> [printf args...]
t() {
  local key=$1
  shift
  local -n table="MSG_${LANG_CODE^^}"
  printf -- "${table[$key]}" "$@"
}

log() {
  printf '%s\n' "$*"
  (( DRY )) && return 0
  mkdir -p "$(dirname "$LOG")"
  printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >>"$LOG"
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

run() {
  log "  \$ $*"
  (( DRY )) && return 0
  "$@"
}

choose_language() {
  [[ -n $LANG_CODE ]] && return
  if (( ! YES )) && [[ -t 0 ]] && command -v whiptail >/dev/null; then
    local pick
    pick=$(whiptail --title "$(t lang_title)" --menu "$(t lang_prompt)" 12 60 2 \
      en "English" \
      id "Indonesian" \
      3>&1 1>&2 2>&3) || pick=""
    [[ $pick == id ]] && LANG_CODE=id
  elif (( ! YES )) && [[ -t 0 ]]; then
    local a=""
    read -r -p "Language / Bahasa [en/id] (en): " a </dev/tty || a=""
    [[ $a == id ]] && LANG_CODE=id
  fi
  LANG_CODE="${LANG_CODE:-en}"
}

while (( $# )); do
  case "$1" in
    --lang=*) LANG_CODE="${1#*=}"; shift ;;
    --only=*) ONLY="${1#*=}"; shift ;;
    --with-packages) WITH_PACKAGES=1; shift ;;
    --install-core) INSTALL_CORE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --yes|-y) YES=1; shift ;;
    --no-backup) BACKUP=0; shift ;;
    --unlink) UNLINK=1; shift ;;
    -h|--help)
      LANG_CODE="${LANG_CODE:-en}"
      [[ $LANG_CODE == id || $LANG_CODE == en ]] || LANG_CODE=en
      t usage; echo; exit 0 ;;
    *) LANG_CODE="${LANG_CODE:-en}"; t usage >&2; die "$(t err_unknown_opt "$1")" ;;
  esac
done

choose_language
case "$LANG_CODE" in
  en|id) ;;
  *) printf 'error: unknown language: %s (en|id)\n' "$LANG_CODE" >&2; exit 1 ;;
esac

# ── Package installation ────────────────────────────────────────────────────
is_installed_pacman() { pacman -Q "$1" >/dev/null 2>&1; }
is_installed_paru() { paru -Q "$1" >/dev/null 2>&1; }
is_installed_flatpak() { flatpak list --app --columns=application 2>/dev/null | grep -qx "$1"; }

bootstrap_paru() {
  log "  $(t pkg_paru_missing)"
  (( DRY )) && return 0
  local tmpdir
  tmpdir=$(mktemp -d)
  run git clone https://aur.archlinux.org/paru-bin.git "$tmpdir"
  run makepkg -si --noconfirm -D "$tmpdir"
  run rm -rf "$tmpdir"
}

install_core() {
  (( INSTALL_CORE )) || return 0
  log "== $(t core_title)"

  local to_install_official=() to_install_aur=() pkg

  for pkg in "${CORE_OFFICIAL[@]}"; do
    if is_installed_pacman "$pkg"; then
      log "  = $pkg ($(t pkg_already))"
    else
      to_install_official+=("$pkg")
    fi
  done

  for pkg in "${CORE_AUR[@]}"; do
    if is_installed_paru "$pkg"; then
      log "  = $pkg ($(t pkg_already))"
    else
      to_install_aur+=("$pkg")
    fi
  done

  local total=$(( ${#to_install_official[@]} + ${#to_install_aur[@]} ))
  if (( total == 0 )); then
    log "  all core packages already installed"
    return 0
  fi

  if (( ! YES )) && [[ -t 0 ]]; then
    local msg
    printf -v msg "$(t core_desc)" "${#to_install_official[@]}" "${#to_install_aur[@]}"
    if command -v whiptail >/dev/null; then
      whiptail --title "$(t core_title)" --yesno "$(t core_prompt)\n\n$msg" 14 70 \
        3>&1 1>&2 2>&3 || { log "cancelled"; return 1; }
    else
      read -r -p "$(t core_prompt) ($msg) [y/N] " msg </dev/tty
      [[ $msg == [yY] ]] || { log "cancelled"; return 1; }
    fi
  fi

  if (( ! DRY )); then
    sudo -v || die "$(t pkg_sudo)"
  fi

  if (( ${#to_install_official[@]} )); then
    log "  $(t pkg_installing "${#to_install_official[@]}") $(t pkg_official)"
    run sudo pacman -S --needed --noconfirm "${to_install_official[@]}"
  fi

  if (( ${#to_install_aur[@]} )); then
    command -v paru >/dev/null || bootstrap_paru
    log "  $(t pkg_installing "${#to_install_aur[@]}") $(t pkg_aur)"
    run paru -S --needed --noconfirm "${to_install_aur[@]}"
  fi
}

parse_pkg_txt() {
  local section="" line pkg
  OFFICIAL_PKGS=()
  AUR_PKGS=()
  FLATPAK_PKGS=()
  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line// /}"
    [[ -z $line ]] && continue
    if [[ $line == "#official"* || $line == "#officialrepo" ]]; then
      section="official"
      continue
    elif [[ $line == "#aur" ]]; then
      section="aur"
      continue
    elif [[ $line == "#flatpak" ]]; then
      section="flatpak"
      continue
    fi
    case "$section" in
      official) OFFICIAL_PKGS+=("$line") ;;
      aur) AUR_PKGS+=("$line") ;;
      flatpak) FLATPAK_PKGS+=("$line") ;;
    esac
  done < "$REPO/pkg.txt"
}

install_packages() {
  (( WITH_PACKAGES )) || return 0
  log "== $(t pkg_title)"

  parse_pkg_txt

  local to_install_official=() to_install_aur=() to_install_flatpak=() pkg

  for pkg in "${OFFICIAL_PKGS[@]}"; do
    if is_installed_pacman "$pkg"; then
      log "  = $pkg ($(t pkg_already))"
    else
      to_install_official+=("$pkg")
    fi
  done

  for pkg in "${AUR_PKGS[@]}"; do
    if is_installed_paru "$pkg"; then
      log "  = $pkg ($(t pkg_already))"
    else
      to_install_aur+=("$pkg")
    fi
  done

  for pkg in "${FLATPAK_PKGS[@]}"; do
    if is_installed_flatpak "$pkg"; then
      log "  = $pkg ($(t pkg_already))"
    else
      to_install_flatpak+=("$pkg")
    fi
  done

  local total=$(( ${#to_install_official[@]} + ${#to_install_aur[@]} + ${#to_install_flatpak[@]} ))
  if (( total == 0 )); then
    log "  all packages already installed"
    return 0
  fi

  if (( ! YES )) && [[ -t 0 ]]; then
    local msg
    printf -v msg "$(t pkg_installing)" "$total"
    if command -v whiptail >/dev/null; then
      whiptail --title "$(t pkg_title)" --yesno "$msg\n\n$(t pkg_official): ${#to_install_official[@]}\n$(t pkg_aur): ${#to_install_aur[@]}\n$(t pkg_flatpak): ${#to_install_flatpak[@]}" 16 70 \
        3>&1 1>&2 2>&3 || { log "cancelled"; return 1; }
    else
      read -r -p "$msg (official: ${#to_install_official[@]}, AUR: ${#to_install_aur[@]}, flatpak: ${#to_install_flatpak[@]}) [y/N] " msg </dev/tty
      [[ $msg == [yY] ]] || { log "cancelled"; return 1; }
    fi
  fi

  if (( ! DRY )); then
    sudo -v || die "$(t pkg_sudo)"
  fi

  if (( ${#to_install_official[@]} )); then
    log "  $(t pkg_installing "${#to_install_official[@]}") $(t pkg_official)"
    run sudo pacman -S --needed --noconfirm "${to_install_official[@]}"
  fi

  if (( ${#to_install_aur[@]} )); then
    command -v paru >/dev/null || bootstrap_paru
    log "  $(t pkg_installing "${#to_install_aur[@]}") $(t pkg_aur)"
    run paru -S --needed --noconfirm "${to_install_aur[@]}"
  fi

  if (( ${#to_install_flatpak[@]} )); then
    if command -v flatpak >/dev/null; then
      run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      run flatpak remote-add --if-not-exists modmanager-origin https://chrisdkn.github.io/Amethyst-Mod-Manager/repo/
      log "  $(t pkg_installing "${#to_install_flatpak[@]}") $(t pkg_flatpak)"
      run flatpak install --noninteractive --assumeyes flathub "${to_install_flatpak[@]}"
    else
      log "  $(t pkg_flatpak_missing)"
    fi
  fi
}

preflight() {
  [[ -d "$REPO/global/.config" && -d "$REPO/umbriel/.config" ]] ||
    die "$(t err_repo "$REPO")"
  [[ $EUID -ne 0 ]] || die "$(t err_root)"
  [[ -n "${HOME:-}" && -w "$HOME" ]] || die "$(t err_home)"
  command -v stow >/dev/null || die "$(t err_stow)"
}

choose_packages() {
  local pick=()
  if [[ -n $ONLY ]]; then
    local p
    IFS=, read -r -a pick <<<"$ONLY"
    for p in "${pick[@]}"; do
      [[ " ${ALL_PKGS[*]} " == *" $p "* ]] || die "$(t err_unknown_pkg "$p")"
      PKGS+=("$p")
    done
    return
  fi

  if (( ! YES )) && [[ -t 0 ]] && command -v whiptail >/dev/null; then
    local out
    out=$(whiptail --title "$(t pick_title)" --checklist --separate-output \
      "$(t pick_prompt)" 18 84 6 \
      global "$(t desc_global)" ON \
      umbriel "$(t desc_umbriel)" ON \
      3>&1 1>&2 2>&3) || die "$(t err_cancel)"
    mapfile -t pick <<<"$out"
    PKGS=("${pick[@]}")
    (( ${#PKGS[@]} )) || die "$(t err_no_pkg)"
    return
  fi

  PKGS=("${ALL_PKGS[@]}")
}

# Repo-relative path of every file in a package, one per line.
pkg_files() {
  local pkg=$1
  if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$REPO" ls-files -z -- "$pkg" | tr '\0' '\n'
  else
    ( cd "$REPO" && find "$pkg" -type f | sort )
  fi
}

# new | linked | conflict
target_state() {
  local rel=$1 t="$HOME/${rel#*/}"
  if [[ ! -e $t && ! -L $t ]]; then
    echo new
  elif [[ "$(readlink -f -- "$t")" == "$(readlink -f -- "$REPO/$rel")" ]]; then
    echo linked
  else
    echo conflict
  fi
}

backup_target() {
  local rel=$1 t="$HOME/${rel#*/}" dest
  dest="$BACKUP_ROOT/$STAMP/${t#"$HOME"/}"
  log "  $(t st_backup "${t#"$HOME"/}" "${dest#"$HOME"/}")"
  run mkdir -p "$(dirname "$dest")"
  run mv -- "$t" "$dest"
}

resolve_conflicts() {
  local pkg=$1 rel t
  while read -r rel; do
    t="$HOME/${rel#*/}"
    case "$(target_state "$rel")" in
      new) log "  $(t st_new "${t#"$HOME"/}")" ;;
      linked) log "  $(t st_linked "${t#"$HOME"/}")" ;;
      conflict)
        if [[ ! -O $t ]]; then
          log "  $(t st_owned "${t#"$HOME"/}" "$(stat -c %u -- "$t")")"
          if (( ! YES )); then
            local a=n
            read -r -p "    $(t st_ask)" a </dev/tty || a=n
            if [[ $a != [yY] ]]; then
              log "  $(t st_skip "${t#"$HOME"/}")"
              continue
            fi
          else
            log "  $(t st_skip_yes "${t#"$HOME"/}")"
            continue
          fi
        fi
        (( BACKUP )) || die "$(t err_conflict_nobackup "${t#"$HOME"/}")"
        backup_target "$rel"
        ;;
    esac
  done < <(pkg_files "$pkg")
}

link_packages() {
  local pkg
  for pkg in "${PKGS[@]}"; do
    log "== $pkg"
    resolve_conflicts "$pkg"
    if (( UNLINK )); then
      run stow -d "$REPO" -t "$HOME" -D "$pkg"
    elif (( DRY )); then
      stow --simulate -v -d "$REPO" -t "$HOME" --restow "$pkg" >/dev/null 2>&1 ||
        log "  $(t sim_conflict)"
      log "  \$ stow -d $REPO -t \$HOME --restow $pkg"
    else
      run stow -d "$REPO" -t "$HOME" --restow "$pkg"
    fi
  done
}

verify_links() {
  local pkg=$1 rel t missing=0
  while read -r rel; do
    t="$HOME/${rel#*/}"
    if [[ ! -L $t && ! -e $t ]]; then
      log "  $(t missing "${t#"$HOME"/}")"
      missing=1
    fi
  done < <(pkg_files "$pkg")
  return "$missing"
}

validate_configs() {
  local fail=0 cfg="$HOME/.config/umbriel/config.toml" inc
  if [[ -f $cfg ]]; then
    if command -v umbriel >/dev/null; then
      if (( DRY )); then
        log "  (dry-run) umbriel config validate -c $cfg"
      elif umbriel config validate -c "$cfg" >/dev/null 2>&1; then
        log "  $(t ok_umbriel)"
      else
        log "  $(t fail_umbriel)"
        fail=1
      fi
    fi
    while read -r inc; do
      [[ -r "$HOME/.config/umbriel/$inc" ]] || { log "  $(t miss_include "$inc")"; fail=1; }
    done < <(grep -oE '"src/[^"]+\.toml"' "$cfg" | tr -d '"')
  fi

  if [[ -f $HOME/.config/fish/config.fish ]] && command -v fish >/dev/null; then
    if (( DRY )); then
      log "  (dry-run) fish -n ~/.config/fish/config.fish"
    elif fish -n "$HOME/.config/fish/config.fish"; then
      log "  $(t ok_fish)"
    else
      log "  $(t fail_fish)"
      fail=1
    fi
  fi
  return "$fail"
}

preflight
install_core
install_packages
choose_packages
log "$(t repo "$REPO")"
log "$(t packages "${PKGS[*]}")"

link_packages
(( UNLINK )) && { log "$(t unlink_done "$LOG")"; exit 0; }

if (( ! DRY )); then
  for pkg in "${PKGS[@]}"; do
    verify_links "$pkg" || die "$(t err_unlinked "$LOG")"
  done
fi

validate_configs || die "$(t err_validate "$LOG")"

log "$(t done "$LOG")"