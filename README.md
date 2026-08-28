# AI config baseline for PHP projects

A portable `.claude/` directory you drop into any PHP project — a fresh Laravel
install or legacy code with no Composer — to give Claude Code one set of coding
rules, an architectural contract, and automated checks.

The rules adapt to the project on their own. Laravel instructions load only in a
Laravel layout; a codebase with no framework gets minimal-intervention rules
instead. A rule that does not match costs nothing.

## Install

```bash
./install.sh /path/to/project
```

Then open the project and record what the config cannot know about it:

```bash
cd /path/to/project
claude
```

In the session, run `/php-onboard`. It detects the stack, verifies the build and
test commands, and writes them to the project's `CLAUDE.md`.

Existing files are never overwritten, so running the installer again is safe.

## What you get

- **Rules** that load by path: PHP style and safety everywhere, Laravel
  architecture only in Laravel, minimal-intervention rules only in legacy code.
- **Skills** for the recurring work: `/ship` before a commit, `/laravel-feature`
  for a new endpoint, `/legacy-refactor` for code with no tests, `/docs` and
  `/adr` for documentation.
- **Hooks** that hold regardless of what the model decides: `.env` edits and
  destructive commands are blocked, every PHP edit is syntax-checked and
  formatted, and a response cannot finish while the tests fail.

Full list: [layers reference](docs/reference/layers.md).

## Using it day to day

1. Plan first for anything non-trivial. Cycle to plan mode with `Shift+Tab`,
   approve the plan, then let it write code.
2. Keep commits small. You review the diff, not the files.
3. Run `/ship` before committing: style, static analysis, tests, and an
   independent review in a fresh context.
4. Give the agent a way to check its own work — see
   [close the feedback loop](docs/how-to/close-the-feedback-loop.md).

## Documentation

| Page | Read it when |
|---|---|
| [Layers reference](docs/reference/layers.md) | you need the exact rules, paths, hooks, or exit codes |
| [Close the feedback loop](docs/how-to/close-the-feedback-loop.md) | the agent guesses instead of verifying |
| [Extend the config](docs/how-to/extend-the-config.md) | you want to add a rule, skill, or hook |
| [Why it is built this way](docs/explanation/design.md) | you are about to change the structure |
| [Why these writing standards](docs/explanation/writing-standards.md) | you want the reasoning behind Diátaxis, Google style, and ADRs |
| [Decision records](docs/adr/) | you want to know why something was settled the way it was |

## Tests

The hooks have their own suite, since a broken hook blocks your workflow:

```bash
./tests/run.sh
```

## Requirements

PHP on the path is enough. Pint, PHPStan, Pest, and PHPUnit are used when the
project has them and skipped when it does not, so the config stays harmless in a
codebase with no Composer.
