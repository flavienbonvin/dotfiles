#!/bin/sh

printf "🌯 Configuring personal laptop\n\n"

printf "🥇 Installing brew packages and casks\n\n"
brew bundle --file=./brewfile-common

printf "🥈 Configuring macos\n\n"
./configure-macos.sh

printf "🥉 Configuring dev stuff\n\n"
./ssh-key-personal.sh
