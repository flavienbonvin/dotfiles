#!/bin/sh

PROFILE=$1

if [ -z "$PROFILE" ] || { [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; }; then
    echo "❌ Invalid profile. Usage: $0 [personal|work]"
    exit 1
fi

printf "🌯 Configuring $PROFILE laptop\n\n"

printf "🥇 Installing brew packages and casks\n\n"
brew bundle --file=./dependencies/brewfile-common
brew bundle --file=./dependencies/brewfile-$PROFILE

printf "🥈 Configuring macos\n\n"
./lib/configure-macos.sh

printf "🥉 Configuring dev stuff\n\n"
./lib/ssh-key.sh $PROFILE

printf "4️⃣  Setting LSP server\n\n"
./lib/install-lsp.sh
