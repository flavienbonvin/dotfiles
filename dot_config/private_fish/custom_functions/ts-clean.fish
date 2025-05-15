function ts-clean -d 'Clean typescript caches'
    echo "Cleaning typescript caches"
    rm -rf .turbo/.cache
    rm -f .eslintcache

    if not string match -q "/Users/fbonvin/Developer/*" (pwd)
        echo "You're not in a dev folder"
        return 1
    end

    echo "Cleaning any .cache folder"
    find . -type d -name ".cache" -exec rm -rf {} +
end
