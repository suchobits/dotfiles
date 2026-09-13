# Command aliases

# Navigation
alias cd="z"
alias find="fd"
alias grep="rg"

# File Management (eza)
alias ls="eza -l --icons --git -a"
alias ll="eza -lhg --icons=always"
alias la="eza -lahg --icons=always"
alias tree="eza --tree --icons=always"

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# Apps & Utilities
alias y="yazi"                 # Finder replacement
alias top="btop"               # Activity monitor replacement
alias htop="btop"
alias cat="bat"                # File viewer
alias help="tldr"              # Man pages replacement
alias lzd="lazydocker"         # Docker GUI
alias lg="lazygit"             # Git GUI
alias t="tv"                   # TV for piping (e.g. ls | t)

# AI Tooling
alias cld="claude"
alias cldp="claude -p"
alias cldo="claude --model opus"
alias clds="claude --model sonnet"
alias cldys="claude --dangerously-skip-permissions --model sonnet"
alias cldy="claude --dangerously-skip-permissions --model sonnet"
alias cldyo="claude --dangerously-skip-permissions --model opus"
alias lfg="claude --dangerously-skip-permissions --model opus"
alias cldpy="claude -p --dangerously-skip-permissions"
alias cldpyo="claude -p --dangerously-skip-permissions --model opus"
alias cldr="claude --resume"

# Git
alias lg="lazygit"
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gs="git status"
alias gf="git fetch"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# nix-darwin (flakes ignore untracked files, so stage first)
DOTFILES="$HOME/Developer/repos/dotfiles"
alias drb="darwin-rebuild build --flake $DOTFILES#MBP"
alias drs="git -C $DOTFILES add -A && sudo darwin-rebuild switch --flake $DOTFILES#MBP"
alias dru="nix flake update --flake $DOTFILES && drs"
alias drg="sudo darwin-rebuild --list-generations"

# Update flake inputs. `dru` (above) bumps every input then rebuilds;
# `nfu <input>` bumps just one (e.g. `nfu nixpkgs`) - follow with `drs`.
alias nfu="nix flake update --flake $DOTFILES"

# GNU Stow - symlink dotfiles into ~. `-d` lets these run from any cwd,
# `-R` (restow) is a safe no-op re-run. See stow/README.md.
alias stn="stow -Rnv -d $DOTFILES/stow -t ~"   # dry run:  stn nvim
alias sts="stow -Rv  -d $DOTFILES/stow -t ~"   # apply:    sts nvim
alias std="stow -Dv  -d $DOTFILES/stow -t ~"   # unstow:   std nvim
sta() {                                         # (re)stow every package
  emulate -L zsh
  local pkgs=("$DOTFILES"/stow/*(/N:t))
  stow -Rv -d "$DOTFILES/stow" -t ~ "$pkgs[@]"
}
