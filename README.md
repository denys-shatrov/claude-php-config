# AI config baseline for PHP projects

A portable `.claude/` directory you can drop into **any** PHP project — from a
fresh Laravel install to legacy code with no Composer — to give Claude Code one
set of coding rules, an architectural contract, and automated checks.

```bash
./install.sh /path/to/project
cd /path/to/project && claude
/php-onboard          # once: detect the stack, record the facts in CLAUDE.md
```

Existing files are never overwritten. Running it again is safe.

---

## How it works

The config is layered. The point is that **Laravel rules never load in a project
without Laravel** — the `paths:` field in each rule file takes care of that. The
same `.claude/` behaves as a Laravel guide in a Laravel app, and as a careful
"don't break someone else's style" in an old codebase.

| File | Loads |
|---|---|
| `rules/00-core.md` | always — change boundaries, secrets, honest reporting |
| `rules/10-php.md` | when working with `*.php` — types, style, abstraction threshold |
| `rules/20/21/22-laravel-*.md` | only if `app/**` or `routes/**` exist |
| `rules/30-testing.md` | only when working in `tests/**` |
| `rules/40-legacy.md` | only in a legacy layout (`includes/`, `lib/`, `public/*.php`) |
| `rules/50-security.md` | for any PHP file or template |
| `skills/*` | on `/name`, or when a task matches the description |
| `agents/php-reviewer.md` | when an independent review is needed |
| `hooks/*.sh` | on lifecycle events, guaranteed |

### Skills

| Command | What it does |
|---|---|
| `/php-onboard` | surveys an unfamiliar project, writes its `CLAUDE.md` |
| `/ship` | pre-commit pipeline: style → analysis → tests → review → commit message |
| `/php-patterns` | "situation → pattern" catalogue and anti-patterns, for design work |
| `/laravel-feature` | end-to-end recipe for a new feature, in the right order |
| `/legacy-refactor` | safe edits in code with no tests |
| `/php-review` | diff review checklist |

### Hooks

| Event | What happens |
|---|---|
| `PreToolUse` | blocks `.env` edits, `migrate:fresh`, `git reset --hard`, force pushes, production targets |
| `PostToolUse` | `php -l` after every edit, then Pint or php-cs-fixer if present |
| `Stop` | refuses to finish while files edited this session fail style, analysis, or tests |

The list of edited files is maintained by the `PostToolUse` hook itself, so the
verification works in projects without git. Every hook exits quietly when a tool
is missing: in a project without Composer, only the syntax check remains.
Disable the Stop hook during a long refactor with `export CLAUDE_PHP_VERIFY=0`.

---

## Driving this setup

The distinction that matters: **text is a request, a hook is a guarantee.** The
model usually follows the rules in `rules/`, but it can depart from them.
Anything that must happen every time lives in `hooks/` and `permissions`.

The working loop this is all built for:

1. **Plan mode for anything non-trivial** (Shift+Tab twice). Approve the plan,
   then the code. Catching a wrong direction in a plan is cheaper than in 600
   lines.
2. **Small commits.** You review `git diff`, not files. One task, one commit that
   fits on a couple of screens.
3. **`/ship` before committing.** Runs the checks and calls an independent
   reviewer with fresh context.
4. **`/code-review` and `/security-review`** — built into Claude Code, for a
   second opinion on the branch.

### Close the feedback loop

The difference between "the agent writes code" and "the agent writes working
code" is whether it can check the result itself. Give it:

- a working test command (record it in `CLAUDE.md` via `/php-onboard`);
- access to the logs (`storage/logs`);
- **Laravel Boost** — an MCP server exposing the database schema, routes, logs,
  and semantic search over the ecosystem's documentation:
  ```bash
  composer require laravel/boost --dev && php artisan boost:install
  ```
  Boost writes its own `CLAUDE.md` at the project root; this layer lives in
  `.claude/rules/`, so they do not collide;
- **Chrome MCP** for UI work, so the agent can see its own markup and the browser
  console instead of guessing.

Without a feedback loop, an agent assumes rather than verifies.

### Quality configs

`.claude/templates/` holds starting points, copied into the project root by hand
so the installer cannot break existing settings:

- `phpstan.neon` — for Laravel, starting at level 5;
- `phpstan-legacy.neon` — for old code, via a baseline;
- `pint.json`, `rector.php`, `github-workflow-quality.yml`.

Static analysis and tests are the only things that catch errors a diff does not
show. Without them, the rest of this tuning buys you little.

---

## Extending it

- Claude got the same thing wrong twice → add a line to the right `rules/` file.
- A rule applies to only part of the codebase → a new file in `rules/` with
  `paths:`, rather than growing the always-on rules.
- You keep typing the same multi-step prompt → make it a skill in `skills/`.
- Something must happen every time, without the model deciding → a hook, not text.
- A decision specific to one project ("we rejected X because Y") → record it in
  that project's `.claude/rules/`, or the agent will reinvent what you rejected.

Keep the always-on portion (`00-core.md` plus any rule without `paths:`) under
roughly 200 lines: the longer it gets, the less reliably it is followed.

### Other agents

If the project is also used through other tools, keep an `AGENTS.md` at the root.
Claude Code does not read it directly, but it can be pulled in from `CLAUDE.md`:

```markdown
@AGENTS.md
```
