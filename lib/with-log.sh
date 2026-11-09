#!/bin/bash
# Runs a command and keeps a copy of everything it prints in ~/.dotfiles-logs, to share when something fails.
# Usage: with-log.sh <name> <command...>
set -o pipefail

NAME=$1
shift
if [ -z "$NAME" ] || [ $# -eq 0 ]; then
    echo "❌ Usage: $0 <name> <command...>"
    exit 1
fi

DIR=~/.dotfiles-logs
mkdir -p "$DIR"
LOG="$DIR/$NAME-$(date +%Y%m%d-%H%M%S).log"
ln -sf "$LOG" "$DIR/$NAME-latest.log"

{
    echo "=== $NAME, $(date)"
    echo "macOS $(sw_vers -productVersion 2>/dev/null) on $(uname -m), user $USER, shell $SHELL"
    echo "FIRST_INSTALL=${FIRST_INSTALL:-0}"
    echo "dotfiles:      $(git -C "${DOTFILES:-.}" rev-parse --short HEAD 2>/dev/null)"
    echo "dotfiles-work: $(git rev-parse --short HEAD 2>/dev/null)"
    echo "==="
    "$@"
} 2>&1 | tee "$LOG"
STATUS=${PIPESTATUS[0]}

echo
if [ "$STATUS" -eq 0 ]; then
    echo "✅ Done. Log: $LOG"
else
    echo "🚨 Failed (exit $STATUS). Share the end of the log: tail -60 $DIR/$NAME-latest.log"
fi
exit "$STATUS"
