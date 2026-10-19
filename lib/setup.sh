#!/bin/sh

PROFILE=$1

if [ -z "$PROFILE" ] || { [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "base" ]; }; then
    echo "❌ Invalid profile. Usage: $0 [personal|base]"
    exit 1
fi

printf "🌯 Configuring $PROFILE laptop\n\n"

printf "🥇 Installing brew packages and casks\n\n"
brew bundle --file=./dependencies/brewfile-common
[ "$PROFILE" = "personal" ] && brew bundle --file=./dependencies/brewfile-personal

printf "🥈 Configuring macos\n\n"
./lib/configure-macos.sh

printf "🥉 Configuring dev stuff\n\n"
./lib/ssh-key.sh $PROFILE

printf "4️⃣  Setting up Node package managers\n\n"
./lib/setup-dev.sh $PROFILE

printf "5️⃣  Setting LSP server\n\n"
./lib/install-lsp.sh

printf "6️⃣  Installing coding agents\n\n"
./lib/install-agents.sh
