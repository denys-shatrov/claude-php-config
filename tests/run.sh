#!/usr/bin/env bash
# Test suite for the hooks. Pure bash, no dependencies beyond php for the
# syntax-check cases.
#
#   ./tests/run.sh          run everything
#   ./tests/run.sh guard    run only cases whose name contains "guard"
#
# Exits non-zero if any case fails, so it works in CI.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$ROOT/.claude/hooks"
FILTER="${1:-}"

pass=0; fail=0; skip=0
failed_names=()

# --- helpers ---------------------------------------------------------------

setup() {
  WORK=$(mktemp -d)
  export TMPDIR="$WORK/tmp"
  mkdir -p "$TMPDIR"
  export CLAUDE_PROJECT_DIR="$WORK/project"
  mkdir -p "$CLAUDE_PROJECT_DIR"
}

teardown() { [ -n "${WORK:-}" ] && rm -rf "$WORK"; }

# check <name> <expected-exit> <hook> <json-payload>
check() {
  local name="$1" want="$2" hook="$3" payload="$4"
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then
    skip=$((skip + 1)); return
  fi

  local out got
  out=$(printf '%s' "$payload" | bash "$HOOKS/$hook" 2>&1)
  got=$?

  if [ "$got" = "$want" ]; then
    printf '  ok   %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '  FAIL %s\n       expected exit %s, got %s\n' "$name" "$want" "$got"
    [ -n "$out" ] && printf '       output: %s\n' "$(printf '%s' "$out" | head -2 | tr '\n' ' ')"
    fail=$((fail + 1))
    failed_names+=("$name")
  fi
}

# assert <name> <condition-description>; caller sets $? via a preceding command
assert() {
  local name="$1" ok="$2"
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then
    skip=$((skip + 1)); return
  fi
  if [ "$ok" = "0" ]; then
    printf '  ok   %s\n' "$name"; pass=$((pass + 1))
  else
    printf '  FAIL %s\n' "$name"; fail=$((fail + 1)); failed_names+=("$name")
  fi
}

json_file() { printf '{"tool_input":{"file_path":"%s"}}' "$1"; }
json_cmd()  { printf '{"tool_input":{"command":"%s"}}' "$1"; }

# --- php-post-edit.sh ------------------------------------------------------

echo "php-post-edit.sh"
setup
P="$CLAUDE_PROJECT_DIR"

printf '<?php\n$a = 1;\n'   > "$P/valid.php"
printf '<?php\n$a = ;\n'    > "$P/broken.php"
printf '# note\n'           > "$P/note.md"

check "post-edit: valid php passes"          0 php-post-edit.sh "$(json_file "$P/valid.php")"
check "post-edit: broken php is handed back" 2 php-post-edit.sh "$(json_file "$P/broken.php")"
check "post-edit: non-php file is ignored"   0 php-post-edit.sh "$(json_file "$P/note.md")"
check "post-edit: missing file is ignored"   0 php-post-edit.sh "$(json_file "$P/gone.php")"
check "post-edit: empty payload is ignored"  0 php-post-edit.sh '{}'
check "post-edit: no vendor dir still works" 0 php-post-edit.sh "$(json_file "$P/valid.php")"

# The edited file must be recorded for the Stop hook.
LIST=$(find "$TMPDIR" -name 'claude-php-edits-*.list' 2>/dev/null | head -1)
grep -q "valid.php" "$LIST" 2>/dev/null
assert "post-edit: records the file for the Stop check" $?

# A file that failed the syntax check must not be recorded.
grep -q "broken.php" "$LIST" 2>/dev/null && r=1 || r=0
assert "post-edit: does not record a file that failed linting" $r

teardown

# --- php-guard.sh ----------------------------------------------------------

echo
echo "php-guard.sh"
setup
P="$CLAUDE_PROJECT_DIR"
mkdir -p "$P/database/migrations"
touch "$P/database/migrations/2026_01_01_create_users_table.php"

check "guard: blocks editing .env"                2 php-guard.sh "$(json_file "$P/.env")"
check "guard: blocks editing .env.local"          2 php-guard.sh "$(json_file "$P/.env.local")"
check "guard: blocks editing an applied migration" 2 php-guard.sh \
      "$(json_file "$P/database/migrations/2026_01_01_create_users_table.php")"
check "guard: allows creating a new migration"    0 php-guard.sh \
      "$(json_file "$P/database/migrations/2026_09_09_create_orders_table.php")"
check "guard: allows an ordinary php file"        0 php-guard.sh "$(json_file "$P/app/Models/User.php")"

check "guard: blocks migrate:fresh"      2 php-guard.sh "$(json_cmd 'php artisan migrate:fresh --seed')"
check "guard: blocks migrate:refresh"    2 php-guard.sh "$(json_cmd 'php artisan migrate:refresh')"
check "guard: blocks db:wipe"            2 php-guard.sh "$(json_cmd 'php artisan db:wipe')"
check "guard: blocks rm -rf /"           2 php-guard.sh "$(json_cmd 'rm -rf /')"
check "guard: blocks force push"         2 php-guard.sh "$(json_cmd 'git push --force origin main')"
check "guard: blocks git reset --hard"   2 php-guard.sh "$(json_cmd 'git reset --hard HEAD~1')"
check "guard: blocks git clean -fd"      2 php-guard.sh "$(json_cmd 'git clean -fd')"
check "guard: blocks ssh to production"  2 php-guard.sh "$(json_cmd 'ssh deploy@prod.example.com')"
check "guard: blocks mysql on prod host" 2 php-guard.sh "$(json_cmd 'mysql -h db.production.internal')"

check "guard: allows route:list"         0 php-guard.sh "$(json_cmd 'php artisan route:list')"
check "guard: allows migrate"            0 php-guard.sh "$(json_cmd 'php artisan migrate')"
check "guard: allows a normal test run"  0 php-guard.sh "$(json_cmd 'vendor/bin/pest --filter Invoice')"
# "products" must not trip the prod word-boundary check.
check "guard: 'products' is not 'prod'"  0 php-guard.sh "$(json_cmd 'docker run products-api')"
check "guard: empty payload passes"      0 php-guard.sh '{}'

teardown

# --- php-verify.sh ---------------------------------------------------------

echo
echo "php-verify.sh"
setup
P="$CLAUDE_PROJECT_DIR"
printf '<?php\n$a = 1;\n' > "$P/ok.php"

check "verify: no edit list means nothing to do" 0 php-verify.sh '{"stop_hook_active":false}'

# Loop guard: never block twice in a row.
printf '%s\n' "$P/ok.php" > "$TMPDIR/claude-php-edits-$(printf '%s' "$P" | shasum | cut -c1-16).list"
check "verify: stop_hook_active short-circuits"  0 php-verify.sh '{"stop_hook_active":true}'

# Kill switch.
LISTFILE="$TMPDIR/claude-php-edits-$(printf '%s' "$P" | shasum | cut -c1-16).list"
printf '%s\n' "$P/ok.php" > "$LISTFILE"
CLAUDE_PHP_VERIFY=0 bash "$HOOKS/php-verify.sh" <<< '{"stop_hook_active":false}' >/dev/null 2>&1
assert "verify: CLAUDE_PHP_VERIFY=0 disables it" $?

# With no pint, phpstan, pest or phpunit present, there is nothing to run.
printf '%s\n' "$P/ok.php" > "$LISTFILE"
check "verify: exits clean when no tools exist"  0 php-verify.sh '{"stop_hook_active":false}'

# The list is consumed, so the same files are not re-checked next time.
[ -f "$LISTFILE" ] && r=1 || r=0
assert "verify: clears the edit list after running" $r

# A path in the list that no longer exists must not break the run.
printf '%s\n' "$P/deleted.php" > "$LISTFILE"
check "verify: tolerates a deleted file in the list" 0 php-verify.sh '{"stop_hook_active":false}'

teardown

# --- summary ---------------------------------------------------------------

echo
echo "----------------------------------------"
printf 'passed %d, failed %d' "$pass" "$fail"
[ "$skip" -gt 0 ] && printf ', skipped %d' "$skip"
echo
if [ "$fail" -gt 0 ]; then
  echo
  echo "failed cases:"
  printf '  - %s\n' "${failed_names[@]}"
  exit 1
fi
exit 0
