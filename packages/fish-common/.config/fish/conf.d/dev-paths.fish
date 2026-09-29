# bun
set --global --export BUN_INSTALL "$HOME/.bun"
fish_add_path --global $BUN_INSTALL/bin

# pnpm (standalone install, https://get.pnpm.io/install.sh)
set --global --export PNPM_HOME "$HOME/Library/pnpm"
fish_add_path --global $PNPM_HOME/bin
