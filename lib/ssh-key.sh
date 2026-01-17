#!/bin/sh

PROFILE=$1

if [ -z "$PROFILE" ]; then
    echo "❌ Usage: $0 [personal|work]"
    exit 1
fi

if [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; then
    echo "❌ Invalid profile: $PROFILE"
    echo "Usage: $0 [personal|work]"
    exit 1
fi

printf "🔑 Setting up SSH keys for $PROFILE profile\n\n"

ssh-keygen -t ed25519 -C "flavien.bonvin@pm.me" -f ~/.ssh/github -N "" >/dev/null 2>&1

ssh-add --apple-use-keychain ~/.ssh/github
cat ~/.ssh/github.pub >> ~/Desktop/github.txt
echo "📋 Public key saved to ~/Desktop/github.txt"


if [ "$PROFILE" = "work" ]; then
    ssh-keygen -t ed25519 -C "flavien.bonvin@proton.ch" -f ~/.ssh/gitlab -N ""  >/dev/null 2>&1

    ssh-add --apple-use-keychain ~/.ssh/gitlab
    cat ~/.ssh/gitlab.pub >> ~/Desktop/gitlab.txt
    echo "📋 Public key saved to ~/Desktop/gitlab.txt"
fi
