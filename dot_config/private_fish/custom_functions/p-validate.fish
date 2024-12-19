function p-validate -d "Run linting and check types"
    argparse 'h/help' 'p/product=' -- $argv
    or return 1

    if set -q _flag_help
        p-validate-help
        return 0
    end

    if not set -q _flag_product
        echo "Error: The --product option is required."
        p-validate-help
        return 1
    end

    set PROJECT_PATH "/Users/fbonvin/Dev/proton/clients"
    set tsc_command yarn workspace $_flag_product check-types
    set lint_command yarn workspace $_flag_product lint

    # Display the command to run
    echo (set_color cyan)"Testing Proton"(set_color normal)
    echo (set_color yellow)$tsc_command(set_color normal)
    echo (set_color yellow)$lint_command(set_color normal)

    # Ask for confirmation
    echo "Do you want to proceed? (y/n)"
    read -l confirmation
    if test "$confirmation" != "y"
        echo "Operation cancelled"
        return 0
    end

    # Run the command
    echo "🔎 Validating Proton..."
    cd $PROJECT_PATH
    eval $tsc_command
    eval $lint_command
end

function p-validate-help
    echo "Usage: pr-run [OPTIONS]"
    echo "Description: This command helps testing Proton applications or package."
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -s, --scientist     The name of the scientist"
    echo "  -p, --product      The name of the product to run"
    echo "                      Valid values are: account admin calendar drive mail vpn-settings."
end
