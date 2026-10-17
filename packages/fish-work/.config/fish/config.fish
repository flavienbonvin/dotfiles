fnm env --use-on-cd --log-level=quiet --shell fish | source

set -x NODE_EXTRA_CA_CERTS "$HOME/Library/Application Support/mkcert/rootCA.pem"

# Hermes Agent command
fish_add_path "$HOME/.local/bin"
