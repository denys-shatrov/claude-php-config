# Why the config is built this way

This page explains the reasoning behind the structure. You do not need it to use
the config; you need it to change the config without breaking its properties.

## The problem it solves

A single `CLAUDE.md` full of Laravel conventions is harmful in a project that is
not Laravel. It tells the agent to run `artisan make:*` in a codebase with no
`artisan`, and to move logic into Actions in a codebase with no autoloader. The
instructions are not merely useless; they are wrong, and they push the agent to
restructure code that should be left alone.

The obvious fix — maintaining one config per project type — fails for a
different reason. Configs drift. The one you copied six months ago is not the
one you improved since.

## Path-scoped rules

Claude Code loads a rule with a `paths:` field only when it reads a file
matching one of the patterns. A rule that never matches costs nothing: no
tokens, no noise, no influence.

That turns one directory into several behaviours. In a Laravel project, editing
`app/Http/Controllers/InvoiceController.php` pulls in the HTTP layer contract.
In a legacy project, editing `includes/db.php` pulls in the minimal-intervention
rules instead. Neither project sees the other's instructions.

Only `00-core.md` loads unconditionally, which is why it is kept short. Anthropic
recommends staying under 200 lines for always-on instructions, because adherence
falls as the file grows. Everything path-specific belongs in a scoped rule, and
everything procedural belongs in a skill.

## Instructions are a request; hooks are a guarantee

Rules are text delivered to the model. The model usually follows them and
sometimes does not, especially when they conflict with something else in
context. There is no enforcement in a rule file.

So the config splits by the strength the situation needs:

| Strength | Mechanism | Example |
|---|---|---|
| Guidance | `rules/`, `skills/` | prefer an Action over a fat controller |
| Refusal | `permissions.deny` | never read `.env` |
| Enforcement | `hooks/` | block `migrate:fresh`; fail on a broken test |

Anything phrased as "always" or "never" that actually matters is a hook. A rule
saying "never edit `.env`" is a hope. A `PreToolUse` hook returning exit code 2
is a fact.

This is also why the Stop hook exists. A model can convince itself the work is
done. A failing test suite is not a matter of opinion.

## Tracking edits without git

The Stop hook needs to know which files changed. The obvious source is
`git diff`, and the first version used it.

It was wrong. A freshly created Laravel project is not a git repository, and
neither are many legacy PHP codebases. In those projects the hook silently
verified nothing, which is the worst possible failure: the guarantee appears to
be in place and is not.

The `PostToolUse` hook now appends each edited PHP file to a list under
`TMPDIR`, keyed by a hash of the project path. The Stop hook reads that list and
clears it. This works without git, and it is more precise: it covers exactly
what this session touched, rather than everything uncommitted in the tree.

## Asymmetric risk between Laravel and legacy rules

The two rule sets are not equally dangerous when they fire wrongly.

Laravel rules leaking into legacy code is severe. They instruct the agent to use
Eloquent, artisan generators, and queues — none of which exist there — and to
restructure files toward a layout the project does not use.

Legacy rules leaking into a Laravel project are mild. They say to mirror the
surrounding style, to read the whole file first, and not to introduce new
frameworks. Cautious advice, wasted at worst.

That asymmetry justifies treating the two differently. Laravel globs are
restricted to paths that are Laravel-specific: `artisan`, `app/**`, `routes/**`,
`bootstrap/app.php`, and the named `database/` subdirectories. Generic
directory names such as `config/` and `database/` were removed, because legacy
projects have those too. See
[ADR 0001](../adr/0001-narrow-laravel-rule-globs.md).

Legacy globs are left broad, and one overlap is accepted: `public/**/*.php`
matches Laravel's `public/index.php`. Editing that file is rare, and the
consequence is a few lines of conservative advice.

## Why no Repository pattern, and other opinions

The rules take positions that are not universal: no Repository over Eloquent, an
abstraction only on second use, domain grouping inside the framework's own
directories rather than a `Modules/` tree.

These are defaults, not laws. `00-core.md` opens by stating that the conventions
of the existing code outrank everything in the config. A project that already
uses repositories consistently should keep using them; consistency inside one
codebase is worth more than any external opinion about layering.

The defaults exist because an agent with no default invents a different
structure each session, and the average of those inventions is worse than one
mediocre convention applied consistently.

## Laravel Boost is deliberately optional

[Laravel Boost](https://laravel.com/docs/13.x/boost) covers adjacent ground: it
generates guidelines from your installed packages and exposes MCP tools for the
database schema, routes, and logs.

It is not a dependency here, because this config must work in projects that will
never install a Composer package. Where Boost is available it is complementary,
not competing: Boost writes `CLAUDE.md` at the project root, while these rules
live in `.claude/rules/`. Both load.
