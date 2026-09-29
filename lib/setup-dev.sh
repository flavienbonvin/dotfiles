#!/bin/sh

PROFILE=$1

if [ -z "$PROFILE" ] || { [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; }; then
    echo "❌ Invalid profile. Usage: $0 [personal|work]"
    exit 1
fi

printf "📦 Setting up package managers for $PROFILE profile\n\n"

eval "$(fnm env --shell bash)"
fnm install --lts
fnm use lts-latest

if ! command -v node >/dev/null 2>&1; then
    echo "❌ Node.js not found. fnm setup may have failed."
    exit 1
fi

command -v bun >/dev/null 2>&1 || curl -fsSL https://bun.com/install | bash

# Update corepack to latest version
npm install --global corepack@latest

corepack enable pnpm

if [ "$PROFILE" = "work" ]; then
    corepack enable yarn
fi
