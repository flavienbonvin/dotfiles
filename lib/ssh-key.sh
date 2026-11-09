#!/bin/sh
PROFILE=$1

if [ -z "$PROFILE" ] || { [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "base" ]; }; then
    echo "❌ Invalid profile. Usage: $0 [personal|base]"
    exit 1
fi

# Safe to re-run: fills whatever is missing and never overrides an existing key.
KEY=~/.ssh/github
EMAIL="flavien.bonvin@pm.me"

mkdir -p ~/.ssh && chmod 700 ~/.ssh
printf "🔑 Setting up the GitHub SSH key for $PROFILE profile\n\n"

if [ -e "$KEY" ]; then
    echo "✅ $KEY already exists, keeping it"
    # Private key without its public half: derive it instead of generating a new pair
    [ -e "$KEY.pub" ] || ssh-keygen -y -f "$KEY" > "$KEY.pub"
else
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY" -N "" >/dev/null 2>&1
    cat "$KEY.pub" >> ~/Desktop/github.txt
    echo "📋 Public key saved to ~/Desktop/github.txt"
    echo "✍️  Add the public key to GitHub as a signing key, not only as an auth key"
fi

ssh-add --apple-use-keychain "$KEY" 2>/dev/null

# Git signs commits with the same key, allowed_signers lets git verify them locally
SIGNER="$EMAIL $(cat "$KEY.pub")"
touch ~/.ssh/allowed_signers
grep -qxF "$SIGNER" ~/.ssh/allowed_signers || echo "$SIGNER" >> ~/.ssh/allowed_signers
