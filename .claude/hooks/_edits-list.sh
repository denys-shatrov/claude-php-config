# Path to the file tracking PHP files edited in this project.
# Stored outside the project so it never lands in the repository.
edits_list_path() {
  local root="${1:-$PWD}"
  local key
  if command -v shasum >/dev/null 2>&1; then
    key=$(printf '%s' "$root" | shasum | cut -c1-16)
  elif command -v md5sum >/dev/null 2>&1; then
    key=$(printf '%s' "$root" | md5sum | cut -c1-16)
  else
    key=$(printf '%s' "$root" | tr -c 'a-zA-Z0-9' '_' | tail -c 16)
  fi
  printf '%s/claude-php-edits-%s.list' "${TMPDIR:-/tmp}" "$key"
}
