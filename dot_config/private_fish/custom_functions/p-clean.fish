function clean -d 'Clean Proton cache'
    echo 'Cleaning Proton application cache'
    cd ~/dev/proton/clients
    rm -rf applications/**/node_modules/.cache
end