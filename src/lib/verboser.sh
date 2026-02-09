verbose() {
  if has_flag v || has_flag verbose; then
    "$@"
  else
    "$@" > /dev/null 2>&1
  fi
}
