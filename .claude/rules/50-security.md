---
paths:
  - "**/*.php"
  - "**/*.blade.php"
  - "**/*.phtml"
  - "**/*.twig"
---

# Security

This checklist applies to every file you write and every file you read. If you
spot a violation in surrounding code, report it, but do not rewrite it unasked.

## Input and SQL

- Prepared statements or the query builder only. Never concatenate user input
  into SQL, even if the code next to it already does.
- Table and column names taken from user input go through an allowlist.
- `LIMIT`, `OFFSET`, and sort direction are validated too: cast to int, compare
  sort fields against a list of allowed values.

## Output

- Escape everything that reaches HTML. In Blade use `{{ }}`; `{!! !!}` only when
  the source is provably trusted, and always with a comment saying why.
- Encode JSON for attributes and `<script>` blocks properly rather than
  concatenating strings.
- Never expose stack traces, SQL, or config contents in production.

## Access control

- Every endpoint that changes data checks both authentication and permission on
  the specific object. An unguessable URL is not authorisation.
- State-changing forms carry a CSRF token.
- Mass assignment: explicit `$fillable` or a validated field list. Never hand
  `$request->all()` to a model.

## Data and files

- Uploads: verify the real MIME type and size, generate your own filename, store
  outside the web root or serve through a controller. Never trust the extension
  in the submitted name.
- Normalise paths built from input and verify the result stays inside the
  allowed directory.
- Never `unserialize` user-supplied data; use JSON.
- Do not interpolate user input into shell arguments; if unavoidable, escape it
  with the language's own facilities.

## Credentials and sessions

- Hash passwords with the framework's facility (bcrypt/argon2), never md5/sha1.
- Secrets come from the environment, not from code and not from the repository.
- Redirects driven by user input use an allowlist of paths.
- Never log passwords, tokens, card numbers, or personal data.
