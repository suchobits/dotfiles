{ pkgs, ... }:

{
  # Simple hotkey daemon for macOS. The module defines its own user
  # launchd agent (org.nixos.skhd), so this needs no entry in
  # launchd.nix.
  #
  # skhdConfig is left unset: the module then starts skhd without a `-c`
  # flag, so it falls back to its own lookup and reads
  # ~/.config/skhd/skhdrc, stowed from stow/skhd/ like the other
  # dotfiles. (The module still writes an unused empty /etc/skhdrc.)
  #
  # Accessibility permission: see darwin/README.md "Notes".
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
  };
}
