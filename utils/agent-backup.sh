#!/bin/sh

# Copies what your coding agents remember to a folder of your choice.
# Read-only on the source, so it is safe to run at any time.
#
#   ./utils/agent-backup.sh <destination> [--with-transcripts]
#
# Always included:
#   Claude Code  auto memory of every project, plans, prompt history
#   pi           sessions
#   Zed          text-thread conversations
# With --with-transcripts:
#   Claude Code  full session transcripts (they can contain secrets and company code)
#
# Not included on purpose: ~/.claude.json and ~/.pi/agent/auth.json (credentials),
# and anything already stowed from this repo (settings, skills, rules).

DEST=$1
TRANSCRIPTS=$2

if [ -z "$DEST" ]; then
    echo "❌ Usage: $0 <destination> [--with-transcripts]"
    exit 1
fi

mkdir -p "$DEST" || exit 1

# Copies $1 to $DEST/$2 if it exists. Extra arguments go to rsync.
copy() {
    SRC=$1
    TARGET=$2
    shift 2
    if [ -e "$SRC" ]; then
        mkdir -p "$DEST/$TARGET"
        rsync -a "$@" "$SRC" "$DEST/$TARGET/"
        echo "✅ $SRC"
    else
        echo "⏭  $SRC (not found)"
    fi
}

printf "💾 Backing up agent data to %s\n\n" "$DEST"

if [ "$TRANSCRIPTS" = "--with-transcripts" ]; then
    copy "$HOME/.claude/projects/" claude/projects
else
    # Keep every directory on the way down, but only files under a memory/ folder.
    copy "$HOME/.claude/projects/" claude/projects \
        --prune-empty-dirs --include='*/' --include='memory/***' --exclude='*'
fi

copy "$HOME/.claude/plans/" claude/plans
copy "$HOME/.claude/history.jsonl" claude
copy "$HOME/.pi/agent/sessions/" pi/sessions
copy "$HOME/.config/zed/conversations/" zed/conversations

date "+%Y-%m-%d %H:%M:%S" > "$DEST/last-backup.txt"

printf "\n📦 Done. Files backed up:\n"
find "$DEST" -type f ! -name last-backup.txt | wc -l | sed 's/^ */   /'
