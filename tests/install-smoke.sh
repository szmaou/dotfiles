#!/usr/bin/env bash
# Self-check for install.sh: dry-run must touch nothing and must plan stow.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

out=$(HOME="$tmp" XDG_STATE_HOME="$tmp/state" "$REPO/install.sh" --dry-run --yes 2>&1) || {
  printf 'FAIL: dry-run exit != 0\n%s\n' "$out" >&2
  exit 1
}

[[ $out == *"stow"* ]] || { printf 'FAIL: tidak ada rencana stow\n%s\n' "$out" >&2; exit 1; }
[[ $out == *"global"* && $out == *"umbriel"* ]] || { printf 'FAIL: paket tidak terdeteksi\n' >&2; exit 1; }
[[ $out != *"== hyprland"* ]] || { printf 'FAIL: hyprland ikut terpilih secara default\n' >&2; exit 1; }

left=$(find "$tmp" -mindepth 1 | head -5)
[[ -z $left ]] || { printf 'FAIL: dry-run menulis file:\n%s\n' "$left" >&2; exit 1; }

# dry-run dengan --only harus membatasi paket
out=$(HOME="$tmp" "$REPO/install.sh" --dry-run --yes --only=global 2>&1) || {
  printf 'FAIL: --only=global exit != 0\n' >&2
  exit 1
}
[[ $out != *"== umbriel"* ]] || { printf 'FAIL: --only=global masih menyentuh umbriel\n' >&2; exit 1; }

# hyprland: boleh sendiri, ditolak saat bersama umbriel
out=$(HOME="$tmp" "$REPO/install.sh" --dry-run --yes --only=hyprland 2>&1) || {
  printf 'FAIL: --only=hyprland exit != 0\n' >&2
  exit 1
}
[[ $out == *"== hyprland"* ]] || { printf 'FAIL: --only=hyprland tidak merencanakan stow\n' >&2; exit 1; }

if HOME="$tmp" "$REPO/install.sh" --dry-run --yes --only=umbriel,hyprland >/dev/null 2>&1; then
  printf 'FAIL: umbriel+hyprland seharusnya ditolak\n' >&2
  exit 1
fi

# kompositor lain yang masih ter-stow harus dilepas dulu
mkdir -p "$tmp/.config/fish/conf.d"
ln -s "$REPO/umbriel/.config/fish/conf.d/autostart.fish" "$tmp/.config/fish/conf.d/autostart.fish"
if HOME="$tmp" "$REPO/install.sh" --dry-run --yes --only=hyprland >/dev/null 2>&1; then
  printf 'FAIL: hyprland seharusnya menolak saat umbriel masih ter-stow\n' >&2
  exit 1
fi
rm "$tmp/.config/fish/conf.d/autostart.fish"

printf 'ok\n'
