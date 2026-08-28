#!/usr/bin/env bash
# PostToolUse (Write|Edit): syntax check plus formatting of a single file.
# Anything unexpected means a silent exit 0. This hook must never get in the way.
set -uo pipefail

payload=$(cat)
root="${CLAUDE_PROJECT_DIR:-$PWD}"
# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")/_edits-list.sh"

extract_path() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -r '.tool_input.file_path // empty' 2>/dev/null
  else
    printf '%s' "$1" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
  fi
}

file=$(extract_path "$payload")
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0
case "$file" in
  *.php) ;;
  *) exit 0 ;;
esac

# 1. Syntax. Works in any project, even without Composer.
if command -v php >/dev/null 2>&1; then
  if ! lint=$(php -l "$file" 2>&1); then
    echo "Syntax error in $file:" >&2
    echo "$lint" >&2
    exit 2   # hand it back to the agent to fix
  fi
fi

# 2. Remember the file for the final check in the Stop hook.
printf '%s\n' "$file" >> "$(edits_list_path "$root")" 2>/dev/null || true

# 3. Formatting, only if the tool exists in this project.
if [ -x "$root/vendor/bin/pint" ]; then
  "$root/vendor/bin/pint" --quiet "$file" >/dev/null 2>&1 || true
elif [ -x "$root/vendor/bin/php-cs-fixer" ]; then
  "$root/vendor/bin/php-cs-fixer" fix --quiet "$file" >/dev/null 2>&1 || true
fi

exit 0
