# Tool initializations and completions

# Keep emacs-style command-line editing (C-a / C-e / C-w ...). zsh would
# otherwise pick the vi keymap here because $EDITOR is "nvim" (contains
# "vi"); set this before the tool evals so their widgets bind correctly.
bindkey -e

# Completion system. darwin/zsh.nix disables nix-darwin's own compinit
# (its compaudit scan of $fpath is real cost with Nix's many profile
# dirs); audit once a day instead. A stamp file tracks that, not the
# dump's mtime - compinit only bumps the dump's mtime when $fpath's
# file count changes, which isn't daily, so mtime-gating would re-audit
# every shell once stale. Lock dir: one audit at a time, not one per
# concurrently-starting shell. zcompile: cache the dump as bytecode.
#
# The (#q...) glob qualifiers below need extendedglob or they silently
# stop qualifying and "-n ..." is just true - scope it to this closure
# so it doesn't change pattern matching for the rest of the shell.
autoload -Uz compinit
_compdump="${ZDOTDIR:-$HOME}/.zcompdump"
_compstamp="$_compdump.audited"
_complock="$_compdump.lock"
() {
  setopt local_options extendedglob
  [[ -d "$_complock"(#qNmm+1) ]] && rmdir "$_complock" 2>/dev/null
  if [[ ! -e "$_compstamp" || -n "$_compstamp"(#qN.mh+24) ]] && mkdir "$_complock" 2>/dev/null; then
    compinit -d "$_compdump"
    touch "$_compstamp"
    zcompile "$_compdump" 2>/dev/null
    rmdir "$_complock"
  else
    compinit -C -d "$_compdump"
  fi
}
unset _compdump _compstamp _complock

# FZF key bindings and fuzzy completion
command -v fzf &> /dev/null && eval "$(fzf --zsh)"

# Starship
command -v starship &> /dev/null && eval "$(starship init zsh)"

# zoxide (smarter cd, provides the `z` command)
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# tv fuzzy finder
command -v tv &> /dev/null && eval "$(tv init zsh)"
