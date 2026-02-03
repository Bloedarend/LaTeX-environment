find_root() {
  local dir="${1:-$PWD}"

  while true; do
    if [ -f "$dir/$LOCK_FILE" ]; then
      echo "$dir"
      return 0
    fi

    [ "$dir" = "/" ] && { log_error "No $LOCK_FILE file found."; return 1; }

    dir=$(dirname "$dir")
  done
}
