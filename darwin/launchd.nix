{ config, lib, ... }:

let
  homeDir = "/Users/${config.system.primaryUser}";
  logPath = "${homeDir}/Library/Logs/prune-agent-state.log";
in
{
  # Prunes agent session and cache state daily. See scripts/ for scope.
  launchd.agents.prune-agent-state = {
    serviceConfig = {
      ProgramArguments = [ "/bin/bash" "${./scripts/prune-agent-state.sh}" ];
      StartCalendarInterval = [
        { Hour = 9; Minute = 0; }
      ];
      RunAtLoad = false;
      StandardOutPath = logPath;
      StandardErrorPath = logPath;
    };
  };

  # nix-darwin writes each agent's plist, but a new agent does not load
  # until reboot/login. postActivation runs last and bootstraps any
  # agent not yet loaded; it loops over all agents, so new ones need no
  # change here.
  system.activationScripts.postActivation.text = lib.concatMapStringsSep "\n"
    (name: ''
      if ! launchctl print "gui/$(id -u ${config.system.primaryUser})/org.nixos.${name}" >/dev/null 2>&1; then
        echo "bootstrapping launchd agent org.nixos.${name}..." >&2
        launchctl bootstrap "gui/$(id -u ${config.system.primaryUser})" "/Library/LaunchAgents/org.nixos.${name}.plist"
      fi
    '')
    (builtins.attrNames config.launchd.agents);
}
