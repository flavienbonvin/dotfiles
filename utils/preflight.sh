#!/bin/sh

# Run this on an existing laptop before `make configure-<profile>`.
# It changes nothing except making a backup copy of ~/.ssh.
#
#   1. backs up ~/.ssh
#   2. tells you whether the SSH key step will be skipped or will generate keys
#   3. does a dry run of stow to list files that would conflict

PROFILE=$1

if [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; then
    echo "❌ Invalid profile. Usage: $0 [personal|work]"
    exit 1
fi

STATUS=0

printf "1️⃣  Backing up ~/.ssh\n\n"
if [ -d "$HOME/.ssh" ]; then
    BACKUP="$HOME/.ssh-backup-$(date +%Y%m%d-%H%M%S)"
    cp -RP "$HOME/.ssh" "$BACKUP" && echo "   saved to $BACKUP"
else
    echo "   no ~/.ssh yet, nothing to back up"
fi

printf "\n2️⃣  SSH keys\n\n"
if [ "$PROFILE" = "work" ]; then KEYS="github gitlab"; else KEYS="github"; fi
FOUND=""
MISSING=""
for KEY in $KEYS; do
    if [ -e "$HOME/.ssh/$KEY" ] || [ -e "$HOME/.ssh/$KEY.pub" ]; then
        FOUND="$FOUND $KEY"
    else
        MISSING="$MISSING $KEY"
    fi
done

if [ -n "$FOUND" ]; then
    echo "   existing:${FOUND}"
    echo "   lib/ssh-key.sh will refuse to run and leave them untouched."
    if [ -n "$MISSING" ]; then
        echo "   ⚠️  missing:${MISSING}. Nothing will generate them, do it by hand."
    fi
else
    echo "   none found. lib/ssh-key.sh will generate: $KEYS"
fi

printf "\n3️⃣  Stow dry run\n\n"
if OUTPUT=$(make stow-"$PROFILE" STOW_FLAGS="-n -v" 2>&1); then
    echo "   no conflicts"
else
    STATUS=1
    echo "   ⚠️  conflicts, stow would change nothing until these are resolved:"
    echo "$OUTPUT" | sed 's/^/   /'
fi

exit $STATUS
