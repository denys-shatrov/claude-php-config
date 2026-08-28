---
name: ship
description: Pre-commit pipeline for a PHP project - formatting, static analysis, tests, independent review of the diff, and a ready commit message. Run before committing an agent's work.
---

# /ship — verify and prepare a change

The single step between "the agent wrote code" and "the code is in the
repository". The goal is to give the user grounds to trust the diff without
reading every line.

Do not commit or push anything without being told to.

## 1. What changed

```
git status --short
git diff --stat
```

If nothing changed, say so and stop.

If the change is larger than ~400 lines, or spans unrelated areas, propose
splitting it into several commits and show exactly how.

## 2. Automated checks

Run only what the project has. A missing tool is not a failure, but mention it
in the summary.

| Check | Command |
|---|---|
| Syntax | `php -l` on the changed files |
| Style | `vendor/bin/pint --dirty`, else php-cs-fixer |
| Analysis | `vendor/bin/phpstan analyse <changed files>` |
| Tests | `vendor/bin/pest` or `vendor/bin/phpunit` |

Fix failures immediately and re-run. Do not move on with failing tests. If you
cannot fix something, stop and explain precisely what is broken.

## 3. Independent review

Run the `php-reviewer` subagent over the diff. The fresh context matters here:
the author of a change systematically fails to see its flaws.

Split the findings into two groups and show them:

- **Fixing now** — real defects: security, N+1, swallowed errors, wrong logic, a
  new branch with no test.
- **Your call** — taste and judgement. Do not act on these unasked.

## 4. Test coverage of new behaviour

Check honestly: does every new branch of behaviour have a test? If not, either
write it or state plainly that the coverage is missing and why.

## 5. Documentation

Did this change alter behaviour a reader relies on — a command, a config key, an
endpoint, a setup step? If so, the documentation change belongs in this commit,
not a later one. If a decision with lasting consequences was made, propose an
ADR via the `/adr` skill.

## 6. Summary

Print it compactly:

```
Changed: N files (+X / -Y)
Pint: ok | PHPStan: ok | Tests: 42 passed | Review: 2 findings fixed

What changed: <2-3 lines of substance, not a restatement of the diff>
Not covered by tests: <or "none">
Needs attention: <risks, manual steps, migrations, config changes>

Suggested commit:
  <type>(<scope>): <imperative description>
```

Take the commit message style from `git log`, not from your own preference.

Never sign the commit: no `Co-Authored-By`, no `Claude-Session` line, no
"Generated with" footer, and no mention of an agent in the body. The commit
belongs to the person running the session.
