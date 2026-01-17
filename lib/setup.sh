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


printf "🌯 Configuring $PROFILE laptop\n\n"

printf "🥇 Installing brew packages and casks\n\n"
brew bundle --file=./dependencies/brewfile-common
brew bundle --file=./dependencies/brewfile-$PROFILE

printf "🥈 Configuring macos\n\n"
./lib/configure-macos.sh

printf "🥉 Configuring dev stuff\n\n"
./lib/ssh-key-$PROFILE.sh
