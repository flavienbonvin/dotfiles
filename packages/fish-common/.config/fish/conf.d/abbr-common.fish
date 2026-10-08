# Git commands group convention

# gb = branch (local)
abbr -a --set-cursor gbn "git switch -c %"
abbr -a gbsm "git switch main && git pull && git fetch --all"
abbr -a gbsr "git switch master && git pull && git fetch --all"
abbr -a gbclean "git fetch --all -p; git branch -v | grep 'gone' | awk '{ print \$1 }' | xargs -n 1 git branch -D"

# gc = commits
abbr -a gca "git add ."
abbr -a --set-cursor gcm "git add . && git commit -m \"%\""
abbr -a --set-cursor gcmp "git add . && git commit -m \"%\" && git push"
abbr -a gcan "git add . && git commit --amend --no-edit"
abbr -a gcn "git commit --amend --no-edit"

# gcp = cherry-pick
abbr -a --set-cursor gcp "git cherry-pick -m 1 %"
abbr -a gcpc "git cherry-pick --continue"
abbr -a gcpa "git cherry-pick --abort"

# gp = push/pull (remote)
abbr -a gpp "git push"
abbr -a gpl "git pull"
abbr -a gpf "git push --force-with-lease"

# gr = rebase
abbr -a --set-cursor gri "git rebase -i HEAD~%"

# gd = inspect (status, log)
abbr -a gds "git status"
abbr -a gdl "git log --pretty='%C(auto)%h%d %s %C(dim white)(%ar) <%an>%Creset' --all"

# gs = stash
abbr -a gst "git stash"
abbr -a gstp "git stash pop"

# gu = undo (reset, revert)
abbr -a guh "git reset --hard"
abbr -a guho "git reset --hard origin/(git branch --show-current)"


# pnpm
abbr -a p pnpm
