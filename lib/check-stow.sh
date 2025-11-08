#!/bin/bash

if ! command -v stow &> /dev/null; then
    echo "🚨 GNU Stow is not installed!"
    echo "Install it with: brew install stow"
    exit 1
fi
