#!/bin/sh

if ! command -v brew &> /dev/null; then
    echo "🚨 Brew is not installed!"
    exit 1
fi
