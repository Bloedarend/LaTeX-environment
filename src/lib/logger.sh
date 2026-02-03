LOG_PREFIX="[LTXE]"

log_info() {
    echo -e "$LOG_PREFIX $*"
}

log_warn() {
    echo -e "$LOG_PREFIX \033[33mWARN: $*\033[0m" >&2
}

log_error() {
    echo -e "$LOG_PREFIX \033[31mERROR: $*\033[0m" >&2
}
