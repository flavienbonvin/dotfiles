function update -d 'Update system'
    echo 'Updating the system'

    echo \n'🍺 Updating homebrew'
    brew update
    brew upgrade
    brew upgrade --cask
    brew cleanup

    echo \n'🐠 Updating fish'
    fisher update
    fish_update_completions

    echo \n'🍎 Updating system'
    /usr/sbin/softwareupdate -ia
end