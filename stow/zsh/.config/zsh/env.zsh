# Environment variables and PATH modifications

# Default editor for git, `crontab -e`, `fc`, etc. zsh also inspects
# $EDITOR at startup: because "nvim" contains "vi" it switches line
# editing to the vi keymap - init.zsh pins `bindkey -e` to keep emacs
# keys on the command line regardless.
export EDITOR=nvim
export VISUAL=nvim

# lazygit on macOS otherwise reads ~/Library/Application Support/lazygit;
# point it at the stow-managed config instead.
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

export PATH="/Users/lrs/.local/bin:$PATH"

# Bun global installs (e.g. `bun add -g`, used for firecrawl-cli)
export PATH="$HOME/.bun/bin:$PATH"

# npm-only tools nix-darwin installs (pi, playwright-cli - see
# darwin/packages.nix's activation script)
export PATH="$HOME/.npm-global/bin:$PATH"

# API keys, looked up live from macOS Keychain at shell startup - see
# secrets.zsh and functions.zsh's secret-add/secret-rm/secret-list
[[ -f "$ZDOTDIR_CONFIG/secrets.zsh" ]] && source "$ZDOTDIR_CONFIG/secrets.zsh"

# /usr/libexec/java_home only scans macOS's native locations
# (/Library/Java/JavaVirtualMachines), not a Nix-provided JDK, so derive
# JAVA_HOME from `java` on $PATH instead.
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
