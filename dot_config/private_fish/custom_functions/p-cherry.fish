# complete -c gcherry -a "(__fish_my_git_function_branches)" 

function __fish_my_git_function_branches
    __fish_git_branches
end

function gcherry
    printf '%s' $PWD (fish_git_prompt) ' $ '
    set branch $argv[1]
    git checkout $branch
    git fetch && git reset --hard origin/$branch
    yarn install
end