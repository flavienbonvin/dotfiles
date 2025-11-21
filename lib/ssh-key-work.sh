#!/bin/sh

ssh-keygen -t ed25519 -C "flavien.bonvin@pm.me" -f ~/.ssh/github -N ""  >/dev/null 2>&1
ssh-keygen -t ed25519 -C "flavien.bonvin@proton.ch" -f ~/.ssh/gitlab -N ""  >/dev/null 2>&1

cat ~/.ssh/github.pub >> ~/Desktop/github.txt
cat ~/.ssh/gitlab.pub >> ~/Desktop/gitlab.txt

ssh-add --apple-use-keychain ~/.ssh/github
ssh-add --apple-use-keychain ~/.ssh/gitlab
