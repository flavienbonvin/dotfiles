function p-run -d "Run Proton applications"
    argparse 'h/help' 's/scientist=' 'p/products=' 't/test' -- $argv
    or return 1

    if set -q _flag_help
        p-run-help
        return 0
    end

    if not set -q _flag_scientist
        echo "Error: The --scientist option is required."
        p-run-help
        return 1
    end

    if not set -q _flag_products
        echo "Error: The --products option is required."
        p-run-help
        return 1
    end

    set products (string split ' ' $_flag_products)
    set valid_products proton-account proton-admin proton-calendar proton-drive proton-mail proton-docs proton-vpn-settings
    for product in $products
        set product (string trim $product)
        if not contains -- $product $valid_products
            echo "Error: Each product must be one of: proton-account proton-admin proton-calendar proton-drive proton-mail proton-docs proton-vpn-settings"
            p-run-help
            return 1
        end
    end

    if set -q _flag_test
        set url "$_flag_scientist.proton.black"
    else
        set url "$_flag_scientist.proton.pink"
    end


    set PROJECT_PATH "/Users/fbonvin/Dev/proton/clients"
    set command yarn start-all --applications "\"$products\"" --api $url

    # Display the command to run
    echo (set_color cyan)"Running Proton"(set_color normal)
    echo (set_color yellow)$command(set_color normal)

    # Ask for confirmation
    echo "Do you want to proceed? (y/n)"
    read -l confirmation
    if test "$confirmation" != "y"
        echo "Operation cancelled"
        return 0
    end

    # Run the command
    echo "🏃‍♂️‍➡️ Starting Proton..."
    cd $PROJECT_PATH
    eval $command
end

function p-run-help
    echo "Usage: pr-run [OPTIONS]"
    echo "Description: This command helps running Proton applications."
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -s, --scientist     The name of the scientist environment"
    echo "  -t, --test          Run the applications using a test environment"
    echo "  -p, --products      The name of the products to run"
    echo "                      Valid values are:"
    echo "                      proton-account proton-admin proton-calendar proton-drive proton-mail"
    echo "                      proton-docs proton-vpn-settings"
end
