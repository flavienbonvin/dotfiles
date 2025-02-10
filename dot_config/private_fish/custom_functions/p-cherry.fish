function __fish_my_git_function_branches
    __fish_git_branches
end

function p-cherry
    set branch $argv[1]

    git checkout $branch
    git fetch && git reset --hard origin/$branch
end
