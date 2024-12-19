function gclean -d 'Git clean all untracked branches'
   git fetch --all -p; git branch -v | grep "gone" | awk '{ print $1 }' | xargs -n 1 git branch -D
end