{ config, pkgs, ... }:

let
  user = config.system.primaryUser;
  homeDir = "/Users/${user}";

  # xcode-build-server: the BSP bridge that lets sourcekit-lsp understand
  # an xcodeproj/xcworkspace. Not in nixpkgs, and homebrew.nix is
  # casks-only, so pin a git checkout under ~/.local/share. xcodebuild.nvim
  # runs it to generate buildServer.json
  # (stow/nvim/.config/nvim/lua/plugins/swift.lua).
  #
  # Pure stdlib, no deps, no build step. The $PATH entry is a wrapper that
  # pins the interpreter to macOS's system python3 (Apple-managed, matches
  # upstream's stated 3.9 requirement).
  #
  # Stable tool - bump `rev` from
  # https://github.com/SolaWing/xcode-build-server only if a fix is needed.
  rev = "438d0ae21778af955d7025d2013ebd419d161427";

  # git is a macOS built-in. Runs as the user (activation is root; paths
  # are in $HOME).
  install = pkgs.writeShellScript "install-xcode-build-server" ''
    set -euo pipefail

    dest="${homeDir}/.local/share/xcode-build-server"
    link="${homeDir}/.local/bin/xcode-build-server"

    if [ "$(/usr/bin/git -C "$dest" rev-parse HEAD 2>/dev/null || true)" = "${rev}" ] \
      && [ -x "$link" ]; then
      exit 0
    fi

    echo "installing xcode-build-server ${rev}..." >&2
    mkdir -p "${homeDir}/.local/share" "${homeDir}/.local/bin"
    if [ ! -d "$dest/.git" ]; then
      rm -rf "$dest"
      /usr/bin/git clone --quiet https://github.com/SolaWing/xcode-build-server.git "$dest"
    fi
    /usr/bin/git -C "$dest" fetch --quiet origin "${rev}" \
      || /usr/bin/git -C "$dest" fetch --quiet origin
    /usr/bin/git -C "$dest" checkout --quiet "${rev}"

    printf '#!/bin/sh\nexec /usr/bin/python3 "%s/xcode-build-server" "$@"\n' "$dest" > "$link"
    chmod +x "$link"
    echo "xcode-build-server ${rev} installed" >&2
  '';
in
{
  # Non-fatal: a network failure should not abort the switch.
  system.activationScripts.postActivation.text = ''
    echo "checking xcode-build-server..." >&2
    sudo --set-home -u ${user} ${install} \
      || echo "WARNING: xcode-build-server install failed; will retry on next switch" >&2
  '';
}
