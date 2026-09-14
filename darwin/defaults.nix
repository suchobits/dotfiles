{ config, pkgs, ... }:

let
  user = config.system.primaryUser;
  homeDir = "/Users/${user}";
  themeName = "Vira-Theme-Carbon";
  # Not a nix path literal: the file lives in the private dotfiles-vira
  # repo, outside this flake's source tree, so it must stay a plain
  # string (a nix path would try to copy it into the store at eval time).
  themeFile = "${homeDir}/Developer/repos/dotfiles-vira/darwin/Vira-Theme-Carbon.terminal";
  terminalPlist = "${homeDir}/Library/Preferences/com.apple.Terminal.plist";
  # A nix path literal on purpose: this file lives in this (public) repo,
  # so it should be copied into the store and stay reproducible on a
  # fresh clone with no manual step.
  wallpaper = ./resources/night-watch.png;
in
{
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # Two `defaults write` calls. CustomUserPreferences targets the
  # primary user without extra context.
  system.defaults.CustomUserPreferences."com.apple.Terminal" = {
    "Default Window Settings" = themeName;
    "Startup Window Settings" = themeName;
  };

  # macOS 26 Liquid Glass "Clear" icon & widget style (System Settings >
  # Appearance). Too new for a typed nix-darwin option; these are the raw
  # NSGlobalDomain keys, read back from a machine with the setting applied.
  system.defaults.CustomUserPreferences."NSGlobalDomain" = {
    AppleIconAppearanceTheme = "ClearDark";
    AppleIconAppearanceTintColor = "Graphite";
    NSGlassDiffusionSetting = 0;
  };

  system.defaults.dock = {
    orientation = "bottom";
    tilesize = 51;
    autohide = false;
    magnification = false;
    persistent-apps = [
      { app = "/System/Applications/Apps.app"; }
      { app = "/Applications/Google Chrome.app"; }
      { app = "/System/Applications/Mail.app"; }
      { app = "/Applications/Visual Studio Code.app"; }
      { app = "/Applications/Xcode.app"; }
      { app = "/Applications/Android Studio.app"; }
      { app = "/Applications/Capacities.app"; }
      { app = "/Applications/Ghostty.app"; }
      { app = "/System/Applications/System Settings.app"; }
    ];
  };

  # CustomUserPreferences cannot merge a plist fragment into a nested key
  # the way PlistBuddy's Merge can, so the theme dict needs a script.
  # Activation runs as root, so the commands set an explicit user context.
  #
  # The dict is deleted before re-adding: PlistBuddy's Merge skips every
  # key already present (logging "Duplicate Entry Was Skipped") and would
  # ignore later edits to ${themeName}.terminal. Delete on a missing
  # entry exits non-zero, hence the `|| true`.
  #
  # Merge itself is also `|| true`: ${themeFile} lives in the private
  # dotfiles-vira repo, which a fresh machine hasn't cloned yet. A missing
  # file shouldn't fail the whole switch - clone dotfiles-vira and switch
  # again to pick up the theme.
  system.activationScripts.postActivation.text = ''
    echo "installing Terminal theme..." >&2
    sudo --set-home -u ${user} /usr/libexec/PlistBuddy \
      -c "Delete :'Window Settings':'${themeName}'" "${terminalPlist}" 2>/dev/null || true
    sudo --set-home -u ${user} /usr/libexec/PlistBuddy \
      -c "Add :'Window Settings':'${themeName}' dict" "${terminalPlist}"
    sudo --set-home -u ${user} /usr/libexec/PlistBuddy \
      -c "Merge ${themeFile} :'Window Settings':'${themeName}'" "${terminalPlist}" || true
    killall cfprefsd 2>/dev/null || true

    # desktoppr talks to the user's WindowServer session to change the
    # live picture, so it needs the GUI bootstrap context - plain `sudo
    # -u` isn't enough, hence launchctl asuser (same pattern nix-darwin
    # itself uses to restart the Dock after a `system.defaults.dock`
    # change).
    echo "setting desktop wallpaper..." >&2
    launchctl asuser "$(id -u ${user})" sudo -u ${user} \
      ${pkgs.desktoppr}/bin/desktoppr "${wallpaper}"

    # Finder and SystemUIServer render app/folder icons; killall (as
    # root) can signal them without needing the GUI bootstrap context
    # that launching one would.
    killall Finder SystemUIServer 2>/dev/null || true
  '';
}
