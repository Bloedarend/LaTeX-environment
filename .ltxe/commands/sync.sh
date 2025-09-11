#!/bin/bash

SYNC_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SYNC_COMMAND_DIR/../globals.sh"
source "$SYNC_COMMAND_DIR/../helpers/get-tree.sh"

sync_aliases=(s)

sync() {
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

    local tree_dir=$(get_tree)
    mkdir -p "$tree_dir" > /dev/null

    echo "$PREFIX Synchronizing packages to $tree_dir"

    for p in "${packages[@]}"; do
        if [ -d "$p" ]; then
            local package_name=$(basename "$p")
            echo "  └── $package_name"

            rsync -avz "$p/" "$tree_dir/" > /dev/null
        fi
    done

    echo "$PREFIX Updating TeX filename database."
    mktexlsr "$tree_dir" > /dev/null
    echo "$PREFIX Updated TeX filename database."

    echo "$PREFIX $EMOJI_SUCCESS Synchronization completed successfully."

    echo "$PREFIX Running post-sync scripts for each package."

    for p in "${packages[@]}"; do
        if [ -d "$p" ]; then
            local package_name=$(basename "$p")

            post_sync_script="$tree_dir/tex/latex/$package_name/post-sync.sh"
            if [ -f "$post_sync_script" ]; then
                echo "  └── $package_name"

                bash "$post_sync_script" > /dev/null

                if [ $? -ne 0 ]; then
                    echo "$PREFIX Error: Post sync script for $package_name failed." >&2
                    echo "$PREFIX Aborting."
                    echo "$PREFIX $EMOJI_ERROR Not all post-sync scripts could be executed successfully."
                    exit 1
                fi
            else
                echo "  └── $package_name (No post-sync script)"
            fi
        fi
    done

    echo "$PREFIX $EMOJI_SUCCESS Post-sync scripts completed successfully."

}

sync_usage() {
    echo ": Synchronize all TeX packages from your project packages to your personal tree."
}
