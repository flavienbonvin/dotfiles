#!/bin/sh

PROFILE=$1

if [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; then
    echo "❌ Invalid profile. Usage: $0 [personal|work]"
    exit 1
fi

printf "📦 Setting up package managers for $PROFILE profile\n\n"

# Node (via fnm)
eval "$(fnm env --shell bash)"
fnm install --lts
fnm use lts-latest

# Bun
if ! command -v bun >/dev/null; then
    curl -fsSL https://bun.com/install | bash
fi

export PATH="$HOME/.bun/bin:$PATH"

# pnpm
# SHELL=/bin/zsh keeps the installer from editing the stowed fish config
# (PNPM_HOME is already set in fish-common/conf.d/dev-paths.fish).
if [ ! -x "$HOME/Library/pnpm/bin/pnpm" ]; then
    curl -fsSL https://get.pnpm.io/install.sh | SHELL=/bin/zsh sh -
fi
