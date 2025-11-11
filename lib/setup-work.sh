#!/bin/sh

printf "🌯 Configuring work laptop\n\n"

printf "🥇 Installing brew packages and casks\n\n"
brew bundle --file=./brewfile-common
brew bundle --file=./brewfile-work

printf "🥈 Configuring macos\n\n"
./configure-macos.sh

printf "🥉 Configuring SSH keys\n\n"
./ssh-key-work.sh
