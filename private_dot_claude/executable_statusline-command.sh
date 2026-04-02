#!/bin/bash
# Claude Code statusline — powered by ccusage with quota display

# Find node dynamically — works on macOS (Homebrew) and Linux (Linuxbrew/system)
NODE="$(command -v node 2>/dev/null)"
if [ -z "$NODE" ]; then
    # Fallback: check common Homebrew locations not yet on PATH
    for candidate in /opt/homebrew/bin/node /home/linuxbrew/.linuxbrew/bin/node /usr/local/bin/node; do
        if [ -x "$candidate" ]; then
            NODE="$candidate"
            break
        fi
    done
fi

if [ -z "$NODE" ]; then
    echo "node not found"
    exit 1
fi

OUTPUT=$("$NODE" "$HOME/.local/share/ccusage/apps/ccusage/dist/index.js" statusline --quota)
RC=$?

# On error, pass through raw output
if [ $RC -ne 0 ] || [[ "$OUTPUT" == *"❌"* ]]; then
    echo "$OUTPUT"
    exit $RC
fi

# Merge 🤖 model and 🧠 context sections into one
# Input:  🤖 Opus | ... | 🧠 N/A
# Output: 🤖 Opus (🧠 N/A) | ...
IFS='|' read -ra PARTS <<< "$OUTPUT"
MODEL="" CTX="" REST=()
for part in "${PARTS[@]}"; do
    trimmed="${part#"${part%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    case "$trimmed" in
        🤖*) MODEL="$trimmed" ;;
        🧠*) CTX="$trimmed" ;;
        *)   REST+=("$trimmed") ;;
    esac
done
MERGED="${MODEL} – ${CTX}"
SECTIONS=("$MERGED" "${REST[@]}")

# Reassemble as single line
SINGLE=$(IFS='|'; printf '%s' "${SECTIONS[0]}"; shift; for s in "${SECTIONS[@]:1}"; do printf ' | %s' "$s"; done)

# If it fits, print on one line; otherwise one section per line
COLS="${COLUMNS:-$(tput cols 2>/dev/null || echo 120)}"
if [ "${#SINGLE}" -le "$COLS" ]; then
    echo "$SINGLE"
else
    printf '%s\n' "${SECTIONS[@]}"
fi
