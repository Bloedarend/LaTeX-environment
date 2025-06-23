#!/bin/bash

COMMAND="ltxe"
PREFIX="[$COMMAND]"
PERSONAL_TREE="$HOME/texmf"

LIB_DIR="./lib"
DOCS_DIR="./doc"
OUT_DIR="./out"

help() {
    echo "$COMMAND - LaTeX environment"
    echo
    echo "Usage:"
    echo "  $COMMAND <command> [options]"
    echo
    echo "Commands:"
    echo "  help           Show this help message."
    echo "  ls             Show all installed personal packages."
    echo "  update (u)     Copy local packages from lib/ to personal tree and refresh TeX DB."
    echo "  build (b)      Build all .tex files in docs, output to out/"
}

ls() {
    if [ ! -f "$PERSONAL_TREE/ls-R" ]; then
        echo "$PREFIX No ls-R file found in $PERSONAL_TREE."
        echo "$PREFIX Please run '$COMMAND update' to generate it."
        return
    fi

    echo "$(basename "${USER}")@personal $PERSONAL_TREE"

    found=0
    current_dir=""
    while IFS= read -r line; do
        if [[ "$line" == *: ]]; then
            current_dir="${line%:}"
            continue
        else
            if [[ "$line" == *.sty ]]; then
                pkgname=$(basename "$line" .sty)
                if [[ "$pkgname" == "$(basename "$current_dir")" ]]; then
                    echo "└── $pkgname"
                    found=1
                fi
            fi
        fi
    done < "$PERSONAL_TREE/ls-R"

    if [ $found -eq 0 ]; then
        echo "└── (empty)"
    fi
}

update() {
    mkdir -p "$PERSONAL_TREE"
    mkdir -p "$LIB_DIR"

    if [ -d "$LIB_DIR" ]; then
        shopt -s nullglob
        lib_subdirs=("$LIB_DIR"/*/)
        shopt -u nullglob

        if [ ${#lib_subdirs[@]} -eq 0 ]; then
            echo "$PREFIX No packages found in $LIB_DIR, skipping copy."
        else
            echo "$PREFIX Copying local packages from $LIB_DIR to $PERSONAL_TREE ..."

            for pkgdir in "${lib_subdirs[@]}"; do
                pkgname=$(basename "$pkgdir")
                pkg_src="$pkgdir/tex/latex/$pkgname"

                if [ -d "$pkg_src" ]; then
                    pkg_dest="$PERSONAL_TREE/tex/latex/$pkgname"
                    echo "$PREFIX Copying $pkgname to $pkg_dest ..."

                    mkdir -p "$pkg_dest"
                    if command -v rsync >/dev/null 2>&1; then
                        rsync -a "$pkg_src/" "$pkg_dest/"
                    else
                        cp -r "$pkg_src/"* "$pkg_dest/"
                    fi
                else
                    echo "$PREFIX Warning: $pkgname does not contain tex/latex/$pkgname/"
                fi
            done
        fi
    fi

    echo "$PREFIX Updating TeX filename database ..."
    mktexlsr "$PERSONAL_TREE"

    echo "$PREFIX Done. Please restart your terminal session or IDE to see the updates."
}

build() {
    rm -R "$OUT_DIR"

    mkdir -p "$DOCS_DIR"
    mkdir -p "$OUT_DIR"

    texfiles=$(find "$DOCS_DIR" -type f -name "*.tex")

    if [ -z "$texfiles" ]; then
        echo "$PREFIX No .tex files found in $DOCS_DIR"
        exit 1
    fi

    for texfile in $texfiles; do
        echo "$PREFIX Building $texfile ..."

        relative_path="${texfile#"$DOCS_DIR"/}"
        output_subdir=$(dirname "$relative_path")
        mkdir -p "$OUT_DIR/$output_subdir"

        latexmk -pdf -interaction=nonstopmode -output-directory="$OUT_DIR/$output_subdir" "$texfile"

        if [ $? -ne 0 ]; then
            echo "$PREFIX Build failed for $texfile"
        else
            echo "$PREFIX Built $texfile successfully."

            pdfname="$(basename "$texfile" .tex).pdf"
            output_path="$OUT_DIR/$output_subdir"

            find "$output_path" -type f ! -name "$pdfname" \
                \( -name "*.log" -o -name "*.aux" -o -name "*.toc" -o -name "*.out" -o -name "*.fls" -o -name "*.fdb_latexmk" \) -delete
        fi
    done

    find "$DOCS_DIR" -type f ! -name "*.tex" | while read -r file; do
        rel_path="${file#"$DOCS_DIR"/}"
        dest_path="$OUT_DIR/$rel_path"
        mkdir -p "$(dirname "$dest_path")"
        cp "$file" "$dest_path"
    done
}

case "$1" in
    help|--help|-h)
        help
        ;;
    ls)
        ls
        ;;
    update|u)
        update
        ;;
    build|b)
        build
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$COMMAND help' to see available commands."
        exit 1
        ;;
esac
