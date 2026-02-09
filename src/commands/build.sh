cmd_name="build"
cmd_aliases="b"
cmd_help_msg="Build your documents, or a specific document."

cmd_run() {
  local pids=()
  local tex_files=()
  local failed_count=0
  local total_files=0

  local out_dir=""
  local target_file="$1"
  local ltxe_root=""

  if [ -n "$target_file" ]; then
    if [[ "$target_file" == /* ]]; then
      ltxe_root=$(find_root $(dirname "$target_file")) || {
        log_error "Is your file inside of a LaTeX environment?"
        exit 1
      }

      out_dir="$ltxe_root/$OUT_DIR"
    else
      ltxe_root=$(find_root) || {
        log_error "Are you inside of a LaTeX environment?"
        exit 1
      }

      out_dir="$ltxe_root/$OUT_DIR"

      target_file="$(realpath "$ltxe_root/$DOC_DIR/$target_file")"
      echo "$target_file"
    fi

    if [[ $target_file != *.tex ]]; then
      target_file="$target_file.tex"
    fi
    
    if [ ! -f "$target_file" ]; then
      log_error "File '$1' not found."
      return 1
    fi
    
    if [[ "$target_file" != *.tex ]]; then
      log_error "'$1' is not a .tex file."
      return 1
    fi
    
    if [[ "$target_file" != "$ltxe_root/$DOC_DIR"* ]]; then
      log_error "'$1' is not under a '$DOC_DIR' directory."
      return 1
    fi
    
    tex_files=("$target_file")
    total_files=1
  else
    ltxe_root=$(find_root) || {
      log_error "Are you inside of a LaTeX environment?"
      exit 1
    }

    out_dir="$ltxe_root/$OUT_DIR"

    if [ ! -d "$ltxe_root/$DOC_DIR" ]; then
      log_warn "No '$DOC_DIR' directory found."
      log_info "Exiting.."
      exit 0
    fi
    
    while IFS= read -r tex_file; do
      tex_files+=("$tex_file")
    done < <(find "$ltxe_root/$DOC_DIR" -type f -name "*.tex")
    
    total_files=${#tex_files[@]}

    if [ $total_files -eq 0 ]; then
      log_warn "No '.tex' files found."
      log_info "Exiting.."
      exit 0
    fi

    if [ -d "$out_dir" ] && [ "$(ls -A "$out_dir")" ]; then
      log_info "Clearing previous output."
      find "$out_dir" -mindepth 1 -delete
    fi
  fi

  export TEXMFHOME="$ltxe_root/$TEXMF_DIR"
  
  log_info "$(has_flag watch && echo "Watching" || echo "Building") $total_files file(s) in parallel."
  
  local result_file=$(mktemp)
  
  declare -A file_to_index
  for i in "${!tex_files[@]}"; do
    local tex_file="${tex_files[$i]}"
    local relpath="${tex_file#$ltxe_root/$DOC_DIR/}"
    file_to_index["$relpath"]=$i
  done
  
  build_file() {
    local tex_file="$1"
    local relpath="$2"
    local tex_base="$(basename "$tex_file")"
    local tex_name="${tex_base%.*}"
    local tex_dir=$(dirname "$relpath")
    local build_dir="$ltxe_root/$BUILD_DIR/$tex_dir"
    
    mkdir -p "$build_dir"
    
    (
      cd "$(dirname "$tex_file")" || exit 1

      if has_flag watch; then
        verbose latexmk -pdf -pvc -synctex=1 \
          -pdflatex="pdflatex -interaction=nonstopmode -shell-escape %O %S" \
          -outdir="$build_dir" \
          "$tex_base"

        return 0
      fi 
      
      log_info "Building '$relpath'."

      has_flag clean && (
        log_info "Clearing build files for ${tex_base}"
        find "$build_dir" -type f -name "${tex_name}.*" -delete
      ) 
      
      if verbose latexmk -pdf -synctex=1 \
          -pdflatex="pdflatex -interaction=nonstopmode -shell-escape %O %S" \
          -outdir="$build_dir" \
          "$tex_base"; then
        echo "$relpath:SUCCESS" >> "$result_file"

        local pdf_relpath="${relpath%.tex}.pdf"
        local pdf_dir="$out_dir/$pdf_relpath"

        mkdir -p "$(dirname "$pdf_dir")"
        cp "$build_dir/${tex_base%.tex}.pdf" "$pdf_dir"

        log_info "Build successful for '$relpath'."
      else
        echo "$relpath:FAILURE" >> "$result_file"
        log_error "Build failed for '$relpath'."
      fi
    )
  }
  
  export -f build_file
  export ltxe_root DOC_DIR BUILD_DIR
  
  if has_flag watch; then
    for tex_file in "${tex_files[@]}"; do
      relpath="${tex_file#$ltxe_root/$DOC_DIR/}"
      log_info "Watching $relpath"
      log_info "└── At: $ltxe_root/$BUILD_DIR/$relpath"
    done

    for tex_file in "${tex_files[@]}"; do
      verbose build_file "$tex_file" "$relpath" &
    done

    wait
    exit 0
  else 
    for i in "${!tex_files[@]}"; do
      local tex_file="${tex_files[$i]}"
      local relpath="${tex_file#$ltxe_root/$DOC_DIR/}"
      
      build_file "$tex_file" "$relpath" &
      pids+=($!)
    done
  fi

  if [ ! -n "$1" ]; then
    find "$ltxe_root/$DOC_DIR" -type f ! -name "*.tex" | while IFS= read -r file; do
      local relpath="${file#$ltxe_root/$DOC_DIR/}"
      local dest_dir="$out_dir/$(dirname "$relpath")"

      log_info "Copying file '$relpath'"

      mkdir -p "$dest_dir"
      cp "$file" "$dest_dir/"
    done
  fi
  
  for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null
  done
  
  log_info
  log_info "Results:"
  
  while IFS= read -r line; do
    results+=("$line")
  done < "$result_file"
  
  sorted_results=()
  for i in "${!tex_files[@]}"; do
    local tex_file="${tex_files[$i]}"
    local relpath="${tex_file#$ltxe_root/$DOC_DIR/}"
    for result in "${results[@]}"; do
      if [[ "$result" == "$relpath:"* ]]; then
        sorted_results+=("$result")
        break
      fi
    done
  done
  
  for i in "${!sorted_results[@]}"; do
    local result="${sorted_results[$i]}"
    local relpath="${result%:*}"
    local status="${result#*:}"
    
    [ $i -eq $(( ${#sorted_results[@]} - 1 )) ] && prefix="└──" || prefix="├──"
    
    if [ "$status" = "SUCCESS" ]; then
      log_info "$prefix ${GREEN}✓${NC} $relpath"
    else
      log_info "$prefix ${RED}✗${NC} $relpath"
      failed_count=$((failed_count + 1))
    fi
  done
  
  rm -f "$result_file"
  log_info
  
  if [ $failed_count -eq 0 ]; then
    log_info "All builds completed successfully."
    return 0
  else
    log_info "$failed_count build(s) failed."
    return 1
  fi
}
