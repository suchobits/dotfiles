{ config, pkgs, ... }:

let
  user = config.system.primaryUser;
  homeDir = "/Users/${user}";

  # JetBrains kotlin-lsp: not in nixpkgs, and homebrew.nix is casks-only,
  # so pin the CDN bundle by SHA-256, unpack under ~/.local/share, symlink
  # onto $PATH. nvim's `kotlin_lsp` server points at it
  # (stow/nvim/.config/nvim/lua/plugins/kotlin.lua).
  #
  # BUMP ~monthly: `intellij-server` is an EAP build that stops running
  # ~30 days after release ("This build ... has expired"). Set `version`
  # and `sha256` from the newest tag + its macOS-arm64 checksum at
  # https://github.com/Kotlin/kotlin-lsp/releases.
  version = "263.4702.0";
  sha256 = "95da3fc6d3b9092c7616345044a05edb85e5408dc648d081e4e433595c892bec";
  url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.sit";

  # curl/shasum/ditto are macOS built-ins. The .sit is a plain zip that
  # unpacks to one kotlin-server-<ver>/ dir; bin/intellij-server is the
  # entrypoint. Runs as the user (activation is root; paths are in $HOME).
  install = pkgs.writeShellScript "install-kotlin-lsp" ''
    set -euo pipefail

    optdir="${homeDir}/.local/share/kotlin-lsp"
    dest="$optdir/kotlin-server-${version}"
    target="$dest/bin/intellij-server"
    link="${homeDir}/.local/bin/kotlin-lsp"

    # Already at the pinned version: skip the ~370MB fetch.
    if [ -x "$target" ] && [ "$(readlink "$link" 2>/dev/null || true)" = "$target" ]; then
      exit 0
    fi

    echo "installing kotlin-lsp ${version}..." >&2
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT

    /usr/bin/curl -fsSL -o "$tmp/kls.zip" "${url}"
    echo "${sha256}  $tmp/kls.zip" | /usr/bin/shasum -a 256 -c - >&2

    mkdir -p "$optdir" "${homeDir}/.local/bin"
    rm -rf "$dest"
    /usr/bin/ditto -x -k "$tmp/kls.zip" "$optdir"
    chmod +x "$target"
    ln -sfn "$target" "$link"

    # Drop superseded versions.
    find "$optdir" -mindepth 1 -maxdepth 1 -type d ! -name "kotlin-server-${version}" -exec rm -rf {} +
    echo "kotlin-lsp ${version} installed" >&2
  '';
in
{
  # Non-fatal: optional tooling, and the pinned build may be expired
  # upstream - a failure should not abort the switch.
  system.activationScripts.postActivation.text = ''
    echo "checking kotlin-lsp (${version})..." >&2
    sudo --set-home -u ${user} ${install} \
      || echo "WARNING: kotlin-lsp install failed; will retry on next switch" >&2
  '';
}
