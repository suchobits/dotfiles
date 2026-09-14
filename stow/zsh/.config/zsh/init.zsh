# Tool initializations and completions

# Keep emacs-style command-line editing (C-a / C-e / C-w ...). zsh would
# otherwise pick the vi keymap here because $EDITOR is "nvim" (contains
# "vi"); set this before the tool evals so their widgets bind correctly.
bindkey -e

# Completion system. darwin/zsh.nix turns off nix-darwin's own
# unconditional compinit (its compaudit security scan of $fpath is real
# cost on every shell with Nix's many profile dirs); only pay for that
# scan once a day, trust the dump otherwise.
autoload -Uz compinit
if [[ -n "${ZDOTDIR:-$HOME}"/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# FZF key bindings and fuzzy completion
command -v fzf &> /dev/null && eval "$(fzf --zsh)"

# Starship
command -v starship &> /dev/null && eval "$(starship init zsh)"

# zoxide (smarter cd, provides the `z` command)
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# tv fuzzy finder
command -v tv &> /dev/null && eval "$(tv init zsh)"
