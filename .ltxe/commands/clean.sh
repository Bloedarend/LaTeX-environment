#!/bin/bash

CLEAN_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CLEAN_COMMAND_DIR/../globals.sh"

clean_aliases=(c)

clean() {
    mkdir -p "$PACKAGE_DIR"
    mkdir -p "$DOCUMENT_DIR"
    mkdir -p "$INCLUDE_DIR"
    mkdir -p "$FIGURE_DIR"
    mkdir -p "$BIBLIOGRAPHY_DIR"

    rm -rf "$PACKAGE_DIR"/mypackage
    rm -rf "$DOCUMENT_DIR"/my-document.tex
    rm -rf "$INCLUDE_DIR"/my-included-document.tex
    rm -rf "$FIGURE_DIR"/my-figure.png

    touch "$BIBLIOGRAPHY_DIR"/references.bib
}

clean_usage() {
    echo ": Clean the project directories by removing all default files."
}
