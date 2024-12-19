complete -c p-cherry -a "(__fish_my_git_function_branches)"

if test -d $__fish_config_dir/custom_functions
    set -gp fish_function_path $__fish_config_dir/custom_functions
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
set -x NODE_EXTRA_CA_CERTS (mkcert -CAROOT)/rootCA.pem
