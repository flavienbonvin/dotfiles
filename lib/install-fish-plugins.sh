#!/bin/sh

# Bootstraps fisher (if missing) and installs the plugins listed in
# ~/.config/fish/fish_plugins (stowed from packages/fish-common).

if ! command -v fish >/dev/null 2>&1; then
    echo "❌ fish is not installed"
    exit 1
fi

if ! fish -c 'functions -q fisher'; then
    printf "🐠 Installing fisher\n"
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher' || exit 1
fi

printf "🐠 Installing fish plugins\n"
fish -c 'fisher update'
