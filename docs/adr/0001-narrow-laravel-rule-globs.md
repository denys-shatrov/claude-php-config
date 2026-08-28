# 0001. Narrow Laravel rule globs to Laravel-specific paths

- **Status:** accepted
- **Date:** 2026-08-28

## Context

The config's central promise is that Laravel rules never load in a project that
is not Laravel. Path-scoped rules make that possible, but only if the patterns
match paths that Laravel projects have and others do not.

The initial patterns did not. `20-laravel.md` matched `config/**` and
`bootstrap/**`; `22-laravel-data.md` matched `database/**`. All three directory
names are common in PHP projects with no framework at all. Opening
`config/db.php` in a legacy codebase would have loaded instructions to call
`config()` instead of `env()`, to generate files with `artisan make:*`, and to
move work onto queues — none of which exist there.

A documentation audit surfaced this: the README stated the guarantee, and the
globs did not deliver it.

## Options considered

### Option A — Soften the claim in the documentation

Keep the patterns and describe the behaviour accurately: "Laravel rules load in
Laravel-shaped projects, and may load elsewhere."

Honest, and free. Rejected because the guarantee is the reason the design exists.
A config that leaks framework advice into legacy code is the problem this was
built to avoid, so weakening the promise means abandoning the goal.

### Option B — Detect the framework at session start with a hook

A `SessionStart` hook could look for `artisan` and `laravel/framework` in
`composer.json`, then enable or disable rule files accordingly.

Precise, and it would handle unusual layouts. Rejected as disproportionate: it
introduces state, a failure mode when the hook does not run, and a mechanism a
reader has to understand before they can trust which rules are active. Path
globs are visible in the file that they govern.

### Option C — Restrict the globs to Laravel-specific paths

Keep only patterns that a non-Laravel project is unlikely to have: `artisan`,
`app/**`, `routes/**`, `bootstrap/app.php`, and named `database/`
subdirectories.

## Decision

We restrict the Laravel globs to Laravel-specific paths, and we accept that
legacy globs stay broad.

The two directions of leakage are not equally harmful. Laravel rules in legacy
code actively mislead: they name tools that do not exist and push a
restructuring the project never asked for. Legacy rules in a Laravel project say
to mirror the surrounding style, read the whole file, and avoid introducing new
frameworks. That is conservative advice, wasted at worst.

Asymmetric consequences justify asymmetric strictness.

## Consequences

**Good:** the guarantee in the README is now true. A legacy project with
`config/` and `database/` directories no longer receives Laravel instructions.

**Bad:** `config/**` no longer triggers `20-laravel.md`, so its guidance on
`env()` versus `config()` does not load while editing a file under `config/`. It
still loads when editing `app/**` or `routes/**`, which is where the mistake is
actually made, so the loss is small but real.

A Laravel project with a non-standard layout — application code outside `app/`
— gets no Laravel rules. Such a project should add its own path-scoped rule.

The overlap in the other direction remains: `public/**/*.php` in
`40-legacy.md` matches Laravel's `public/index.php`. Accepted, per the reasoning
above.

**Follow-up:** if a false positive is reported in either direction, revisit
whether framework detection (Option B) has become worth its complexity.
