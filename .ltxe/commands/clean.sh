#!/bin/bash

CLEAN_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CLEAN_COMMAND_DIR/../globals.sh"

clean_aliases=(c)

clean() {
    echo "$PREFIX Cleaning project directories..."

    mkdir -p "$PACKAGE_DIR"
    mkdir -p "$DOCUMENT_DIR"
    mkdir -p "$INCLUDE_DIR"
    mkdir -p "$FIGURE_DIR"
    mkdir -p "$BIBLIOGRAPHY_DIR"
    mkdir -p "$TEMPLATE_DIR"

    rm -rf "$PACKAGE_DIR"/mypackage
    rm -rf "$DOCUMENT_DIR"/my-document.tex
    rm -rf "$INCLUDE_DIR"/my-included-document.tex
    rm -rf "$FIGURE_DIR"/my-figure.png
    rm -rf "$TEMPLATE_DIR"/default.tex

    touch "$BIBLIOGRAPHY_DIR"/references.bib

    echo "$PREFIX $EMOJI_SUCCESS Project directories cleaned successfully."
}

clean_usage() {
    echo ": Clean the project directories by removing all default files."
}
