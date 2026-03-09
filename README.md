# Dotfiles (chezmoi)

Cross-platform dotfiles managed by [chezmoi](https://www.chezmoi.io/). Tokyo Night Night everywhere.

## Full Setup (fresh machine)

Installs chezmoi, applies dotfiles, and runs all install scripts (Homebrew, packages, fonts, etc.):

```sh
# Personal (default — everything)
sh -c "$(curl -fsLS https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh)"

# Work (skip personal apps + AI editors/agents)
sh -c "$(curl -fsLS https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh)" -- --flavor work
```

## Dotfiles Only (existing machine)

Pull config files without running any install scripts:

```sh
# Install chezmoi if you don't have it
brew install chezmoi

# Init and apply dotfiles only (skip all run_ scripts)
chezmoi init suchobits/dotfiles
chezmoi apply --exclude=run
```

Then install the minimal dependencies below as needed.

## Minimal Brew Dependencies

These are what the configs directly depend on. Install only what you need.

### Core (shell + prompt)

```sh
brew install starship zoxide fzf
```

- **starship** — prompt (sourced in `.zshrc`)
- **zoxide** — `cd` replacement (sourced in `.zshrc`)
- **fzf** — fuzzy finder (sourced in `.zshrc`, used by neovim config switcher)

### Terminal & Editor

```sh
brew install neovim tmux
brew install --cask ghostty
```

### tmux plugin dependencies

tmux-powerkit requires bash 4+ and GNU utils:

```sh
brew install bash bc gawk gsed
```

Then clone TPM and install plugins:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Open tmux, then press prefix + I to install plugins
```

### CLI tools (used by shell aliases & neovim)

```sh
brew install ripgrep fd bat eza lazygit git-delta gh
```

- **ripgrep**, **fd** — used by neovim telescope and shell
- **bat** — aliased as `cat`
- **eza** — aliased as `ls`
- **lazygit** — aliased as `lg`, used by neovim
- **git-delta** — git pager (if configured in `.gitconfig`)
- **gh** — GitHub CLI

### Fonts

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

### Language toolchains (per neovim config)

Only install what you work with:

| Config | Stack | Packages |
|--------|-------|----------|
| `nvim-web` | TypeScript | `node pnpm` |
| `nvim-ios` | Swift (macOS) | `swiftformat swiftlint xcbeautify xcode-build-server` |
| `nvim-spring` | Kotlin/Spring | `kotlin gradle ktlint JetBrains/utils/kotlin-lsp`, `cask zulu@17` |
| `nvim-android` | Kotlin/Android | same as spring + Android SDK |

## Neovim Config Switcher

Four independent LazyVim configs selected via `NVIM_APPNAME`:

```sh
nvim-web       # TypeScript / Tailwind
nvim-ios       # Swift / Xcode
nvim-spring    # Kotlin / Spring Boot
nvim-android   # Kotlin / Android
v              # alias for nvim-web
vv             # interactive picker (fzf)
```
