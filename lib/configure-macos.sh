#!/bin/sh

chflags nohidden ~/Library

defaults write com.apple.dock orientation left
defaults write com.apple.dock persistent-apps -array

FISH_PATH=$(command -v fish)
grep -qx "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
chsh -s "$FISH_PATH"

killall Dock
killall Finder
