if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
fish_ssh_agent
set -x NODE_EXTRA_CA_CERTS (mkcert -CAROOT)/rootCA.pem
