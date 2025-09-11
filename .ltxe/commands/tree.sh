#!/bin/bash

TREE_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$TREE_COMMAND_DIR/../globals.sh"
source "$TREE_COMMAND_DIR/../helpers/get-tree.sh"

tree_aliases=(t)

tree() {
    local tree=$(get_tree)

    if [ ! -f "$tree/ls-R" ]; then
        echo "$PREFIX No ls-R file found in $tree."
        echo "$PREFIX Please run '$0 sync' to generate it."
        return
    fi

    echo "$PREFIX $(basename "${USER}")@personal $tree"

    local found=0
    local current_dir=""
    while IFS= read -r line; do
        if [[ "$line" == *: ]]; then
            current_dir="${line%:}"
            continue
        else
            if [[ "$line" == *.sty ]]; then
                local pkgname=$(basename "$line" .sty)
                if [[ "$pkgname" == "$(basename "$current_dir")" ]]; then
                    echo "└── $pkgname"
                    found=1
                fi
            fi
        fi
    done < "$tree/ls-R"

    if [ $found -eq 0 ]; then
        echo "└── (empty)"
    fi
}

tree_usage() {
    echo ": List all TeX packages from your personal tree."
}
