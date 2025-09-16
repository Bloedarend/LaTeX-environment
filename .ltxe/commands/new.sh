#!/bin/bash

NEW_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$NEW_COMMAND_DIR"/../globals.sh

new_aliases=(n)

new() {
    local document_path=$1
    local template_name=$2

    if [ -z "$document_path" ]; then
        echo "$PREFIX Error: Missing argument: document_path"
        exit 1
    fi

    document_path="$DOCUMENT_DIR/$document_path"

    if [ -z "$template_name" ]; then
        echo "$PREFIX No template name provided, using default template."
        template_name="default"
    fi

    if [ ! -f "$TEMPLATE_DIR/$template_name.tex" ]; then
        echo "$PREFIX Error: Template '$template_name.tex' not found."
        exit 1
    fi

    if [ -f "$document_path" ]; then
        echo "$PREFIX Error: File '$document_path' already exists."
        echo "$PREFIX Aborting..."
        exit 1
    fi

    cp "$TEMPLATE_DIR/$template_name.tex" "$document_path" &> /dev/null
    echo "$PREFIX $EMOJI_SUCCESS Created document '$document_path' based on template '$template_name.tex'."
}

new_usage() {
    echo "<document_path> <template_name> : Create a new TeX document based on a template from the tpl directory."
}
