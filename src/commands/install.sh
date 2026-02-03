cmd_name="install"
cmd_aliases="i"
cmd_help_msg="Install packages from lock file or specific git repositories."

cmd_run() {
  local script_name="${0##*/}"
  local ltxe_root
  ltxe_root=$(find_root) || {
    log_error "Are you inside of a LaTeX environment?"
    exit 1
  }

  local pkg_dir="$ltxe_root/$PKG_DIR"
  local lock_file="$ltxe_root/$LOCK_FILE"
  
  mkdir -p "$pkg_dir"
  
  if [ -z "$1" ]; then
    log_info "Installing packages from lock file."
    
    if [ ! -f "$lock_file" ]; then
      log_error "No $LOCK_FILE file found."
      exit 1
    fi
    
    while IFS='|' read -r pkg_root_dir repo_url commit_hash; do
      [[ -z "$repo_url" || "$repo_url" =~ ^# ]] && continue
      
      local repo_name=$(basename "$repo_url" .git)
      local target_dir="$pkg_dir/$repo_name"
      
      log_info "Installing '$repo_name' from '$repo_url'."
      
      if [ -d "$target_dir" ]; then
        log_warn "Package '$repo_name' already exists. Ignoring.."
        # (
        #   cd "$target_dir" || exit 1
        #   git fetch origin 2>/dev/null
        #   if [ -n "$commit_hash" ]; then
        #     git checkout "$commit_hash" 2>/dev/null
        #   fi
        # )
      else
        if ! git clone "$repo_url" "$target_dir" 2>/dev/null; then
          log_error "Failed to clone repository '$repo_url'."
          continue
        fi
        
        if [ -n "$commit_hash" ]; then
          (
            cd "$target_dir" || exit 1
            git checkout "$commit_hash" 2>/dev/null
          )
        fi
        
        log_info "Package '$repo_name' installed successfully"
      fi
    done < "$lock_file"
    
  else
    # Install specific package
    local repo_url="$1"
    local commit_hash="$2"
    local repo_name=$(basename "$repo_url" .git)
    local target_dir="$pkg_dir/$repo_name"
    
    log_info "Installing package '$repo_name' from '$repo_url'"
    
    # Clone or update repository
    if [ -d "$target_dir" ]; then
      log_warn "Package '$repo_name' already exists. Updating..."
      (
        cd "$target_dir" || exit 1
        git fetch origin 2>/dev/null
        
        if [ -n "$commit_hash" ]; then
          git checkout "$commit_hash" 2>/dev/null
        else
          # Get latest commit if no hash provided
          commit_hash=$(git rev-parse HEAD 2>/dev/null)
        fi
      )
    else
      if ! git clone "$repo_url" "$target_dir" 2>/dev/null; then
        log_error "Failed to clone repository"
        return 1
      fi
      
      if [ -n "$commit_hash" ]; then
        (
          cd "$target_dir" || exit 1
          log_info "Checking out commit '$commit_hash'"
          git checkout "$commit_hash" 2>/dev/null
        )
      else
        # Get latest commit if no hash provided
        commit_hash=$(cd "$target_dir" && git rev-parse HEAD 2>/dev/null)
      fi
    fi
    
    log_info "Package '$repo_name' installed successfully"
    
    # Add to lock file if not already present
    if [ ! -f "$lock_file" ] || ! grep -q "^$repo_url|" "$lock_file"; then
      log_info "Adding '$repo_name' to lock file"
      
      # Create temporary file
      local temp_file=$(mktemp)
      
      # Add new entry to temp file
      if [ -f "$lock_file" ]; then
        cat "$lock_file" > "$temp_file"
        echo "$repo_url|$commit_hash" >> "$temp_file"
        
        # Sort alphabetically by repo_url
        sort "$temp_file" -o "$temp_file"
      else
        echo "$repo_url|$commit_hash" > "$temp_file"
      fi
      
      # Replace lock file
      mv "$temp_file" "$lock_file"
      log_info "Lock file updated"
    fi
  fi
  
  # Copy tex folders to TEXMF directory
  log_info "Copying package files to TEXMF directory..."
  
  for dir in "$pkg_dir"/*/; do
    if [ -d "$dir" ]; then
      local pkg_name=$(basename "$dir")
      
      # Check for texmf or tex directories
      if [ -d "$dir/texmf" ]; then
        log_info "Copying texmf from '$pkg_name'"
        cp -rf "$dir/texmf/"* "$ltxe_root/$TEXMF_DIR/" 2>/dev/null
      elif [ -d "$dir/tex" ]; then
        log_info "Copying tex from '$pkg_name'"
        cp -rf "$dir/tex/"* "$ltxe_root/$TEXMF_DIR/" 2>/dev/null
      fi
    fi
  done
  
  log_success "Installation complete"
}
