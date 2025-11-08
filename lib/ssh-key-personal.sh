#!/bin/sh

ssh-keygen -t ed25519 -C "flavien.bonvin@pm.me" -f ~/.ssh/github -N "" >/dev/null 2>&1

cat ~/.ssh/github.pub >> ~/Desktop/github.txt

ssh-add --apple-use-keychain ~/.ssh/github
