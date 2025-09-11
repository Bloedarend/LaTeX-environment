#!/bin/bash

LIST_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$LIST_COMMAND_DIR/../globals.sh"

list_aliases=(ls)

list() {
    if [ ! -d "$PACKAGE_DIR" ]; then
        echo "$PREFIX No packages found in '$PACKAGE_DIR'."
        exit 0
    fi

    local packages=("$PACKAGE_DIR"/*)
    local has_packages=false

    for p in "${packages[@]}"; do
        if [ -d "$p" ]; then
            has_packages=true
            break
        fi
    done

    if [ "$has_packages" = false ]; then
        echo "$PREFIX No packages found in '$PACKAGE_DIR'."
        exit 0
    fi

    echo "$PREFIX Packages in '$PACKAGE_DIR':"
    for p in "${packages[@]}"; do
        if [ -d "$p" ]; then
            echo "  └── $(basename "$p")"
        fi
    done
}

list_usage() {
    echo ": List all TeX packages from your project packages."
}
