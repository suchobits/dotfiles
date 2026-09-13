# -------------------------------------------------------------------
# API keys via macOS Keychain, looked up live at shell startup.
# No render step, no template -- just names here, values never touch git.
# Manage with secret-add / secret-rm / secret-list (see functions.zsh).
# -------------------------------------------------------------------

typeset -a _secret_names=(
  TAVILY_API_KEY
  PENPOT_MCP_KEY
  FIRECRAWL_API_KEY
)

# One `security` call per key is ~10ms of Keychain round-trip; run them
# concurrently via process substitution instead of paying that serially.
typeset -A _secret_fds
for name in "${_secret_names[@]}"; do
  exec {fd}< <(security find-generic-password -a "$USER" -s "$name" -w 2>/dev/null)
  _secret_fds[$name]=$fd
done

for name in "${_secret_names[@]}"; do
  IFS= read -r -u "${_secret_fds[$name]}" value
  [[ -n "$value" ]] && export "$name"="$value"
done
unset name fd value _secret_fds
