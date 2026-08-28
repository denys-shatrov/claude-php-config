#!/usr/bin/env bash
# Install the AI config baseline into a PHP project.
#   ./install.sh /path/to/project
# Existing files are never overwritten.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 /path/to/project" >&2
  exit 1
fi
if [ ! -d "$TARGET" ]; then
  echo "No such directory: $TARGET" >&2
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"
if [ "$TARGET" = "$SRC" ]; then
  echo "Target directory is the same as the source." >&2
  exit 1
fi

copied=0; skipped=0

copy_tree() {
  local from="$1" to="$2"
  while IFS= read -r rel; do
    local src="$from/$rel" dst="$to/$rel"
    if [ -e "$dst" ]; then
      echo "  = skipped (already there): .claude/$rel"
      skipped=$((skipped + 1))
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "  + .claude/$rel"
      copied=$((copied + 1))
    fi
  done < <(cd "$from" && find . -type f ! -name '.DS_Store' | sed 's|^\./||' | sort)
}

echo "Installing into $TARGET"
echo
copy_tree "$SRC/.claude" "$TARGET/.claude"

chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true

echo
echo "Copied: $copied, skipped: $skipped"

if [ "$skipped" -gt 0 ] && [ -f "$TARGET/.claude/settings.json" ]; then
  echo
  echo "NOTE: settings.json already existed and was left untouched."
  echo "Merge the hooks and permissions blocks by hand from:"
  echo "  $SRC/.claude/settings.json"
fi

cat <<'NEXT'

Next:
  1. cd into the project and run claude
  2. /php-onboard  — detect the stack and record the project's facts in CLAUDE.md
  3. Confirm the rules loaded: /context -> Memory files

Hooks start working once you trust the project folder.
Quality configs (phpstan, pint, rector, CI) live in .claude/templates/ and are
copied into the project root by hand, when you want them.
NEXT
