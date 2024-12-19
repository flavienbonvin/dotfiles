function p-test -d "Test Proton applications or package"
    argparse 'h/help' 'p/product=' -- $argv
    or return 1

    if set -q _flag_help
        p-test-help
        return 0
    end

    if not set -q _flag_product
        echo "Error: The --product option is required."
        p-test-help
        return 1
    end

    set command "test:watch"
    set different_command proton-verify @proton/activation @proton/ai-assistant @proton/chargebee
    if contains $_flag_product $different_command
        set command "test:dev"
    end

    set PROJECT_PATH "/Users/fbonvin/Dev/proton/clients"
    set command yarn workspace $_flag_product $command

    # Display the command to run
    echo (set_color cyan)"Testing Proton"(set_color normal)
    echo (set_color yellow)$command(set_color normal)

    # Ask for confirmation
    echo "Do you want to proceed? (y/n)"
    read -l confirmation
    if test "$confirmation" != "y"
        echo "Operation cancelled"
        return 0
    end

    # Run the command
    echo "🧪 Testing Proton..."
    cd $PROJECT_PATH
    eval $command
end

function p-test-help
    echo "Usage: pr-run [OPTIONS]"
    echo "Description: This command helps testing Proton applications or package."
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -s, --scientist     The name of the scientist"
    echo "  -p, --product      The name of the product to run"
    echo "                      Valid values are: account admin calendar drive mail vpn-settings."
end
