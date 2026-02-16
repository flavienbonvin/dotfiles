starship init fish | source
set -x NODE_EXTRA_CA_CERTS (mkcert -CAROOT)/rootCA.pem

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# opencode
fish_add_path /Users/fbonvin/.opencode/bin
