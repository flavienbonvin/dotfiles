function __fish_my_git_function_branches
    __fish_git_branches
end

function p-cherry -d 'Prepare release branch for a safe cherry-pick'
    set branch $argv[1]

    git switch $branch
    git fetch && git reset --hard origin/$branch
end
