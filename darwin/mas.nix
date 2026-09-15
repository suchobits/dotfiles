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

      # mas can never install/update this - SIP blocks writes into an
      # installed MAS app's bundle even as root (verified directly).
      # Declared anyway so `cleanup` won't remove it; the install attempt
      # below is skipped every switch since `mas list` already shows it.
      TestFlight = 899247664;
    };
  };

  # WhatsApp is a cask instead (see homebrew.nix); MAS id is 310633997.
  # `cleanup` cannot remove a MAS app macOS protects; those are removed
  # manually via Finder or Launchpad.

  # Xcode (497799835): same SIP block as TestFlight, but mas never gets a
  # receipt for it, so it's never "already installed" and declaring it
  # would redownload the full ~3GB every switch, forever. Left undeclared;
  # updates via macOS's own background App Store updater instead.
}
