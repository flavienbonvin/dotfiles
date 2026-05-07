# Git branch commands group convention
# gb = branch (local)
# gc = commits
# gp = push/pull (remote)
# gr = rebase
# gd = diff
# gs = stash

abbr -a --set-cursor gbn "git switch -c %"
abbr -a gbsm "git switch main && git pull && git fetch --all"
abbr -a gbclean "git fetch --all -p; git branch -v | grep 'gone' | awk '{ print \$1 }' | xargs -n 1 git branch -D"

abbr -a gca "git add ."
abbr -a --set-cursor gcm "git add . && git commit -m \"%\""
abbr -a --set-cursor gcmp "git add . && git commit -m \"%\" && git push"
abbr -a gcan "git add . && git commit --amend --no-edit"

abbr -a gpp "git push"
abbr -a gpl "git pull"
abbr -a gpf "git push --force-with-lease"

abbr -a --set-cursor gri "git rebase -i HEAD~%"

abbr -a gds "git status"
abbr -a gdl "git log --pretty='%C(auto)%h%d %s %C(dim white)(%ar) <%an>%Creset' --all"

abbr -a gst "git stash"
abbr -a gstp "git stash pop"
