#!/usr/bin/env bash
#
# One-time setup for a new Mac. Chains the steps documented in README.md's
# "New machine setup": Xcode CLT, Homebrew, Nix, the first darwin-rebuild
# switch, and stow. Safe to re-run - each step skips if already done.
#
# Must run from a clone of this repo at ~/Developer/repos/dotfiles: that
# exact path is hardcoded elsewhere (secrets.zsh's _secrets_file, this
# repo's own docs), so a different clone location would silently break them.
set -euo pipefail

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPECTED_DIR="$HOME/Developer/repos/dotfiles"
if [ "$REPO_DIR" != "$EXPECTED_DIR" ]; then
  echo "This repo must be cloned to $EXPECTED_DIR (found: $REPO_DIR)." >&2
  exit 1
fi

# --- Xcode Command Line Tools (git, cc; needed before Homebrew or Nix) ---
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "Finish the Command Line Tools install (GUI dialog), then re-run this script." >&2
  exit 1
fi

# --- Homebrew ---
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Nix (official multi-user installer, matches this machine's install) ---
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix"
  sh <(curl -L https://nixos.org/nix/install) --daemon
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# --- First darwin-rebuild switch ---
# Flakes only see git-tracked files.
git -C "$REPO_DIR" add -A

log "Running darwin-rebuild switch"
if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo darwin-rebuild switch --flake "$REPO_DIR#MBP"
else
  # darwin-rebuild doesn't exist on PATH yet on a fresh machine.
  sudo nix run --extra-experimental-features 'nix-command flakes' \
    nix-darwin/master#darwin-rebuild -- switch --flake "$REPO_DIR#MBP"
fi

# --- Stow ---
export PATH="/run/current-system/sw/bin:$PATH"
log "Stowing dotfiles"
(cd "$REPO_DIR/stow" && stow -t "$HOME" */)

cat <<EOF

Done. Remaining steps this script can't do for you:

  - Secrets: restart your shell, then run 'secret-add NAME' for each name
    'secret-list' prints (values live only in Keychain, never in git).
  - Theme: clone the private dotfiles-vira repo to
    ~/Developer/repos/dotfiles-vira (needs GitHub auth - 'gh auth login'
    after this script installs gh, or an existing SSH key). nvim/ghostty/
    starship/tmux pick it up on next launch; Terminal.app needs one more
    'sudo darwin-rebuild switch --flake $REPO_DIR#MBP'.
  - Mac App Store apps install only once you're signed into the App Store app;
    sign in, then re-run: sudo darwin-rebuild switch --flake $REPO_DIR#MBP
  - Manually installed apps (no cask/MAS entry) - see darwin/README.md's
    "Manually installed apps" table.
  - Some launchd agents (e.g. skhd) need a re-login to load - see
    darwin/README.md Notes.
EOF
