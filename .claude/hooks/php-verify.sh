#!/usr/bin/env bash
# Stop: refuses to let the response finish while PHP files edited in this
# session fail their checks. Works without git.
# Disable during a long refactor: export CLAUDE_PHP_VERIFY=0
set -uo pipefail

payload=$(cat)
root="${CLAUDE_PROJECT_DIR:-$PWD}"
# shellcheck source=/dev/null
. "$(dirname "${BASH_SOURCE[0]}")/_edits-list.sh"

[ "${CLAUDE_PHP_VERIFY:-1}" = "0" ] && exit 0

# Loop guard: if we already blocked the stop once, do not block again.
if printf '%s' "$payload" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

cd "$root" 2>/dev/null || exit 0

list=$(edits_list_path "$root")
[ -f "$list" ] || exit 0

changed=$(sort -u "$list" 2>/dev/null | while IFS= read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done)
if [ -z "$changed" ]; then
  rm -f "$list"
  exit 0
fi

problems=""

# Run a tool over the changed files without eval: paths may contain spaces.
run_on_changed() {
  printf '%s\n' "$changed" | tr '\n' '\0' | xargs -0 "$@" 2>&1
}

# 1. Style — check only; the PostToolUse hook does the formatting.
if [ -x vendor/bin/pint ]; then
  out=$(run_on_changed vendor/bin/pint --test) \
    || problems+="Pint: style does not match the config."$'\n'"$out"$'\n'
fi

# 2. Static analysis of the changed files.
if [ -x vendor/bin/phpstan ] && { [ -f phpstan.neon ] || [ -f phpstan.neon.dist ]; }; then
  out=$(run_on_changed vendor/bin/phpstan analyse --no-progress --error-format=raw) \
    || problems+="PHPStan:"$'\n'"$out"$'\n'
fi

# 3. Tests. Pest 5 picks the affected ones itself when Test Impact Analysis is on.
if [ -x vendor/bin/pest ]; then
  out=$(vendor/bin/pest --compact 2>&1) || problems+="Tests are failing:"$'\n'"$out"$'\n'
elif [ -x vendor/bin/phpunit ]; then
  out=$(vendor/bin/phpunit 2>&1) || problems+="Tests are failing:"$'\n'"$out"$'\n'
fi

# Clear the session list either way; the same files are not re-checked.
rm -f "$list"

if [ -n "$problems" ]; then
  echo "Checks on the changed code did not pass. Fix them before finishing:" >&2
  printf '%s' "$problems" | tail -c 8000 >&2
  exit 2
fi

exit 0
