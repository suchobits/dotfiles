{
  # Homebrew for GUI apps (casks) and CLI tools that need to track
  # upstream faster than nixpkgs (brews).
  homebrew = {
    enable = true;

    # Uninstalls, with data, anything installed but not declared below,
    # on every switch.
    onActivation.cleanup = "zap";

    # No --force: it is only needed to adopt a pre-existing app at a
    # different version. Left on, it would let Homebrew revert a
    # self-updated app to its cached version. Without it, a mismatch
    # errors on that one cask.

    # xcodes: nixpkgs lags (1.6.2 vs 2.0.3+) and the gap matters here -
    # Apple periodically changes its sign-in backend, and only current
    # xcodes releases speak to it. An outdated client fails auth with a
    # JSON decode error instead of a clear version message.
    brews = [ "xcodes" ];

    casks = [
      "android-studio"
      "antigravity-cli" # `agy` CLI
      "apidog"
      "autodesk-fusion"
      "bambu-studio"
      "capacities"
      "chatgpt"
      "claude"
      "devin-cli"
      "discord"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "freecad"
      "gcloud-cli" # was google-cloud-sdk, renamed upstream
      "ghostty"
      "google-chrome"
      "kicad"
      "logi-options+" # renamed from logi-options-plus
      "obsidian"
      "orbstack"
      "protonvpn"
      "raycast"
      "tailscale-app" # was tailscale, renamed upstream
      "visual-studio-code"
      "vlc"
      "whatsapp" # also nixpkgs whatsapp-for-mac (lags) and MAS 310633997
      "zoom"
    ];
  };
}
