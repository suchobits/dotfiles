# darwin

nix-darwin system configuration: packages, Homebrew casks, Mac App Store apps, macOS settings, launchd agents.
Applied with `darwin-rebuild`.
Dotfiles are separate - see [../stow/README.md](../stow/README.md).

## Files

| File | Purpose |
| --- | --- |
| `configuration.nix` | Entry point: host platform, unfree allowlist, `stateVersion`, imports |
| `packages.nix` | CLI tools (`environment.systemPackages`), plus npm-only tools via activation script |
| `homebrew.nix` | GUI apps (`homebrew.casks`) |
| `mas.nix` | Mac App Store apps (`programs.mas`) |
| `defaults.nix` | macOS settings (`system.defaults`): dark mode, icon/widget style, Dock; Terminal theme and desktop wallpaper via activation script |
| `launchd.nix` | Scheduled jobs (`launchd.agents`) |
| `skhd.nix` | Hotkey daemon (`services.skhd`); bindings stowed from `stow/skhd/` |
| `kotlin-lsp.nix` | Pinned JetBrains kotlin-lsp download via activation script (not in nixpkgs, not a cask) |
| `xcode-build-server.nix` | Pinned git checkout of xcode-build-server via activation script (not in nixpkgs, not a cask) |
| `resources/` | Assets referenced above |
| `scripts/` | Scripts run by `launchd.agents` |

## Commands

Flake reference: `~/Developer/repos/dotfiles#MBP`, usable from any directory.

Flakes only see git-tracked files.
Stage everything before building or switching; untracked files surface as missing-file errors.

```sh
git add -A
```

Build - no activation, no `sudo`, no change to the live system; leaves a gitignored `result` symlink:

```sh
darwin-rebuild build --flake ~/Developer/repos/dotfiles#MBP
```

Activate - writes `/etc`, `/Library`, and launchd, and runs `brew` and `mas`:

```sh
sudo MAS_NO_AUTO_INDEX=1 darwin-rebuild switch --flake ~/Developer/repos/dotfiles#MBP
```

`MAS_NO_AUTO_INDEX=1` stops `mas`'s own Spotlight-reindex diagnostic text (printed right after installing a large app not yet indexed, e.g. Xcode) from bleeding into nix-darwin's `programs.mas` cleanup loop, which parses that same output for installed bundle IDs - without it, cleanup word-splits the diagnostic text into garbage IDs and harmlessly no-ops trying to "uninstall" each one.

Quit any GUI app whose cask is installing or updating first.
Homebrew cannot replace the files of a running app.

Rollback:

```sh
sudo darwin-rebuild --list-generations
sudo darwin-rebuild --rollback
```

Rollback re-points `/run/current-system` and is instant.
It does not undo a Homebrew zap, which is a filesystem deletion and needs a reinstall.

## Adding and removing

- **CLI tool**: confirm it is in nixpkgs (`nix eval nixpkgs#<name>.meta.description`), add to `packages.nix`.
  Unfree packages must be named in `configuration.nix`'s `allowUnfreePredicate`.
- **GUI app**: confirm it is a cask (`brew info --cask <name>`), add to `homebrew.nix`.
  An existing install at a different version errors instead of overwriting; quit and delete the old copy, then switch again.
- **Mac App Store app**: find its numeric ID (`mas search <name>`, or the App Store URL), add to `mas.nix`.
- **Remove**: delete the line and switch.

`homebrew.onActivation.cleanup = "zap"` and `programs.mas.cleanup` uninstall anything installed but not declared, with its data, on every switch, without confirmation.

App updates: casks with `auto_updates: true` update in-app.
Nix CLI tools update as a set via `nix flake update` then `switch`.
MAS apps self-update via `programs.mas.update`.

## Manually installed apps

These GUI apps have no cask and are not on the Mac App Store.
Reinstall them by hand after a fresh setup; `zap` leaves them alone since they live outside Homebrew.

| App | Source |
| --- | --- |
| oMLX | <https://github.com/jundot/omlx> |
| Pencil (`Pen.app`) | <https://www.pen.dev> |
| ZMK Studio | <https://zmk.studio> (also runs in-browser) |
| Python 3.14 | python.org installer, kept outside Nix on purpose |
| InjectionNext | <https://github.com/johnno1962/InjectionNext> |


## Notes

- `system.activationScripts.<name>` runs only for the names `preActivation`, `extraActivation`, and `postActivation`.
  Any other name is accepted by the option type and never executed, with no error or warning ([nix-darwin#663](https://github.com/nix-darwin/nix-darwin/issues/663)).
  Multiple files may set the same one; their `.text` values concatenate.
- `homebrew.nix` sets no `--force`.
  A version mismatch then errors on the one cask instead of letting Homebrew revert a self-updated app to its cached version.
- `allowUnfreePredicate` names each unfree package (`tart`); blanket `allowUnfree` would hide later additions.
- A self-updating tool outside Nix (e.g. Claude Code at `~/.local/bin/claude`) shadows a Nix copy when its directory precedes the Nix profile on `$PATH`.
- `/usr/libexec/java_home` does not detect Nix JDKs; `JAVA_HOME` derives from `java` on `$PATH` (`stow/zsh/.config/zsh/env.zsh`).
- `kotlin-lsp.nix` pins a CDN bundle by SHA-256, unpacks it to `~/.local/share/kotlin-lsp`, and symlinks `~/.local/bin/kotlin-lsp`.
  Its `intellij-server` EAP build expires ~monthly and needs a `version` bump (see the file).
  The install step is non-fatal: a failed download or checksum warns and retries on the next switch instead of aborting activation.
- `xcode-build-server.nix` pins a git checkout (`rev`) to `~/.local/share/xcode-build-server`; `~/.local/bin/xcode-build-server` is a wrapper that runs it under `/usr/bin/python3` (system python, not whatever is first on `$PATH`).
  It is the BSP bridge so sourcekit-lsp understands an xcodeproj; pure stdlib, no deps, stable, so `rev` rarely needs bumping. Also non-fatal.
- Swift tooling (`swiftformat`, `swiftlint`, `xcbeautify` in `packages.nix`) is for the Neovim iOS setup (`stow/nvim/.config/nvim/lua/plugins/swift.lua`).
- Nix tooling (`nil`, `nixfmt`, `statix` in `packages.nix`) backs Neovim's `lang.nix` extra (LSP / conform format-on-save / nvim-lint); the extra installs none of them itself.
- `system.stateVersion` tracks nix-darwin's state format; read `darwin-rebuild changelog` before changing it.
- `launchd.agents.<name>` writes `/Library/LaunchAgents/org.nixos.<name>.plist`.
  A new agent does not load until reboot/login; `launchd.nix`'s `postActivation` script bootstraps unloaded agents on every switch.
  Replacing a hand-managed agent still requires removing the old plist and script manually.
- `skhd.nix` sets `services.skhd`; bindings are in `stow/skhd/.config/skhd/skhdrc`.
  The module defines a user agent (`launchd.user.agents.skhd`), not covered by `launchd.nix`'s bootstrap loop; a fresh install may need a re-login to load.
  `skhdConfig` is left unset, so skhd runs without `-c` and reads `~/.config/skhd/skhdrc`; the module still writes an unused empty `/etc/skhdrc`.
  skhd needs Accessibility permission for `~/.local/bin/skhd`; without it, bound keys pass through as their raw keystroke.
  `skhd.nix` copies the binary there on every switch and points the agent at that fixed path instead of the store path, so the grant survives `pkgs.skhd` updates - the store path used to change per update, and macOS never cleaned up the stale per-path grant, so they piled up in Privacy & Security > Accessibility.
- Mac App Store apps cannot be removed by automation, including as root; macOS protects them.
  Remove via Finder or Launchpad.
- `defaults.nix`'s `AppleIconAppearanceTheme`/`AppleIconAppearanceTintColor`/`NSGlassDiffusionSetting` (macOS 26's Liquid Glass icon & widget style) have no typed nix-darwin option yet; they're raw `NSGlobalDomain` keys read back off a machine with the setting applied, set via `CustomUserPreferences`.
  A future nix-darwin release may add typed options that conflict with writing these directly.
- The desktop wallpaper (`darwin/resources/night-watch.png`) is applied via `desktoppr` (`packages.nix`) in `defaults.nix`'s `postActivation`, wrapped in `launchctl asuser` since changing the live picture needs the user's WindowServer session, not just `sudo -u`.
