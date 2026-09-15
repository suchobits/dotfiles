{
  # programs.mas rather than homebrew.masApps: it skips gracefully when
  # not signed in, where homebrew.masApps hangs, and its `mas` binary
  # comes from nixpkgs.
  programs.mas = {
    enable = true;

    # Uninstalls anything installed but not declared, like homebrew zap.
    cleanup = true;

    packages = {
      CleanMyMac = 1339170533;
      Noir = 1592917505;
      Developer = 640199958;
      Keynote = 361285480;
      Numbers = 361304891;
      Pages = 361309726;
      Scrivener3 = 1310686187;
      Amphetamine = 937984704;

      # mas can never install/update these - SIP blocks writes into an
      # installed MAS app's bundle even as root (verified directly).
      # Declared anyway so `cleanup` won't remove them; the failed
      # install attempt below is harmless (`|| true`) every switch.
      TestFlight = 899247664;
      Xcode = 497799835;
    };
  };

  # WhatsApp is a cask instead (see homebrew.nix); MAS id is 310633997.
  # `cleanup` cannot remove a MAS app macOS protects; those are removed
  # manually via Finder or Launchpad.
}
