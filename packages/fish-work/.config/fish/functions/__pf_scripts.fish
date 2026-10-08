function __pf_scripts -d 'List the scripts of the package typed after pf'
    set package (commandline -opc)[2]
    set dir (__pf_packages | awk -F '\t' -v name=$package '$1 == name { print $2 }')

    test -f $dir/package.json; or return
    jq -r '.scripts // {} | to_entries[] | "\(.key)\t\(.value)"' $dir/package.json
end
