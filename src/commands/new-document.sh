cmd_name="new-document"
cmd_aliases="nd"
cmd_help_msg="Create a new document from template."

cmd_run() {
  local document_name="$1" 
  local template_name="${2:-default.tex}"

  if [[ -z $document_name ]]; then 
    log_error "Missing argument: Document name not provided."
    exit 1
  fi

  if [[ $document_name != *.tex ]]; then
    document_name="$document_name.tex"
  fi

  local document="$DOC_DIR/$document_name"

  if [ -f "$document" ]; then
    log_error "Document with name '$document_name' already exists."
    log_info "Exiting.."
    exit 1
  fi

  if [[ $template_name != *.tex ]]; then
    template_name="$template_name.tex"
  fi

  local template="$TPL_DIR/$template_name"

  if [ ! -f "$template" ]; then
    log_error "Template with name '$template_name' does not exist."
    log_info "Exiting.."
    exit 1
  fi
  
  cp $template $document
}
