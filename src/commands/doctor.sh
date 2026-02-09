cmd_name="doctor"
cmd_aliases="d"
cmd_help_msg="Validate environment is set up correctly."

cmd_run() {
  log_info "Doctor Results:"

  if command -v latexmk >/dev/null 2>&1; then
    log_info "├── ${GREEN}✓${NC} latexmk found"
  else
    log_info "├── ${RED}✗${NC} latexmk not found"
  fi

  if command -v pdflatex >/dev/null 2>&1; then
    log_info "├── ${GREEN}✓${NC} pdflatex found"
  else
    log_info "├── ${RED}✗${NC} pdflatex not found"
  fi

  local script_path="$(realpath $0)"
  local tmp_dir=$(mktemp -d)

  cd "$tmp_dir"

  verbose "$script_path" init

  cat > "$tmp_dir/doc/doctor.tex" <<'EOF'
\documentclass{article}
\begin{document}
Doctor check
\end{document}
EOF

  if verbose "$script_path" build; then
    log_info "└── ${GREEN}✓${NC} test build succeeded"
  else
    log_info "└── ${RED}✗${NC} test build failed"
  fi

  rm -rf "$tmp_dir"
}

