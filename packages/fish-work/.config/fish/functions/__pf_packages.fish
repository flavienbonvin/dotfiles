function __pf_packages -d 'List "name<tab>path" of the workspace packages (cached)'
    set root $PWD
    while test $root != / -a ! -f $root/pnpm-workspace.yaml
        set root (path dirname $root)
    end
    test -f $root/pnpm-workspace.yaml; or return

    set cache ~/.cache/pf/(string replace -a / _ $root)
    if not test -f $cache -a $cache -nt $root/pnpm-lock.yaml
        mkdir -p (path dirname $cache)
        pnpm --dir $root ls -r --depth -1 --json | jq -r '.[] | "\(.name)\t\(.path)"' >$cache
    end

    cat $cache
end
