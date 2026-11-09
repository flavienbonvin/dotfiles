#!/bin/bash
# Stows packages into ~. Usage: stow-packages.sh <packages dir> <package...>
#
# --no-folding is required: ~/.agents and ~/.pi/agent receive files from both repos.
#
# A fresh Mac (or an app's first launch) can leave real files where a link should go, e.g. ~/.config/fish/config.fish.
# Stow refuses to touch them. With FIRST_INSTALL=1 they are moved to ~/.dotfiles-backup/<date>/ and stowing goes on.
# Without it the conflicts are listed and nothing changes.

PKG_DIR=$1
shift
STOW=(stow --no-folding -R -d "$PKG_DIR" -t "$HOME")

# Paths stow cannot replace, relative to ~. The wording differs between stow versions.
conflicts() {
    "${STOW[@]}" -n "$@" 2>&1 | sed -nE \
        -e 's/^ *\* existing target is (neither a link nor a directory|not owned by stow): (.*)$/\2/p' \
        -e 's/^ *\* cannot stow .* over existing target (.*) since neither a link nor a directory.*$/\1/p' | sort -u
}

FOUND=$(conflicts "$@")

if [ -n "$FOUND" ]; then
    if [ "${FIRST_INSTALL:-0}" != "1" ]; then
        echo "🚨 These files already exist and are not links to the dotfiles:"
        echo "$FOUND" | sed 's/^/   ~\//'
        echo "Move them away yourself, or re-run with FIRST_INSTALL=1 to back them up to ~/.dotfiles-backup and replace them."
        exit 1
    fi
    BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    echo "📦 FIRST_INSTALL: backing up existing files to $BACKUP"
    echo "$FOUND" | while IFS= read -r REL; do
        mkdir -p "$BACKUP/$(dirname "$REL")"
        mv "$HOME/$REL" "$BACKUP/$REL" && echo "   ~/$REL"
    done
fi

"${STOW[@]}" "$@"
