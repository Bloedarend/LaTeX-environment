#!/bin/bash

BUILD_COMMAND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BUILD_COMMAND_DIR/../globals.sh"

build_aliases=(b)

build() {
    local target_file="$1"
    local find_query="*.tex"

    if [ -n "$target_file" ]; then
        if [[ "$target_file" = /* ]]; then
            if [[ "$target_file" != "$DOCUMENT_DIR"* ]]; then
                echo "$PREFIX $EMOJI_ERROR Given file must be inside $DOCUMENT_DIR" >&2
                exit 1
            fi
            tex_file="$target_file"
        else
            tex_file="$DOCUMENT_DIR/$target_file"
        fi

        if [ ! -f "$tex_file" ]; then
            echo "$PREFIX $EMOJI_ERROR File '$target_file' not found in $DOCUMENT_DIR" >&2
            exit 1
        fi

        find_query="${tex_file#$DOCUMENT_DIR/}"
    else
        echo "$PREFIX Cleaning old output."
        rm -rf "$OUT_DIR"
    fi

    rm -rf "$LOG_DIR"

    echo "$PREFIX Creating output directory."
    mkdir -p "$OUT_DIR"
    mkdir -p "$LOG_DIR"

    if [ -z "$target_file" ]; then
        echo "$PREFIX Copying all files from document directory to output directory."
        rsync -a "$DOCUMENT_DIR/" "$OUT_DIR/" > /dev/null

        echo "$PREFIX Looking for .tex files in $OUT_DIR."
    else
        echo "$PREFIX Preparing single file: $tex_file"
        local relative_path=${tex_file#$DOCUMENT_DIR}
        cp "$tex_file" "$OUT_DIR/$relative_path"
    fi

    local tex_files=$(find "$OUT_DIR" -type f -name "$find_query")

    if [ -z "$tex_files" ]; then
        echo "$PREFIX No .tex files found in $OUT_DIR."
        echo "$PREFIX Nothing to compile."
        exit 0
    fi

    if [ -n "$target_file" ]; then
        echo "$PREFIX Compiling single file: $tex_file"
    else
        echo "$PREFIX Compiling .tex files."
    fi

    local build_amount=0
    local build_failed=0

    if ! command -v latexmk >/dev/null 2>&1; then
        echo "$PREFIX $EMOJI_ERROR Could not compile." >&2
        echo "$PREFIX Latexmk is not installed."
        exit 1
    fi

    for tex_file in $tex_files; do
        relative_path="${tex_file#$OUT_DIR/}"
        sub_dir=$(dirname "$relative_path")
        tex_file_name=$(basename "$tex_file")
        base_name=$(basename "$tex_file" .tex)

        echo -ne "    └── $relative_path."

        (
            cd "$OUT_DIR/$sub_dir" || exit 1
            latexmk -pdf -pdflatex=lualatex -shell-escape -interaction=nonstopmode "$tex_file_name" > /dev/null 2>&1
        )

        failed=$?
        build_amount=$((build_amount + 1))

        mkdir -p "$LOG_DIR/$sub_dir"
        mv $(realpath "$OUT_DIR/$sub_dir/$base_name.log") $(realpath "$LOG_DIR/$sub_dir/$base_name.log") 2>/dev/null || true

        find "$OUT_DIR/$subdir" -type f \( \
            -name "${base_name}.tex" -o \
            -name "${base_name}.aux" -o \
            -name "${base_name}.toc" -o \
            -name "${base_name}.out" -o \
            -name "${base_name}.fls" -o \
            -name "${base_name}.fdb_latexmk" -o \
            -name "${base_name}.run.xml" -o \
            -name "${base_name}.blg" -o \
            -name "${base_name}.bcf" -o \
            -name "${base_name}.bbl" \
        \) -delete

        rm -rf "$OUT_DIR/$subdir/_minted-$base"

        if [ $failed -eq 0 ]; then
            echo -e "\r    └── $EMOJI_SUCCESS $relative_path."
        else
            build_failed=$((build_failed + 1))
            echo -e "\r    └── $EMOJI_ERROR $relative_path."
        fi
    done

    if [ $build_failed -eq 0 ]; then
        if [ -n "$target_file" ]; then
            echo "$PREFIX $EMOJI_SUCCESS File compiled successfully."
        else
            echo "$PREFIX $EMOJI_SUCCESS All .tex files compiled successfully."
        fi
    else
        if [ -n "$target_file" ]; then
            echo "$PREFIX $EMOJI_ERROR $target_file failed to compile."
            echo "$PREFIX See the log directory for more information."
        else
            echo "$PREFIX $EMOJI_ERROR $build_failed out of $build_amount .tex files failed to compile."
            echo "$PREFIX See the log directory for more information."
        fi
    fi
}

build_usage() {
    echo "[target_file] : Compile a target file or all .tex files from the document directory into the out directory."
}
