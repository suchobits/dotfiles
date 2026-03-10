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

exec "$NODE" "$HOME/.local/share/ccusage/apps/ccusage/dist/index.js" statusline --quota
