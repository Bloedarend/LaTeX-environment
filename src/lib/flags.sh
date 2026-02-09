declare -A FLAGS
POSITIONAL=()

parse_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --*=*)
        key="${1%%=*}"
        key="${key#--}"
        val="${1#*=}"
        FLAGS["$key"]="$val"
        ;;
      --*)
        key="${1#--}"
        if [ -n "${2:-}" ] && [[ "$2" != -* ]]; then
          FLAGS["$key"]="$2"
          shift
        else
          FLAGS["$key"]=1
        fi
        ;;
      -[a-zA-Z]*)
        chars="${1#-}"
        if [ "${#chars}" -gt 1 ]; then
          for ((i=0; i<${#chars}; i++)); do
            FLAGS["${chars:i:1}"]=1
          done
        else
          key="$chars"
          if [ -n "${2:-}" ] && [[ "$2" != -* ]]; then
            FLAGS["$key"]="$2"
            shift
          else
            FLAGS["$key"]=1
          fi
        fi
        ;;
      *)
        POSITIONAL+=("$1")
        ;;
    esac
    shift
  done
}

has_flag() {
  [[ ${FLAGS[$1]:-0} -eq 1 ]]
}

get_flag() {
  echo "${FLAGS[$1]:-}"
}
