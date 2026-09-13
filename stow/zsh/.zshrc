# -------------------------------------------------------------------
# zsh initialization and load time tracking
# -------------------------------------------------------------------
zmodload zsh/datetime
ZSH_START_TIME=$EPOCHREALTIME

# Path to the modular configuration files
ZDOTDIR_CONFIG="$HOME/.config/zsh"

# Sourcing in a specific order: env -> init -> aliases -> functions
source "$ZDOTDIR_CONFIG/env.zsh"
source "$ZDOTDIR_CONFIG/init.zsh"
source "$ZDOTDIR_CONFIG/aliases.zsh"
source "$ZDOTDIR_CONFIG/functions.zsh"

# Calculate load time
ZSH_END_TIME=$EPOCHREALTIME
ZSH_LOAD_TIME=$(( (ZSH_END_TIME - ZSH_START_TIME) * 1000 ))

# Warn if startup takes more than 150ms
if (( ZSH_LOAD_TIME > 150 )); then
    printf "\033[0;33m⚠️  zsh loaded slowly: %0.2f ms\033[0m\n" $ZSH_LOAD_TIME
fi

# Handy alias to manually check the load time anytime
alias profile_zsh='printf "zsh load time: %0.2f ms\n" $ZSH_LOAD_TIME'
