#!/bin/bash

GET_TREE_HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$GET_TREE_HELPER_DIR/../globals.sh"

get_tree() {
    local texmf_home
    texmf_home=$(kpsewhich -var-value=TEXMFHOME 2>/dev/null)

    if [ -n "$texmf_home" ]; then
        echo "$texmf_home"
    else
        echo "$PREFIX Error: Unable to determine personal TeX tree path."
        return 1
    fi
}
