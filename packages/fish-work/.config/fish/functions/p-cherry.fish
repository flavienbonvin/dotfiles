function p-cherry -d 'Checkout and reset to head for cherry-pick'
    set branch $argv[1]

    git switch $branch
    git fetch && git reset --hard origin/$branch
end
