#!/bin/sh

# Compares what Homebrew has installed with the brewfiles of a profile.
#
#   ./utils/brew-drift.sh personal            list the differences, change nothing
#   ./utils/brew-drift.sh work --remove       also offer to uninstall the extras, one by one
#
# Covers casks and formulae (only the ones you installed on purpose, not
# dependencies). Mac App Store apps and taps are not checked.

PROFILE=$1
ACTION=$2

if [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; then
    echo "❌ Invalid profile. Usage: $0 [personal|work] [--remove]"
    exit 1
fi

TMP=$(mktemp -d "${TMPDIR:-/tmp}/brew-drift.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

# Names declared in the brewfiles, for one kind ("brew" or "cask").
# A tap prefix like "user/tap/name" is dropped so it matches what brew reports.
declared() {
    cat ./dependencies/brewfile-common ./dependencies/brewfile-"$PROFILE" \
        | sed -n "s/^$1 \"\([^\"]*\)\".*/\1/p" | sed 's|.*/||' | sort -u
}

declared cask > "$TMP/cask-declared"
declared brew > "$TMP/brew-declared"
brew list --cask -1 | sed 's|.*/||' | sort -u > "$TMP/cask-installed"
brew leaves | sed 's|.*/||' | sort -u > "$TMP/brew-installed"

# Prints a titled list, or "none".
show() {
    printf "%s\n" "$1"
    if [ -s "$2" ]; then sed 's/^/   /' "$2"; else echo "   none"; fi
    echo
}

comm -23 "$TMP/cask-installed" "$TMP/cask-declared" > "$TMP/cask-extra"
comm -13 "$TMP/cask-installed" "$TMP/cask-declared" > "$TMP/cask-missing"
comm -23 "$TMP/brew-installed" "$TMP/brew-declared" > "$TMP/brew-extra"
comm -13 "$TMP/brew-installed" "$TMP/brew-declared" > "$TMP/brew-missing"

printf "🔎 Profile: %s\n\n" "$PROFILE"
show "Casks installed but not in a brewfile:" "$TMP/cask-extra"
show "Formulae installed but not in a brewfile:" "$TMP/brew-extra"
show "Casks in a brewfile but not installed:" "$TMP/cask-missing"
show "Formulae in a brewfile but not installed:" "$TMP/brew-missing"

[ "$ACTION" = "--remove" ] || exit 0

# Asks about each name in file $1 and runs the uninstall command $2 for the ones you accept.
offer_removal() {
    while read -r NAME <&3; do
        printf "🗑  Uninstall %s? [y/N] " "$NAME"
        read -r ANSWER
        case "$ANSWER" in
            y | Y) $2 "$NAME" ;;
            *) echo "   kept" ;;
        esac
    done 3< "$1"
}

offer_removal "$TMP/cask-extra" "brew uninstall --cask"
offer_removal "$TMP/brew-extra" "brew uninstall"

printf "\n🧹 Dependencies nothing needs anymore (dry run):\n"
brew autoremove --dry-run
