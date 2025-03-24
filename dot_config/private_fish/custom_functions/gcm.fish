function gcm -d 'Git checkout main'
    git checkout main && git pull && git fetch --all && gclean
end
