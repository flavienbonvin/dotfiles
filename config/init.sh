#!/bin/sh

echo "🥇 Installing brew packages and casks"
brew bundle --file=./Brewfile

echo "🥈 Configuring macos"
./macos.sh

echo "🥉 Configuring dev stuff"
./dev-config.sh

echo "🐟 Configuring fish"
./fish.sh