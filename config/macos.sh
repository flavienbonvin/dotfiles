#!/bin/sh

chflags nohidden ~/Library

defaults write com.apple.dock orientation left
defaults write "com.apple.dock" "persistent-apps" -array

sudo bash -c 'echo $(which fish) >> /etc/shells'
chsh -s $(which fish)

killall Dock
killall Finder

open -a "Zen Browser" --args --make-default-browser