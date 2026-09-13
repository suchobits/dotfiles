# dotfiles

- [nix-darwin](https://github.com/nix-darwin/nix-darwin) manages packages, GUI apps,
system settings, and launchd agents.
- [GNU Stow](https://www.gnu.org/software/stow/) manages dotfiles.

## Layout

| Path | Contents |
| --- | --- |
| `flake.nix` | Flake entry point; `darwinConfigurations."MBP"` |
| `install.sh` | New-machine entry point - see below |
| `bootstrap.sh` | New-machine setup, called by `install.sh` |
| `darwin/` | nix-darwin modules - see [darwin/README.md](darwin/README.md) |
| `stow/` | Stow packages, one per tool - see [stow/README.md](stow/README.md) |

## New machine setup

1. Name the account `lrs` (`darwin/configuration.nix` hardcodes it) and install Xcode Command Line Tools: `xcode-select --install`.
   Needed for `git`, which the next step requires.
2. `curl -fsSL https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh | bash`.
   Clones this repo to `~/Developer/repos/dotfiles` - that exact path is hardcoded elsewhere (Keychain secret lookup) - then runs `bootstrap.sh`: installs Homebrew and Nix if missing, runs the first `darwin-rebuild switch`, then stows everything.
   Re-run `~/Developer/repos/dotfiles/bootstrap.sh` if it stops partway; each step skips once done.
3. Follow the checklist `bootstrap.sh` prints at the end: re-add Keychain secrets, sign into the Mac App Store, and reinstall the handful of apps with no cask/MAS entry (`darwin/README.md`).

## Design

- nix-darwin only, no home-manager.
  One `nixpkgs` input, one `flake.lock`.
  Cross-machine sharing is a non-goal, and mixing in home-manager without `inputs.nixpkgs.follows` pulls a second `nixpkgs` copy ([Discourse](https://discourse.nixos.org/t/home-manager-complaining-about-nixpkgs-version-mismatch/28569)).
- nix-darwin owns packages (`environment.systemPackages`), GUI apps (`homebrew` module, a declarative wrapper over `brew`), macOS settings (`system.defaults`), and launchd agents (`launchd.agents`).
- Stow owns dotfiles, with no connection to Nix: no `mkOutOfStoreSymlink`, no shared state.
