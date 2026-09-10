#!/bin/sh

PROFILE=$1

if [ -z "$PROFILE" ] || { [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; }; then
    echo "❌ Invalid profile. Usage: $0 [personal|work]"
    exit 1
fi

EXISTING=""

for KEY in ~/.ssh/github ~/.ssh/github.pub; do
    [ -e "$KEY" ] && EXISTING="$EXISTING $KEY"
done

if [ "$PROFILE" = "work" ]; then
    for KEY in ~/.ssh/gitlab ~/.ssh/gitlab.pub; do
        [ -e "$KEY" ] && EXISTING="$EXISTING $KEY"
    done
fi

if [ -n "$EXISTING" ]; then
    echo "❌ SSH keys already exist:"
    for KEY in $EXISTING; do
        echo "   $KEY"
    done
    echo "Remove or back them up before running this script, generating new ones would override them."
    exit 1
fi

printf "🔑 Setting up SSH keys for $PROFILE profile\n\n"

ssh-keygen -t ed25519 -C "flavien.bonvin@pm.me" -f ~/.ssh/github -N "" >/dev/null 2>&1

ssh-add --apple-use-keychain ~/.ssh/github
cat ~/.ssh/github.pub >> ~/Desktop/github.txt
echo "📋 Public key saved to ~/Desktop/github.txt"

# Git signs commits with the same key, allowed_signers lets git verify them locally
echo "flavien.bonvin@pm.me $(cat ~/.ssh/github.pub)" > ~/.ssh/allowed_signers


if [ "$PROFILE" = "work" ]; then
    ssh-keygen -t ed25519 -C "flavien.bonvin@proton.ch" -f ~/.ssh/gitlab -N ""  >/dev/null 2>&1

    ssh-add --apple-use-keychain ~/.ssh/gitlab
    cat ~/.ssh/gitlab.pub >> ~/Desktop/gitlab.txt
    echo "📋 Public key saved to ~/Desktop/gitlab.txt"

    echo "flavien.bonvin@proton.ch $(cat ~/.ssh/gitlab.pub)" >> ~/.ssh/allowed_signers
fi

echo "✍️  Add the public key to GitHub/GitLab as a signing key, not only as an auth key"
