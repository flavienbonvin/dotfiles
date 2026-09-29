#!/bin/sh

eval "$(fnm env --shell bash)"
fnm use lts-latest

printf "Installing PI...\n"
npm install -g @earendil-works/pi-coding-agent
