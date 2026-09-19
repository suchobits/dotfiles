# Stow

GNU Stow is a symlink farm manager.
Each subdirectory here is a "package" whose contents mirror where they belong under `$HOME`.
Running `stow` creates matching symlinks there, pointing back into this repo.
No templating, no hooks, no permissions - just symlinks.

Run stow from this directory, with an explicit target - the default target (this directory's parent) is the repo root, not `$HOME`:

```sh
cd ~/Developer/repos/dotfiles/stow
stow -t ~ <package>          # one package
stow -t ~ */                 # every package (the glob expands to each dir)
```

There are also shell shortcuts (from `zsh`'s `aliases.zsh`, so they work from any cwd):

| Alias | Does |
|---|---|
| `stn <pkg>` | dry-run restow one package (`stow -Rnv`) |
| `sts <pkg>` | restow one package |
| `sta` | restow **every** package |
| `std <pkg>` | unstow one package |

## What's here

| Package | Target |
|---|---|
| `herdr` | `~/.config/herdr/config.toml` |
| `tmux` | `~/.tmux.conf` |
| `sesh` | `~/.config/sesh/sesh.toml` |
| `git` | `~/.gitconfig`, `~/.config/git/ignore` |
| `starship` | `~/.config/starship.toml` |
| `ghostty` | `~/.config/ghostty/` |
| `nvim` | `~/.config/nvim/` |
| `television` | `~/.config/television/` |
| `lazygit` | `~/.config/lazygit/config.yml` (read via `$LG_CONFIG_FILE`, set in `zsh`) |
| `zsh` | `~/.zshrc`, `~/.config/zsh/` |
| `claude` | `~/.claude/CLAUDE.md` (global agent instructions; the rest of `~/.claude/` is machine-local state, left untracked) |
| `stow` | `~/.stow-global-ignore` |
| `ssh` | `~/.ssh/config` (includes `~/.ssh/config.local`, untracked, for actual hosts) |

`herdr` is the daily-driver terminal multiplexer; `tmux`/`sesh` config is kept for compatibility, not stowed by default.

`zsh`'s secrets are handled separately: `secrets.zsh` looks values up from macOS Keychain at shell startup rather than storing them, and `functions.zsh` has `secret-add`/`secret-rm`/`secret-list` to manage them.

The `stow` package installs `~/.stow-global-ignore`, which every restow consults so Finder's `.DS_Store` files (and other junk) inside a package never cause a conflict. That file **replaces** Stow's built-in default ignore list, so it also repeats the defaults worth keeping (`.git`, editor backups, `README`/`LICENSE` at a package root).

## Usage

**Add a new package** (a new tool's config):
```sh
mkdir -p stow/<name>/<path mirroring $HOME>
cp <source file> stow/<name>/<same path>
stow -n -v -t ~ <name>   # dry run first
stow -v -t ~ <name>
```
If a real file already exists at the target path, Stow refuses to overwrite it - remove/back it up first.

**Edit an existing dotfile**: just edit the file in `stow/<package>/...` directly (or via its symlink in `$HOME` - same file, either path works).
No restow needed for content changes.

**Add a new file to an existing package**: drop the file into the package directory, then restow:
```sh
stow -R -t ~ <package>
```
Needed because Stow may have symlinked the whole containing directory as one unit - restow is safe regardless, it's a no-op when nothing changed.

**Remove a package**:
```sh
stow -D -t ~ <package>
```
Removes that package's symlinks from `$HOME`; the files stay in the repo, just unlinked.

**List what's stowed**: check `$HOME` directly:
```sh
ls -la ~/.zshrc ~/.config/<name>
```
A stowed path shows as a symlink pointing back into this repo.

## Flags reference

| Flag | Meaning |
|---|---|
| `-t <dir>` | Target directory (`~` here, always explicit) |
| `-n` | Dry run - shows what would happen, changes nothing |
| `-v` | Verbose (repeat for more detail) |
| `-R` | Restow - unstow then stow again |
| `-D` | Unstow - remove that package's symlinks |

