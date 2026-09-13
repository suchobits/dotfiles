#!/usr/bin/env bash
#
# Entry point for a brand-new Mac:
#   curl -fsSL https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh | bash
#
# Clones this repo to ~/Developer/repos/dotfiles, then hands off to
# bootstrap.sh. Requires Xcode Command Line Tools already installed
# (xcode-select --install) - needed for git, and its GUI install can't
# be driven from a piped script.
set -euo pipefail

REPO_URL="https://github.com/suchobits/dotfiles.git"
REPO_DIR="$HOME/Developer/repos/dotfiles"

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install Xcode Command Line Tools first: xcode-select --install" >&2
  exit 1
fi

if [ -d "$REPO_DIR" ]; then
  echo "$REPO_DIR already exists, skipping clone"
else
  git clone "$REPO_URL" "$REPO_DIR"
fi

exec "$REPO_DIR/bootstrap.sh"
