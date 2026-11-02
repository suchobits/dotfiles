{ config, pkgs, ... }:

let
  mas = "${pkgs.mas}/bin/mas";

  # name = id; names are for readability only.
  apps = {
    CleanMyMac = 1339170533;
    Noir = 1592917505;
    Developer = 640199958;
    Keynote = 361285480;
    Numbers = 361304891;
    Pages = 361309726;
    Scrivener3 = 1310686187;
    Amphetamine = 937984704;
    Ghostery = 6504861501;

    # SIP blocks writes into an installed MAS app's bundle even as root,
    # so mas never updates it. Declared so cleanup keeps it.
    TestFlight = 899247664;
  };

  ids = builtins.concatStringsSep " " (map toString (builtins.attrValues apps));

  # programs.mas runs mas as the user, but mas 7 needs root to install,
  # get, update and uninstall, and fails silently (`|| true`). Activation
  # is already root, so run mas directly.
  script = pkgs.writeShellScript "mas-sync" ''
    set -uo pipefail
    desired=(${ids})

    listing="$(${mas} list)" || { echo "mas list failed" >&2; exit 1; }
    installed=()
    while read -r id _; do
      [[ "$id" =~ ^[0-9]+$ ]] && installed+=("$id")
    done <<<"$listing"

    has() { local x; for x in "''${@:2}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

    ${mas} update

    # `install` only works for apps already gotten; `get` fetches new free ones.
    for id in "''${desired[@]}"; do
      has "$id" "''${installed[@]}" && continue
      ${mas} install "$id" || ${mas} get "$id" || echo "could not install $id" >&2
    done

    # An empty listing means mas is broken, not that nothing is installed.
    [ "''${#installed[@]}" -gt 0 ] || exit 0
    for id in "''${installed[@]}"; do
      has "$id" "''${desired[@]}" && continue
      echo "removing $id from App Store" >&2
      ${mas} uninstall "$id" || echo "could not remove $id" >&2
    done
  '';
in
{
  environment.systemPackages = [ pkgs.mas ];

  # Non-fatal: App Store state should not abort the switch.
  system.activationScripts.postActivation.text = ''
    echo "setting up App Store apps (mas)..." >&2
    # mas resolves the App Store user from SUDO_UID/SUDO_GID, which
    # activation's environment does not carry.
    SUDO_UID="$(id -u ${config.system.primaryUser})" \
      SUDO_GID="$(id -g ${config.system.primaryUser})" \
      ${script} || echo "WARNING: mas sync failed" >&2
  '';
}
