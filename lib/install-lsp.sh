#!/bin/sh

export PATH="$HOME/.bun/bin:$PATH"

bun install -g \
      typescript \
      typescript-language-server \
      @tailwindcss/language-server \
      vscode-langservers-extracted \
      @astrojs/language-server \
      prettier
