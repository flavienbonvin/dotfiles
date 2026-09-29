#!/bin/sh

printf "Installing PI...\n"
curl -fsSL https://pi.dev/install.sh | sh

printf "\nInstalling Claude Code...\n"
curl -fsSL https://claude.ai/install.sh | bash
