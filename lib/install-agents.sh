#!/bin/sh

export PATH="$HOME/.bun/bin:$PATH"

printf "Installing PI...\n"
bun install -g @earendil-works/pi-coding-agent
