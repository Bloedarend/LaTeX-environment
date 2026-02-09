#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/../build"
LIB_DIR="$SCRIPT_DIR/lib"
CMD_DIR="$SCRIPT_DIR/commands"

OUT="$OUT_DIR/ltxe.sh"

mkdir -p "$OUT_DIR"

{
echo '#!/usr/bin/env bash'
echo
echo 'set -e'
echo

for f in "$LIB_DIR"/*.sh; do
  [ -e "$f" ] || continue
  echo '# ---- lib: $(basename "$f") ----'
  cat "$f"
  echo
done

COMMANDS=()
ALIASES=()
HELP_MSGS=()

for f in "$CMD_DIR"/*.sh; do
  [ -e "$f" ] || continue

  unset cmd_name cmd_aliases cmd_help_msg cmd_run
  source "$f"

  if [ -z "${cmd_name:-}" ] || [ -z "${cmd_help_msg:-}" ]; then
    echo 'ERROR: $f must define cmd_name and cmd_help_msg' >&2
    exit 1
  fi

  COMMANDS+=("$cmd_name")
  ALIASES+=("${cmd_aliases:-}")
  HELP_MSGS+=("$cmd_help_msg")

  echo '# ---- command: $cmd_name ----'
  declare -f cmd_run | sed "s/^cmd_run/cmd_${cmd_name}_run/"
  echo
done

echo 'show_help() {'
echo '  echo "Usage: $0 <command> [args]"'
echo '  echo'
echo '  echo "Available commands:"'

count="${#COMMANDS[@]}"
for i in "${!COMMANDS[@]}"; do
  name="${COMMANDS[$i]}"
  aliases="${ALIASES[$i]}"
  msg="${HELP_MSGS[$i]}"

  [ "$i" -eq $((count - 1)) ] && prefix="└──" || prefix="├──"

  if [ -n "$aliases" ]; then
    echo "  echo \"  $prefix $name ($aliases): $msg\""
  else
    echo "  echo \"  $prefix $name: $msg\""
  fi
done

echo '}'
echo

echo 'main() {'
echo '  cmd="$1"; shift || true'
echo
echo 'parse_flags "$@"'
echo 'set -- "${POSITIONAL[@]}"'
echo
echo '  case "$cmd" in'

for i in "${!COMMANDS[@]}"; do
  name="${COMMANDS[$i]}"
  aliases="${ALIASES[$i]}"

  cases="$name"
  if [ -n "$aliases" ]; then
    cases="$cases|$(echo "$aliases" | tr ',' '|')"
  fi

  echo "    $cases) cmd_${name}_run \"\$@\" ;;"
done

echo '    help|-h|--help|"") show_help ;;'
echo '    *) echo "Unknown command: $cmd"; show_help; exit 1 ;;'
echo '  esac'
echo '}'
echo
echo 'main "$@"'

} > "$OUT"

chmod +x "$OUT"
echo "Built $OUT"
