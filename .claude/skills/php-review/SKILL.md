---
name: php-review
description: Checklist for reviewing a PHP diff - security, correctness, database access, error handling, tests. Use when checking changes before a commit or when reading through someone else's code.
---

# Reviewing a PHP change

Work through this list. Report only what is genuinely a defect or a notable
risk: a long list of taste-based remarks devalues the important findings.

For every finding: **what is wrong → the input or state that breaks it → how to
fix it**. Without a failure scenario it is an opinion, not a finding.

## Security

- Is SQL assembled by concatenating user input?
- Is output written to HTML unescaped? In Blade, `{!! !!}` with an untrusted
  source?
- Does an endpoint change data without checking permission on the **specific
  object**?
- Does `$request->all()` reach a model or travel further down the chain?
- Uploads: are type, size, and name checked; is the path free of user input?
- Did a secret, token, or real internal URL land in the code?
- Is there a redirect driven by user input without an allowlist?

## Correctness

- Edge cases: empty collection, `null`, zero, negative, very long string,
  concurrent request.
- Is an error swallowed by an empty `catch` or by `@`?
- `==` where `===` is required?
- Money in a float? It should be integer minor units or a decimal string.
- Dates without timezone handling?
- Does an early `return` skip required cleanup or logging?

## Database

- **N+1**: a loop over a collection touching a relation, with no `with()`.
- Several related writes with no transaction.
- An HTTP call or a queue dispatch inside a transaction without `afterCommit`.
- `all()` or `get()` where `chunkById` / `lazy` is needed.
- Migration: is `down()` filled in, are there indexes on foreign keys and lookup
  columns, is an already-applied migration being edited?

## Architecture

- A controller doing the work instead of orchestrating it.
- Business logic in a model, in middleware, or in a route file.
- A new Repository over Eloquent, a `*Manager` dumping ground, an interface with
  one implementation.
- An abstraction introduced on its first use.
- Copy-pasted code instead of a call to something that exists.
- A hand-rolled equivalent of something the framework provides.

## Tests

- A new branch of behaviour with no test.
- A test asserting only the status code, not the data or the database state.
- A test that hits the network or depends on the current time.
- A test that would still pass with the implementation commented out.

## Compatibility

- A changed public method signature or API response shape.
- A config change that needs a manual deployment step, unmentioned.
- A new required environment variable missing from `.env.example`.
