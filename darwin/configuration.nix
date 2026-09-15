{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./homebrew.nix
    ./mas.nix
    ./defaults.nix
    ./launchd.nix
    ./zsh.nix
    ./kotlin-lsp.nix
    ./xcode-build-server.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # tart is the only unfree package. Named explicitly so future unfree
  # additions stay a deliberate choice.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [ "tart" ];

  # Flakes and the unified CLI.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Must match an existing account - otherwise, nix-darwin refuses to activate.
  system.primaryUser = "lrs";

  # Touch ID for sudo, including `darwin-rebuild switch`. `reattach`
  # keeps it working inside tmux.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # nix-darwin state format version. Read `darwin-rebuild changelog`
  # before changing.
  system.stateVersion = 7;
}
