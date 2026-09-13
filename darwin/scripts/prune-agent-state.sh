#!/usr/bin/env bash
#
# Prunes local AI-agent session and chat-history state for tools that expose
# no retention setting of their own:
#   - Codex CLI (~/.codex): session transcripts (sessions/), shell command
#     snapshots, app cache. Codex offers only manual per-session delete.
#   - Pi (~/.pi/agent): session transcripts, plus timestamped settings/model
#     .bak files that Pi writes on every config change and never evicts.
#   - Antigravity IDE: Electron/Chromium disk caches only (Cache, CachedData,
#     GPUCache, Dawn*Cache, logs, Crashpad, CachedExtensionVSIXs). Excludes
#     Local Storage, Session Storage, blob_storage, and workspaceStorage,
#     which hold real app and extension state.
#
# Claude Code is not handled here; it has a native `cleanupPeriodDays`
# setting in ~/.claude/settings.json.
#
# Scheduled daily at 9am by darwin/launchd.nix. Default retention is 7 days;
# override per-run with PRUNE_AGENT_STATE_DAYS=N.
# Logs: ~/Library/Logs/prune-agent-state.log
set -uo pipefail

RETENTION_DAYS="${PRUNE_AGENT_STATE_DAYS:-7}"
log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

prune_files() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  find "$dir" -type f -mtime +"$RETENTION_DAYS" -delete 2>/dev/null
}

log "Pruning agent state older than ${RETENTION_DAYS} days"

# --- Codex CLI (~/.codex) ---
prune_files "$HOME/.codex/sessions"
find "$HOME/.codex/sessions" -type d -empty -delete 2>/dev/null
prune_files "$HOME/.codex/shell_snapshots"
prune_files "$HOME/.codex/cache"

# --- Pi (~/.pi/agent) ---
prune_files "$HOME/.pi/agent/sessions"
find "$HOME/.pi/agent" -maxdepth 1 -type f -name '*.bak' -mtime +"$RETENTION_DAYS" -delete 2>/dev/null

# --- Antigravity IDE - Electron/Chromium caches only, never touches
#     Local Storage / Session Storage / blob_storage / workspace data ---
AG="$HOME/Library/Application Support/Antigravity IDE"
for d in "Cache" "Code Cache" "CachedData" "GPUCache" "DawnGraphiteCache" "DawnWebGPUCache" "CachedExtensionVSIXs" "logs" "Crashpad"; do
  prune_files "$AG/$d"
done

log "Done"
