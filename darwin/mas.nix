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
      Xcode = 497799835;
      Scrivener3 = 1310686187;
      Amphetamine = 937984704;

      # `mas`/`installer` can't install, upgrade, or uninstall this one -
      # "Operation not permitted" moving files into /Applications even as
      # root, a SIP-level restriction the App Store GUI client has but the
      # CLI path doesn't. Declared anyway so `cleanup` doesn't fight a
      # manually-installed copy on every switch; on a machine that doesn't
      # have it yet, the install attempt below just fails harmlessly
      # (`|| true`) until you install it by hand from the App Store app.
      TestFlight = 899247664;
    };
  };

  # WhatsApp is a cask instead (see homebrew.nix); MAS id is 310633997.
  # `cleanup` cannot remove a MAS app macOS protects; those are removed
  # manually via Finder or Launchpad.
}
