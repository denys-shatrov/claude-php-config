#!/usr/bin/env bash
# PreToolUse (Bash|Write|Edit): blocks irreversible and dangerous operations.
# exit 2 = refusal, with a reason the agent will read.
set -uo pipefail

payload=$(cat)

field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r "$1 // empty" 2>/dev/null
  else
    printf '%s' "$payload" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
  fi
}

deny() { echo "Blocked by project policy: $1" >&2; exit 2; }

cmd=$(field '.tool_input.command' 'command')
file=$(field '.tool_input.file_path' 'file_path')

# --- File edits ---
if [ -n "$file" ]; then
  case "$(basename "$file")" in
    .env|.env.*)
      deny "editing $file. Secrets are changed by a human, by hand." ;;
  esac
  case "$file" in
    */database/migrations/*)
      # Creating new ones is fine; editing applied ones is not.
      [ -f "$file" ] && deny "editing the existing migration $file. Write a new migration instead." ;;
  esac
fi

# --- Commands ---
if [ -n "$cmd" ]; then
  case "$cmd" in
    *"migrate:fresh"*|*"migrate:refresh"*|*"migrate:reset"*|*"db:wipe"*)
      deny "this command destroys database data. Run it by hand if you really mean it." ;;
    *"rm -rf /"*|*"rm -rf ~"*|*"rm -fr /"*)
      deny "recursive delete outside the project." ;;
    *"git push --force"*|*"git push -f"*)
      deny "force push. Do it by hand if you are sure." ;;
    *"git reset --hard"*|*"git clean -fd"*)
      deny "this command discards uncommitted work." ;;
    *" > .env"*|*">.env"*|*"tee .env"*)
      deny "overwriting .env." ;;
  esac
  # Production, detected by a marker in the target name.
  if printf '%s' "$cmd" | grep -Eq '(^|[^a-zA-Z])(prod|production)([^a-zA-Z]|$)'; then
    case "$cmd" in
      *ssh*|*kubectl*|*docker*|*deploy*|*mysql*|*psql*|*rsync*|*scp*)
        deny "this command targets a production environment." ;;
    esac
  fi
fi

exit 0
