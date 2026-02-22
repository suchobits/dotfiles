#!/bin/sh
# Bootstrap installer for chezmoi dotfiles
# Usage:
#   Personal (default — everything):
#     sh -c "$(curl -fsLS https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh)"
#   Work (skip personal apps + AI editors/agents):
#     sh -c "$(curl -fsLS https://raw.githubusercontent.com/suchobits/dotfiles/main/install.sh)" -- --flavor work
set -e

DOTFILES_REPO="suchobits/dotfiles"
FLAVOR="personal"

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --flavor)
            FLAVOR="$2"
            shift 2
            ;;
        --flavor=*)
            FLAVOR="${1#--flavor=}"
            shift
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            exit 1
            ;;
    esac
done

# Validate flavor
case "$FLAVOR" in
    personal|work) ;;
    *)
        printf 'Invalid flavor: %s (must be "personal" or "work")\n' "$FLAVOR" >&2
        exit 1
        ;;
esac

printf '==> Bootstrapping with flavor: %s\n' "$FLAVOR"

# Install chezmoi, init, and apply in one shot
printf '==> Installing chezmoi and applying dotfiles...\n'
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$DOTFILES_REPO" --promptString flavor="$FLAVOR"

printf '\n==> Done! Flavor: %s\n' "$FLAVOR"
if [ "$FLAVOR" = "work" ]; then
    printf '    Skipped: AI editors/agents, personal apps\n'
else
    printf '    Installed: full personal setup\n'
fi
printf '    Run "chezmoi diff" to review or "chezmoi apply" to re-apply.\n'
