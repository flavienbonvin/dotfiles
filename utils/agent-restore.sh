#!/bin/sh

# Puts a backup made by agent-backup.sh back into the home directory.
# Never deletes anything, and skips files that are newer on this machine.
#
#   ./utils/agent-restore.sh <backup-folder>

SRC=$1

if [ ! -d "$SRC" ]; then
    echo "❌ Usage: $0 <backup-folder>"
    exit 1
fi

# Copies $SRC/$1 to $2 if it exists.
restore() {
    if [ -e "$SRC/$1" ]; then
        mkdir -p "$2"
        rsync -a --update "$SRC/$1" "$2/"
        echo "✅ $1"
    else
        echo "⏭  $1 (not in backup)"
    fi
}

printf "♻️  Restoring agent data from %s\n\n" "$SRC"

restore claude/projects/ "$HOME/.claude/projects"
restore claude/plans/ "$HOME/.claude/plans"
restore claude/history.jsonl "$HOME/.claude"
restore pi/sessions/ "$HOME/.pi/agent/sessions"
restore zed/conversations/ "$HOME/.config/zed/conversations"

# Claude names each project folder after its absolute path. If the username
# changed, restored folders will not match the new paths.
PREFIX=$(printf "%s" "$HOME" | tr '/' '-')
if [ -d "$SRC/claude/projects" ]; then
    MISMATCHED=""
    for DIR in "$SRC"/claude/projects/*/; do
        NAME=$(basename "$DIR")
        case "$NAME" in
            "$PREFIX"*) ;;
            *) MISMATCHED="$MISMATCHED\n   $NAME" ;;
        esac
    done
    if [ -n "$MISMATCHED" ]; then
        printf "\n⚠️  These project folders do not start with %s, so Claude will not\n" "$PREFIX"
        printf "   find them for the current username. Rename them to match the new path:"
        printf "%b\n" "$MISMATCHED"
    fi
fi
