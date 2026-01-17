#!/bin/sh

printf "🌯 Configuring work laptop\n\n"

printf "🥇 Installing brew packages and casks\n\n"
brew bundle --file=./dependencies/brewfile-common
brew bundle --file=./dependencies/brewfile-work

printf "🥈 Configuring macos\n\n"
./configure-macos.sh

printf "🥉 Configuring SSH keys\n\n"
./ssh-key-work.sh
