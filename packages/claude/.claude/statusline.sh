#!/bin/bash

# Read JSON data that Claude Code sends to stdin
input=$(cat)

echo "$input" > /tmp/claude_statusline.json

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd')

echo "[$MODEL] | ${PCT}% context | ${COST} USD"
