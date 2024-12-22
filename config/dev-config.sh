#!/bin/sh

ssh-keygen -t ed25519 -C "flavien.bonvin@pm.me" -f ~/.ssh/github -N "" 
ssh-keygen -t ed25519 -C "flavien.bonvin@proton.ch" -f ~/.ssh/gitlab -N ""

cat ~/.ssh/github.pub >> ~/Desktop/ssh.txt
cat ~/.ssh/gitlab.pub >> ~/Desktop/ssh.txt

ssh-add --apple-use-keychain ~/.ssh/github
ssh-add --apple-use-keychain ~/.ssh/gitlab

echo "starship init fish | source" >> ~/.config/fish/config.fish