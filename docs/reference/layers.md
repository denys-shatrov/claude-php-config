# Layers reference

Every file in `.claude/`, what it contains, and when it enters Claude's context.

## Rules

Rules with a `paths:` field load only when Claude reads a file matching one of
the patterns. A rule without `paths:` loads at the start of every session.

| File | Contents | Paths |
|---|---|---|
| `rules/00-core.md` | change boundaries, secrets, writing style, commits, reporting | none — always loaded |
| `rules/10-php.md` | types, style, language features, abstraction threshold | `**/*.php` |
| `rules/20-laravel.md` | layout, artisan, framework primitives, config, queues | `artisan`, `app/**`, `routes/**`, `bootstrap/app.php` |
| `rules/21-laravel-http.md` | controllers, form requests, policies, actions, DTOs, responses | `app/Http/**`, `app/Actions/**`, `app/Policies/**`, `app/Data/**`, `app/DTO/**`, `routes/**` |
| `rules/22-laravel-data.md` | models, queries, transactions, migrations, factories | `app/Models/**`, `app/Observers/**`, `app/Jobs/**`, `database/migrations/**`, `database/factories/**`, `database/seeders/**` |
| `rules/30-testing.md` | what to test, how to write it, what to avoid | `tests/**`, `**/*Test.php`, `phpunit.xml`, `Pest.php` |
| `rules/40-legacy.md` | minimal intervention, mirroring style, blast radius | `public/**/*.php`, `includes/**`, `include/**`, `inc/**`, `lib/**`, `libs/**`, `admin/**`, `classes/**`, `modules/**`, `**/*.phtml` |
| `rules/50-security.md` | input, output, access control, files, credentials | `**/*.php`, `**/*.blade.php`, `**/*.phtml`, `**/*.twig` |
| `rules/60-docs.md` | Diátaxis page types, prose style, content, formatting | `**/*.md`, `**/*.mdx`, `docs/**` |

## Skills

Skill descriptions load at session start. The body loads when you invoke the
skill or when Claude matches your task to its description.

| Command | Purpose |
|---|---|
| `/php-onboard` | survey an unfamiliar project, write its `CLAUDE.md` |
| `/ship` | pre-commit pipeline: style, analysis, tests, review, commit message |
| `/php-patterns` | design catalogue: situation to pattern, plus anti-patterns |
| `/laravel-feature` | end-to-end recipe for a feature, in dependency order |
| `/legacy-refactor` | safe change to code with no tests |
| `/php-review` | diff review checklist |
| `/docs` | write or audit documentation |
| `/adr` | record an architecture decision |

## Subagent

| File | Tools | Purpose |
|---|---|---|
| `agents/php-reviewer.md` | Read, Grep, Glob, Bash | independent review of a diff in isolated context |

## Hooks

| Event | Script | Behaviour |
|---|---|---|
| `PreToolUse` | `php-guard.sh` | blocks: editing `.env`, editing an already-existing migration, `migrate:fresh`/`refresh`/`reset`, `db:wipe`, `rm -rf /` or `~`, `git push --force`, `git reset --hard`, `git clean -fd`, overwriting `.env`, and ssh/kubectl/docker/deploy/mysql/psql/rsync/scp commands naming `prod` or `production` |
| `PostToolUse` | `php-post-edit.sh` | on `*.php` only: `php -l`, then records the file for the Stop check, then runs `vendor/bin/pint` or `vendor/bin/php-cs-fixer` if present |
| `Stop` | `php-verify.sh` | on files edited this session: `pint --test`, PHPStan if a `phpstan.neon` exists, then the full Pest or PHPUnit suite |

`php-post-edit.sh` exits 0 for any file that is not `.php`. Every hook exits 0
when the tool it needs is absent.

### Exit codes

| Code | Meaning |
|---|---|
| 0 | passed, or nothing to do |
| 2 | blocked or failed; the message goes back to Claude to act on |

### Environment variables

| Variable | Effect |
|---|---|
| `CLAUDE_PHP_VERIFY=0` | disables the Stop hook |
| `CLAUDE_PROJECT_DIR` | project root; set by Claude Code |
| `TMPDIR` | where the session's edited-file list is stored |

## Templates

Copied into a project by hand; the installer does not place them.

| File | Purpose |
|---|---|
| `templates/phpstan.neon` | Larastan config, level 5 |
| `templates/phpstan-legacy.neon` | level 1 with a baseline, for existing code |
| `templates/pint.json` | Laravel preset with strict types and sorted imports |
| `templates/rector.php` | modernisation sets, dry-run first |
| `templates/github-workflow-quality.yml` | CI running pint, phpstan, tests |
| `templates/adr-template.md` | MADR-style decision record |

## Tests

`tests/run.sh` exercises the hooks against sample event payloads. Pure bash; it
needs `php` on the path for the syntax-check cases and nothing else.

```bash
./tests/run.sh          # everything
./tests/run.sh guard    # only cases whose name contains "guard"
```

Exits non-zero if any case fails. The suite is not copied into target projects;
it tests this repository.

## Files the installer writes

`install.sh` copies the whole `.claude/` tree and skips any file that already
exists. It sets the execute bit on `.claude/hooks/*.sh`. It writes nothing
outside `.claude/`.
