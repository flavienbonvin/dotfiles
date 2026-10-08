function pf -d 'Run a script in a pnpm workspace package'
    set package $argv[1]
    set script $argv[2..]

    if test -z "$package" -o -z "$script"
        echo 'usage: pf <package> <script> [args...]'
        return 1
    end

    pnpm --filter $package run $script
end
