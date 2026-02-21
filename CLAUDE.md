# Project: Dotfiles (chezmoi)

## Structure
This is a chezmoi-managed dotfiles repository.
Source of truth for all config files across macOS and Linux.

## Conventions
- `dot_` prefix maps to `.` in home directory
- `.tmpl` suffix means Go template — use {{ .chezmoi.os }} for OS branching
- `run_onchange_` scripts re-run when their content hash changes
- `run_once_` scripts run only on first `chezmoi apply`
- Neovim configs live in dot_config/nvim-{web,ios,spring,android}/
- All four nvim configs share identical colorscheme.lua and navigation.lua

## Commands
- `chezmoi diff` — preview pending changes
- `chezmoi apply` — deploy to real locations
- `chezmoi add <target-path>` — import a file into source
- `chezmoi edit <target-path>` — open source file for a target

## Theme
Tokyo Night Night everywhere: Ghostty, Starship, tmux (powerkit), Neovim (tokyonight.nvim)
