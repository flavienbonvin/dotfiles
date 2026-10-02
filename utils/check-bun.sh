#!/bin/sh

if ! command -v bun &> /dev/null; then
    echo "🚨 Bun is not installed!"
    echo "Install it with: brew install oven-sh/bun/bun"
    exit 1
fi
