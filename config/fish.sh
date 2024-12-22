#!/bin/sh

fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fish_update_completions"

fish -c "nvm install lts"
fish -c "set --universal nvm_default_version lts"