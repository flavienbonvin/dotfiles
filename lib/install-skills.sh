#!/bin/sh

# Third-party agent skills, installed globally (~/.agents/skills) with the skills CLI.
# Re-run to update. Own skills live in packages/agents and are stowed instead.

export PATH="$HOME/.bun/bin:$PATH"
# npx comes from the fnm Node installed by setup-dev.sh, which only lived in that script
eval "$(fnm env --shell bash)"
fnm use lts-latest >/dev/null

printf "Installing anti-slop skill...\n"
npx -y skills add dmmulroy/anti-slop --skill install-anti-slop --global --yes
