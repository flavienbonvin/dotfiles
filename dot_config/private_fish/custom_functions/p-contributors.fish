function p-contributors --description "Show git contribution stats for predefined authors"
    # Array of author emails
    set authors \
        "guillaume.gonzalez@proton.ch" \
        "flavien.bonvin@proton.ch" \
        "richard.tetaz@proton.ch" \
        "romain.sanchez@proton.ch" \
        "nicolas.hoffmann@proton.ch" \
        "mattias.svanstrom@proton.ch" \
        "edvin.candon@proton.ch" \
        "fedora.lepcheska@proton.ch" \
        "coral.avraham@proton.ch"

    # Print header
    printf "%-35s %12s %15s %15s %15s\n" "Author" "Commits" "Added" "Removed" "Total"
    printf "%s\n" "-----------------------------------------------------------------------------"

    # Create a temporary file to store results
    set -l tmpfile (mktemp)

    # Loop through each author and store results
    for author in $authors
        # Get commit count
        set -l commit_count (git rev-list --count --author="$author" HEAD)

        # Get author's name from git log for display
        set -l display_name (git log -1 --author="$author" --format="%aN" 2>/dev/null || echo $author)

        # Get stats for current author
        git log --all --author="$author" --pretty=tformat: --numstat | \
        awk -v author="$display_name" -v commits="$commit_count" '
        {
            add += $1;
            subs += $2;
            loc += $1 - $2
        }
        END {
            printf "%d\t%s\t%d\t%\'d\t%\'d\t%\'d\n", add, author, commits, add, subs, loc
        }' >> $tmpfile
    end

    # Sort the results by added lines (first field) and display
    sort -nr $tmpfile | while read -l line
        set -l fields (string split \t $line)
        printf "%-35s %12s %15s %15s %15s\n" $fields[2] $fields[3] $fields[4] $fields[5] $fields[6]
    end

    # Clean up
    rm $tmpfile
end
