# -------------------------------------------------------------------
# API keys via macOS Keychain
#
# secrets.zsh looks these up live from _secret_names -- no render step,
# no template. add/rm edit that array and auto-commit (only the NAME is
# ever written, never the value).
#   secret-add NAME   store/update a key in Keychain (prompts, hidden)
#   secret-rm NAME    remove a key from Keychain
#   secret-list       show configured key names
# -------------------------------------------------------------------

_secrets_file="$HOME/Developer/repos/dotfiles/stow/zsh/.config/zsh/secrets.zsh"
_secrets_repo="$HOME/Developer/repos/dotfiles"

_secrets_commit() {
  emulate -L zsh
  local msg="$1"

  git -C "$_secrets_repo" diff --quiet -- "$_secrets_file" && return 0
  git -C "$_secrets_repo" add "$_secrets_file" \
    && git -C "$_secrets_repo" commit -q -m "chore: $msg in secrets list" \
    && echo "dotfiles: committed - $msg in secrets list" \
    || echo "dotfiles: could not commit secrets list change, repo left dirty - commit manually" >&2
}

secret-add() {
  emulate -L zsh
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "usage: secret-add NAME" >&2
    return 1
  fi
  if [[ ! "$name" =~ '^[A-Z_][A-Z0-9_]*$' ]]; then
    echo "NAME should look like an env var, e.g. OPENAI_API_KEY" >&2
    return 1
  fi

  security add-generic-password -a "$USER" -s "$name" -U -w || return 1

  if ! command grep -qE "^[[:space:]]*${name}[[:space:]]*\$" "$_secrets_file"; then
    awk -v name="  $name" '
      { print }
      /_secret_names=\($/ && !done { print name; done=1 }
    ' "$_secrets_file" > "$_secrets_file.tmp" && mv "$_secrets_file.tmp" "$_secrets_file"
    _secrets_commit "add $name"
  fi

  echo "$name saved. Run 'exec zsh' (or open a new terminal) to load it."
}

secret-rm() {
  emulate -L zsh
  local name="$1"

  if [[ -z "$name" ]]; then
    echo "usage: secret-rm NAME" >&2
    return 1
  fi

  security delete-generic-password -a "$USER" -s "$name" >/dev/null 2>&1

  awk -v name="$name" '
    { t=$0; gsub(/^[ \t]+|[ \t]+$/, "", t); if (t == name) next; print }
  ' "$_secrets_file" > "$_secrets_file.tmp" && mv "$_secrets_file.tmp" "$_secrets_file"

  _secrets_commit "remove $name"

  echo "$name removed (if it existed). Run 'exec zsh' to unload it."
}

secret-list() {
  print -l -- "${_secret_names[@]}"
}

# -------------------------------------------------------------------
# Per-shell Xcode toolchain, for beta/RC testing alongside stable.
#
# Sets $DEVELOPER_DIR instead of `xcode-select`, which is global and
# would silently repoint every other terminal/nvim's xcrun,
# xcodebuild, and sourcekit-lsp at the beta. DEVELOPER_DIR only
# affects this shell (and children spawned from it, e.g. nvim).
#   xc-use VERSION   point this shell's Xcode tools at an installed version
#   xc-reset         unset the override, back to xcode-select's default
# -------------------------------------------------------------------

xc-use() {
  emulate -L zsh
  local version="$1" app_path

  if [[ -z "$version" ]]; then
    echo "usage: xc-use VERSION   (e.g. xc-use 27)" >&2
    echo "installed:" >&2
    xcodes installed >&2
    return 1
  fi

  app_path=$(xcodes installed | awk -v v="$version" '$0 ~ "^"v { print $NF; exit }')
  if [[ -z "$app_path" ]]; then
    echo "no installed Xcode matches '$version'" >&2
    return 1
  fi

  export DEVELOPER_DIR="$app_path/Contents/Developer"
  echo "DEVELOPER_DIR -> $DEVELOPER_DIR (this shell only)"
}

xc-reset() {
  emulate -L zsh
  unset DEVELOPER_DIR
  echo "DEVELOPER_DIR unset - back to xcode-select default ($(xcode-select -p))"
}

# -------------------------------------------------------------------
# sourcekit-lsp cross-file resolution for any Xcode project.
#
# sourcekit-lsp needs a compile-flags database to see symbols across
# files in a target. xcode-build-server's own `config` can't read
# Xcode 26 build logs, so this does a clean build piped through
# `parse -a` instead, writing buildServer.json + .compile to the
# project root (both globally gitignored - see stow/git). Re-run
# after adding files, deps, or changing build settings, then
# :LspRestart in nvim. See nvim README's Swift section for detail.
#   xc-lsp [SCHEME]   generate buildServer.json + .compile for the
#                      .xcworkspace/.xcodeproj in the current directory
# -------------------------------------------------------------------

xc-lsp() {
  emulate -L zsh
  local scheme="$1" destination platforms rc
  local -a project_arg destination_arg
  local workspace=(*.xcworkspace(N)) xcodeproj=(*.xcodeproj(N))

  if (( $#workspace )); then
    project_arg=(-workspace "$workspace[1]")
  elif (( $#xcodeproj )); then
    project_arg=(-project "$xcodeproj[1]")
  else
    echo "no .xcworkspace or .xcodeproj in $PWD" >&2
    return 1
  fi

  if [[ -z "$scheme" ]]; then
    scheme=$(xcodebuild -list -json "${project_arg[@]}" 2>/dev/null | jq -r '(.workspace // .project).schemes[0] // empty')
    if [[ -z "$scheme" ]]; then
      echo "no scheme found - pass one: xc-lsp SCHEME" >&2
      return 1
    fi
  fi

  platforms=$(xcodebuild -showBuildSettings "${project_arg[@]}" -scheme "$scheme" 2>/dev/null \
    | awk -F'= ' '/ SUPPORTED_PLATFORMS /{ print $2; exit }')
  case "$platforms" in
    *iphonesimulator*) destination="generic/platform=iOS Simulator" ;;
    *appletvsimulator*) destination="generic/platform=tvOS Simulator" ;;
    *watchsimulator*) destination="generic/platform=watchOS Simulator" ;;
    *xrsimulator*) destination="generic/platform=visionOS Simulator" ;;
    *macosx*) destination="generic/platform=macOS" ;;
  esac
  [[ -n "$destination" ]] && destination_arg=(-destination "$destination")

  local log="${TMPDIR:-/tmp}/xc-lsp-$$.log"
  xcodebuild clean build "${project_arg[@]}" -scheme "$scheme" "${destination_arg[@]}" 2>&1 \
    | tee "$log" \
    | xcode-build-server parse -a
  rc=$pipestatus[1]

  if (( rc != 0 )); then
    echo "build failed - see $log" >&2
    return 1
  fi
  rm -f "$log"
  echo "buildServer.json + .compile written for scheme '$scheme'${destination:+ ($destination)}. Run :LspRestart in nvim."
}