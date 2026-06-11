#!/bin/sh
# Bootstrap installer for chezmoi dotfiles
# Usage:
#   sh -c "$(curl -fsLS https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh)"
set -e

DOTFILES_REPO="suchobits/dotfiles"

# Install chezmoi, init, and apply in one shot
printf '==> Installing chezmoi and applying dotfiles...\n'
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$DOTFILES_REPO"

printf '\n==> Done!\n'
printf '    Run "chezmoi diff" to review or "chezmoi apply" to re-apply.\n'
