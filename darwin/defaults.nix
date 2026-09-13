{ config, ... }:

let
  user = config.system.primaryUser;
  homeDir = "/Users/${user}";
  themeName = "Vira-Theme-Carbon";
  # Not a nix path literal: the file lives in the private dotfiles-vira
  # repo, outside this flake's source tree, so it must stay a plain
  # string (a nix path would try to copy it into the store at eval time).
  themeFile = "${homeDir}/Developer/repos/dotfiles-vira/darwin/Vira-Theme-Carbon.terminal";
  terminalPlist = "${homeDir}/Library/Preferences/com.apple.Terminal.plist";
in
{
  # Two `defaults write` calls. CustomUserPreferences targets the
  # primary user without extra context.
  system.defaults.CustomUserPreferences."com.apple.Terminal" = {
    "Default Window Settings" = themeName;
    "Startup Window Settings" = themeName;
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
  '';
}
