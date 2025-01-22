function release-inbox -d "Release a new version of Mail or Calendar"
    argparse 'p/product=' -- $argv

    if not set -q _flag_product
        echo "Error: The --product option is required."
        return 1
    end

    # Validate product parameter
    switch $_flag_product
        case "mail"
            set product "proton-mail"
        case "calendar"
            set product "proton-calendar"
        case '*'
            echo "Error: Invalid product. Must be either 'mail' or 'calendar'."
            return 1
    end

    yarn run version --applications $product --version build
end