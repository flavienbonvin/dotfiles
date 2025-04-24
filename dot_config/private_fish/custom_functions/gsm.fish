function gsm -d 'Git switch main'
    git switch main && git pull && git fetch --all && gclean
end
