---
name: php-onboard
description: Survey an unfamiliar PHP project and record its facts in the project CLAUDE.md. Run once after copying .claude/ into a new project, and again whenever the stack or the run commands change.
---

# Onboarding a PHP project

Goal: in one pass, determine the stack and the working commands, then write them
to `./CLAUDE.md` so future sessions do not rediscover them.

The rules in `.claude/rules/` describe **how to write code**. This skill adds
what the template cannot know: **what this particular project is**.

## Step 1. Reconnaissance

Gather facts; do not assume:

- `composer.json` — required PHP version, framework, key packages, the `scripts`
  section. Is there `laravel/framework`, `symfony/*`, nothing at all?
- `php artisan about`, if an `artisan` file exists.
- Quality tooling: `vendor/bin/{pint,php-cs-fixer,phpstan,psalm,pest,phpunit,rector}`,
  and the configs `phpstan.neon*`, `pint.json`, `.php-cs-fixer*`, `phpunit.xml*`,
  `rector.php`.
- How it runs: `docker-compose.yml`, `Dockerfile`, `Makefile`, `.ddev/`, Sail,
  Herd, Valet, or plain apache/nginx.
- Frontend: `package.json` — bundler, scripts, Inertia/Livewire/Blade.
- CI: `.github/workflows/`, `.gitlab-ci.yml` — which checks are mandatory.
- Code layout: where the logic actually lives. In legacy code, where the entry
  points are and how files are included.
- `git log --oneline -30` plus the diffstat of the last few commits, to see
  commit style and which areas are active.

## Step 2. Decide the mode

- **Laravel** — `artisan` and `laravel/framework` present. Rules `20/21/22` are
  live.
- **Another framework** — the Laravel rules do not apply; record that
  framework's conventions, as found in the code, in CLAUDE.md.
- **Legacy, no framework** — rules `40` are live. Note this explicitly.

## Step 3. Verify the commands

Never record a command in CLAUDE.md that you have not run. Install dependencies
and run the tests if that is safe and quick. If a command does not work, record
it as unverified and explain why.

## Step 4. Write `./CLAUDE.md`

If the file exists, extend it; do not overwrite. Stay near 60 lines and include
only what cannot be read off the code quickly:

```markdown
# <Project name>

<One sentence: what this system is and who uses it.>

## Stack
PHP <version>, <framework and version>, <database>, <queue/cache>, <frontend>.

## Commands
- Install: ...
- Run locally: ...
- Tests: ...          # only commands you actually ran
- Style: ...
- Static analysis: ...

## Layout
<3-6 lines: where the business logic lives, entry points, how this project
differs from the framework's standard layout.>

## Gotchas
<What people trip over here: required environment variables, external services,
non-obvious conventions, areas that are dangerous to touch.>
```

Do not restate `.claude/rules/` — they are already loaded. Do not paste a
directory tree that `ls` would show.

## Step 5. Propose next steps

Give the user a short list of what is worth enabling, with the benefit and the
cost. Do not act without approval:

- **Laravel** → Laravel Boost (`composer require laravel/boost --dev` then
  `php artisan boost:install`): MCP tools for database schema, routes, and logs,
  plus semantic search over the ecosystem's documentation.
- No static analysis → `phpstan.neon` from `.claude/templates/` (for legacy, the
  baseline variant, so you can start on existing code).
- No formatter → `pint.json` from `.claude/templates/`.
- No CI → `github-workflow-quality.yml` from `.claude/templates/`.
- Has a UI → Chrome MCP, so the agent can inspect its own markup and the browser
  console instead of guessing.

Finish by naming which `.claude/rules/` are active in this project and which will
never load because the matching paths do not exist.
