# Share one set of rules across many projects

By default `install.sh` copies everything, so each project gets a frozen snapshot.
Fix a rule here afterwards and the projects keep the old copy: the installer
never overwrites an existing file, so the fix does not reach them.

If you maintain several PHP projects, symlink the rules instead. `git pull` in
this repository then updates all of them at once.

## Link the rules

Clone this repository somewhere permanent, then install with `--link-rules`:

```bash
git clone https://github.com/denys-shatrov/claude-php-config ~/claude-php-config
cd ~/claude-php-config
./install.sh --link-rules /path/to/project
```

Each file in `.claude/rules/` becomes a symlink back to the clone. Skills,
hooks, the subagent, and `settings.json` are still copied, because you often
want to adjust those per project.

Verify it took:

```bash
ls -l /path/to/project/.claude/rules/
```

Every entry should point into your clone.

## Update every project

```bash
cd ~/claude-php-config && git pull
```

That is the whole update. The next session in any linked project reads the new
rules.

## Add rules that belong to one project only

The symlinks live inside a real `.claude/rules/` directory, so a project can
keep its own rules beside the shared ones:

```bash
cat > /path/to/project/.claude/rules/90-project.md <<'RULE'
---
paths:
  - "app/Billing/**"
---

# Billing

- Money is stored as integer cents. Never a float.
RULE
```

Re-running the installer leaves that file alone. This is why rules are linked
file by file rather than by replacing the whole directory.

## Change a shared rule for one project

Delete the symlink and put a real file in its place:

```bash
cd /path/to/project/.claude/rules
rm 21-laravel-http.md
cp ~/claude-php-config/.claude/rules/21-laravel-http.md .
```

The installer will not replace a real file with a link, so the local version
survives future runs. It also stops receiving updates, which is the trade you
just made.

## What this costs

**The clone must stay put.** Move or delete it and every linked project loses
its rules. Claude Code will not warn you; the rules simply stop loading.

**Teammates do not get them.** A symlink committed to git stores a path that
only exists on your machine. For a shared project, either commit real files
(plain `install.sh`) or have each person clone and link themselves.

**Updates arrive unannounced.** A `git pull` changes the rules in every project
at once, including ones you are not working on that day. Read the diff before
pulling if that matters.

## When to copy instead

Use plain `install.sh` for a project you hand to a team, for a client
repository that must be self-contained, and for anything where the config
should be pinned rather than tracking your latest thinking.
