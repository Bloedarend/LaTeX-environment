#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for command_file in "$SCRIPT_DIR"/commands/*.sh; do
    source "$command_file"
done

print_usage() {
    echo "$PREFIX Usage: $0 <command> [args...]"
    echo "$PREFIX Available commands:"

    for file in "$SCRIPT_DIR"/commands/*.sh; do
        local functions=$(grep -oP '^\w+\s*\(\)' "$file" | sed 's/()//' | grep -v '_usage$')

        for function in $functions; do
            aliases=""
            usage=""

            if declare -f "${function}_usage" > /dev/null; then
                usage="$(${function}_usage)"
            fi

            if declare -p "${function}_aliases" &>/dev/null; then
                eval "local aliases=(\"\${${function}_aliases[@]}\")"
                if [ ${#aliases[@]} -gt 0 ]; then
                    aliases=" (${aliases[*]})"
                fi
            fi

            printf "  └── %s%s %s\n" "$function" "$aliases" "$usage"
        done
    done
    exit 1
}

if [ -z "$1" ]; then
    print_usage
fi

command="$1"
shift

if declare -f "$command" > /dev/null; then
    "$command" "$@"
else
    for file in "$SCRIPT_DIR"/commands/*.sh; do
        functions=$(grep -oP '^\w+\s*\(\)' "$file" | sed 's/()//' | grep -v '_usage$')
        for function in $functions; do
            if declare -p "${function}_aliases" &>/dev/null; then
                eval "aliases=(\"\${${function}_aliases[@]}\")"
                for alias in "${aliases[@]}"; do
                    if [ "$alias" = "$command" ]; then
                        "$function" "$@"
                        exit $?
                    fi
                done
            fi
        done
    done
    echo "$PREFIX Error: Command '$command' not found"
    print_usage
fi
