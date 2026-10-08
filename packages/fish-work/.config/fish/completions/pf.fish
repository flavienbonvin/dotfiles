complete -c pf -f
complete -c pf -n 'test (count (commandline -opc)) -eq 1' -a '(__pf_packages)'
complete -c pf -n 'test (count (commandline -opc)) -eq 2' -a '(__pf_scripts)'
