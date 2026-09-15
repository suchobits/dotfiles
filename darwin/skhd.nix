{ config, lib, pkgs, ... }:

let
  user = config.system.primaryUser;
  homeDir = "/Users/${user}";

  # The module's ProgramArguments defaults to the store path, which
  # changes every update; macOS grants Accessibility per-path, so each
  # update piles up a new, never-cleaned-up entry. Copy the binary here
  # instead so the granted path never changes.
  stableBin = "${homeDir}/.local/bin/skhd";

  # Nix's ad-hoc signature doesn't survive TCC revalidation (e.g. after a
  # macOS upgrade); re-sign with a real dev identity so the Accessibility
  # grant sticks. SHA-1 hash, not the display name, to keep a real name
  # out of this public repo.
  codesignIdentity = "9DC3C80CF8B91DD14E452584A6ABBBE1F6C446B7";
in
{
  # Own launchd agent (org.nixos.skhd); no entry needed in launchd.nix.
  # skhdConfig is left unset, so skhd reads ~/.config/skhd/skhdrc
  # (stow/skhd/) instead of the module's /etc/skhdrc.
  # Accessibility permission: see darwin/README.md "Notes".
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
  };

  # mkForce: a plain assignment would concatenate with, not replace, the
  # module's own ProgramArguments.
  launchd.user.agents.skhd.serviceConfig.ProgramArguments = lib.mkForce [ stableBin ];

  # preActivation: must land before userLaunchd reloads org.nixos.skhd,
  # or the first switch starts the agent against a missing file.
  system.activationScripts.preActivation.text = ''
    echo "installing skhd to stable path..." >&2
    sudo --set-home -u ${user} mkdir -p "${homeDir}/.local/bin"
    sudo --set-home -u ${user} install -m 755 ${pkgs.skhd}/bin/skhd "${stableBin}"
    sudo --set-home -u ${user} /usr/bin/codesign --force --sign ${codesignIdentity} "${stableBin}" \
      || echo "WARNING: skhd codesign failed; left with nix's ad-hoc signature (Accessibility grant may not survive the next reboot/upgrade)" >&2
  '';
}
