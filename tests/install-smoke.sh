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

left=$(find "$tmp" -mindepth 1 | head -5)
[[ -z $left ]] || { printf 'FAIL: dry-run menulis file:\n%s\n' "$left" >&2; exit 1; }

# dry-run dengan --only harus membatasi paket
out=$(HOME="$tmp" "$REPO/install.sh" --dry-run --yes --only=global 2>&1) || {
  printf 'FAIL: --only=global exit != 0\n' >&2
  exit 1
}
[[ $out != *"== umbriel"* ]] || { printf 'FAIL: --only=global masih menyentuh umbriel\n' >&2; exit 1; }

printf 'ok\n'
