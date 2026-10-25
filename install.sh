#!/usr/bin/env bash
# Link the dotfiles packages (global/, umbriel/) into $HOME with GNU stow.
# Config only: no package installs, no services, no chsh.
set -euo pipefail

SRC="${BASH_SOURCE[0]:-}"
REPO=""
[[ -n $SRC ]] && REPO="$(cd "$(dirname "$SRC")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
REPO_URL="https://github.com/szmaou/dotfiles.git"

# Run through curl (script alone, no repo around it): clone, then re-exec.
if [[ -z $REPO || ! -d "$REPO/global/.config" ]]; then
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
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/.dotfiles-backup"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-link.log"

# ── i18n ────────────────────────────────────────────────────────────────────
declare -A MSG_EN=(
  [usage]='usage: ./install.sh [options]

  --lang=en|id            language, default en
  --only=global,umbriel   limit to these packages (default: both)
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
)
declare -A MSG_ID=(
  [usage]='penggunaan: ./install.sh [opsi]

  --lang=en|id            bahasa, default en
  --only=global,umbriel   batasi ke paket ini (default: keduanya)
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

# True when a keyboard can be read, even under `curl | bash` (stdin = pipe).
have_tty() { [[ -t 0 ]] || { : < /dev/tty; } 2>/dev/null; }

choose_language() {
  [[ -n $LANG_CODE ]] && return
  if (( ! YES )) && have_tty && command -v whiptail >/dev/null; then
    local pick
    pick=$(whiptail --title "$(t lang_title)" --menu "$(t lang_prompt)" 12 60 2 \
      en "English" \
      id "Indonesian" \
      </dev/tty 3>&1 1>&2 2>&3) || pick=""
    [[ $pick == id ]] && LANG_CODE=id
  elif (( ! YES )) && have_tty; then
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

  if (( ! YES )) && have_tty && command -v whiptail >/dev/null; then
    local out
    out=$(whiptail --title "$(t pick_title)" --checklist --separate-output \
      "$(t pick_prompt)" 18 84 6 \
      global "$(t desc_global)" ON \
      umbriel "$(t desc_umbriel)" ON \
      </dev/tty 3>&1 1>&2 2>&3) || die "$(t err_cancel)"
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
