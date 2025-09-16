#!/bin/bash

GLOBALS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMMAND="ltxe"
PREFIX="[$COMMAND]"

TEMPLATE_DIR="$(realpath "$GLOBALS_DIR/../tpl")"
PACKAGE_DIR="$(realpath "$GLOBALS_DIR/../pkg")"
DOCUMENT_DIR="$(realpath "$GLOBALS_DIR/../doc")"
INCLUDE_DIR="$(realpath "$GLOBALS_DIR/../inc")"
FIGURE_DIR="$(realpath "$GLOBALS_DIR/../fig")"
BIBLIOGRAPHY_DIR="$(realpath "$GLOBALS_DIR/../bib")"
LOG_DIR="$(realpath "$GLOBALS_DIR/../log")"
OUT_DIR="$(realpath "$GLOBALS_DIR/../out")"

EMOJI_SUCCESS="✅"
EMOJI_ERROR="❌"
