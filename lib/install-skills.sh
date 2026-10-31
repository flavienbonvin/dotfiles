#!/bin/sh

# Third-party agent skills, installed globally (~/.agents/skills) with the skills CLI.
# Re-run to update. Own skills live in packages/agents and are stowed instead.

export PATH="$HOME/.bun/bin:$PATH"

printf "Installing anti-slop skill...\n"
npx -y skills add dmmulroy/anti-slop --skill install-anti-slop --global --yes
