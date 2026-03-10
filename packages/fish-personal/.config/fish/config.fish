starship init fish | source

export PATH="$HOME/.local/bin:$PATH"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

set -gx PATH $PATH /Users/fbonvin/.lmstudio/bin
