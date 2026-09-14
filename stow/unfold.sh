#!/usr/bin/env bash
#
# One-time repair for stow packages that got "folded" into a whole-
# directory symlink instead of linking their tracked files individually
# (see bootstrap.sh's mkdir loop for why - this fixes machines that were
# bootstrapped before that guard existed). Idempotent and safe to re-run:
# packages already in the correct state are left untouched.
#
# Usage: ~/Developer/repos/dotfiles/stow/unfold.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$REPO_DIR/stow"

# package:target-relative-to-$HOME, matching bootstrap.sh's guard list.
TARGETS=(
  "claude:.claude"
  "ghostty:.config/ghostty"
  "herdr:.config/herdr"
  "lazygit:.config/lazygit"
  "nvim:.config/nvim"
  "sesh:.config/sesh"
  "skhd:.config/skhd"
  "television:.config/television"
  "zsh:.config/zsh"
)

fixed_any=0

for entry in "${TARGETS[@]}"; do
  pkg="${entry%%:*}"
  rel="${entry#*:}"
  target="$HOME/$rel"
  source="$STOW_DIR/$pkg/$rel"

  # A correctly-stowed package has $target as a real directory containing
  # per-file symlinks. A folded one has $target itself as a symlink.
  [ -L "$target" ] || continue

  case "$(readlink "$target")" in
    *"stow/$pkg/$rel"*) ;;
    *)
      echo "skipping $pkg: $target is a symlink but doesn't point into this repo, leaving it alone" >&2
      continue
      ;;
  esac

  echo "fixing folded package: $pkg ($rel)"
  fixed_any=1

  tracked=$(git -C "$REPO_DIR" ls-tree -r HEAD --name-only -- "stow/$pkg/$rel" | sed "s|^stow/$pkg/$rel/||")

  stow -D -d "$STOW_DIR" -t "$HOME" "$pkg"
  mv "$source" "$target"
  mkdir -p "$source"

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    mkdir -p "$(dirname "$source/$f")"
    mv "$target/$f" "$source/$f"
  done <<<"$tracked"

  stow -d "$STOW_DIR" -t "$HOME" "$pkg"
done

if [ "$fixed_any" = 0 ]; then
  echo "nothing to fix - no packages are folded"
fi

echo
echo "git status:"
git -C "$REPO_DIR" status --short
