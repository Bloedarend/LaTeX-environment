#!/bin/bash

REMOVE_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $REMOVE_COMMAND_DIR/../globals.sh

remove_aliases=(rm)

remove() {
    local name=$1

    if [ -z "$name" ]; then
        echo "$PREFIX Error: Missing argument: name"
        exit 1
    fi

    if [ ! -d "$PACKAGE_DIR/$name" ]; then
        echo "$PREFIX Error: Package '$name' does not exist."
        exit 1
    fi

    rm -rf "$PACKAGE_DIR/$name" > /dev/null
    echo "$PREFIX $EMOJI_SUCCESS Package '$name' removed successfully."
}

remove_usage() {
    echo "<name> : Remove a TeX package from your project packages."
}
