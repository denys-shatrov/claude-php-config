# Give the agent a way to check its own work

The difference between an agent that writes code and one that writes working
code is whether it can observe the result. Without a feedback loop it predicts
behaviour instead of testing it, and predictions are confident and often wrong.

This page lists the loops worth wiring up, cheapest first.

## Record a working test command

The single highest-value step. Run `/php-onboard`, which detects the stack and
writes the verified commands into the project's `CLAUDE.md`.

Verify the command yourself before trusting it:

```bash
vendor/bin/pest      # or vendor/bin/phpunit
```

If the suite cannot run locally — a missing service, a required fixture — say so
in `CLAUDE.md`. An agent that believes it can run tests, and cannot, reports
success it never checked.

Once tests run, the Stop hook enforces them: the response cannot finish while
they fail.

## Give it the logs

Point at the log location in `CLAUDE.md` so failures are read rather than
guessed:

```markdown
## Commands
- Application log: `tail -n 100 storage/logs/laravel.log`
```

Allow the read in `.claude/settings.json` to avoid a prompt each time:

```json
{ "permissions": { "allow": ["Bash(tail -n * storage/logs/*)"] } }
```

## Add Laravel Boost

For Laravel projects, [Boost](https://laravel.com/docs/13.x/boost) exposes the
database schema, the route table, the last error, and semantic search over the
ecosystem's documentation as MCP tools:

```bash
composer require laravel/boost --dev
php artisan boost:install
```

The agent then reads the real schema instead of inferring columns from model
code. Boost writes its own `CLAUDE.md` at the project root; the rules in
`.claude/rules/` are unaffected, and both load.

## Add a browser for UI work

Chrome MCP lets the agent open the page it just changed, read the console, and
see its own markup. Without it, front-end work is written blind and verified by
you.

This matters most for anything visual: layout changes, JavaScript errors, form
behaviour.

## Turn static analysis on

Tests catch what you thought to test. Static analysis catches the rest.

```bash
composer require --dev phpstan/phpstan larastan/larastan
cp .claude/templates/phpstan.neon .
vendor/bin/phpstan analyse
```

For a codebase with existing violations, start from the baseline variant so only
new code is held to the standard:

```bash
cp .claude/templates/phpstan-legacy.neon phpstan.neon
vendor/bin/phpstan analyse --generate-baseline
```

Once `phpstan.neon` exists, the Stop hook runs it on files edited in the
session.

## Close the loop in CI as well

Local hooks can be disabled; CI cannot be talked out of a failure.

```bash
mkdir -p .github/workflows
cp .claude/templates/github-workflow-quality.yml .github/workflows/quality.yml
```

Set the PHP version in that file to match `composer.json` before committing it.
