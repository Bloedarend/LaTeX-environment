#!/bin/bash

ADD_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ADD_COMMAND_DIR"/../globals.sh

add_aliases=(a)

add() {
    local name=$1
    local repository=$2

    if [ -z "$name" ]; then
        echo "$PREFIX Error: Missing argument: name"
        exit 1
    fi

    if [ -z "$repository" ]; then
        echo "$PREFIX Error: Missing argument: repository"
        exit 1
    fi

    echo "$PREFIX Validating repository..."
    git ls-remote "$repository" > /dev/null

    if [ $? -ne 0 ]; then
        echo "$PREFIX Error: Repository does not exist or cannot be accessed."
        exit 1
    fi

    if [ -d "$PACKAGE_DIR/$name" ]; then
        local answer
        read -p "$PREFIX Warning: Directory '$name' already exists. Do you want to overwrite it? (y/n) " answer

        if [ "$answer" != "y" ]; then
            echo "$PREFIX Aborted"
            exit 1
        fi

        rm -rf "$PACKAGE_DIR/$name"
    fi

    git clone "$repository" "$PACKAGE_DIR/.temp/$name" 2> /dev/null

    if [ ! -d "$PACKAGE_DIR/.temp/$name/$name" ]; then
        echo "$PREFIX Error: Repository does not contain the package name '$name' as a first level directory."
        rm -rf "$PACKAGE_DIR/.temp"
        exit 1
    fi

    mv "$PACKAGE_DIR/.temp/$name/$name" "$PACKAGE_DIR/$name" > /dev/null
    rm -rf "$PACKAGE_DIR/.temp" > /dev/null

    echo "$PREFIX $EMOJI_SUCCESS Package '$name' added successfully."
}

add_usage() {
    echo "<name> <repository> : Add a TeX package from a git repository to your project packages."
}
