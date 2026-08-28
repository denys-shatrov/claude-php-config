#!/usr/bin/env bash
# Install the AI config baseline into a PHP project.
#   ./install.sh /path/to/project
#   ./install.sh --link-rules /path/to/project
# Existing files are never overwritten.
#
# --link-rules symlinks each rule file back to this repository instead of
# copying it, so `git pull` here updates every project at once. Skills, hooks
# and the subagent are still copied. See docs/how-to/share-rules-across-projects.md
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINK_RULES=0
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --link-rules) LINK_RULES=1 ;;
    -h|--help)
      echo "Usage: $0 [--link-rules] /path/to/project"
      exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--link-rules] /path/to/project" >&2
      exit 1 ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "Too many arguments: $1" >&2; exit 1
      fi
      TARGET="$1" ;;
  esac
  shift
done

if [ -z "$TARGET" ]; then
  echo "Usage: $0 [--link-rules] /path/to/project" >&2
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

copied=0; skipped=0; linked=0

# Symlink each rule file individually into a real rules/ directory, so the
# project can still add its own rules alongside the shared ones.
link_rules() {
  local from="$1" to="$2"
  mkdir -p "$to"
  local f base dst
  for f in "$from"/*.md; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    dst="$to/$base"
    if [ -L "$dst" ]; then
      echo "  = already linked: .claude/rules/$base"
      skipped=$((skipped + 1))
    elif [ -e "$dst" ]; then
      echo "  = skipped (real file present): .claude/rules/$base"
      skipped=$((skipped + 1))
    else
      ln -s "$f" "$dst"
      echo "  -> .claude/rules/$base"
      linked=$((linked + 1))
    fi
  done
}

copy_tree() {
  local from="$1" to="$2"
  while IFS= read -r rel; do
    local src="$from/$rel" dst="$to/$rel"
    # In link mode the rules directory is handled separately.
    if [ "$LINK_RULES" = "1" ] && case "$rel" in rules/*) true;; *) false;; esac; then
      continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
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
[ "$LINK_RULES" = "1" ] && echo "Rules will be symlinked to $SRC"
echo
copy_tree "$SRC/.claude" "$TARGET/.claude"
[ "$LINK_RULES" = "1" ] && link_rules "$SRC/.claude/rules" "$TARGET/.claude/rules"

chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true

echo
if [ "$LINK_RULES" = "1" ]; then
  echo "Copied: $copied, linked: $linked, skipped: $skipped"
  echo
  echo "Rules are symlinks into $SRC."
  echo "  - 'git pull' there updates this project's rules immediately."
  echo "  - Moving or deleting that directory breaks them."
  echo "  - Teammates cloning this project will not get the linked files."
else
  echo "Copied: $copied, skipped: $skipped"
fi

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
