---
paths:
  - "tests/**"
  - "**/*Test.php"
  - "phpunit.xml"
  - "Pest.php"
---

# Tests

## What to write

- A new HTTP endpoint gets a feature test: the happy path, an authorisation
  failure, a validation failure.
- A new Action or pure function gets a unit test covering behaviour, edge cases,
  and error paths.
- Fixing a bug starts with a test that reproduces it and fails.

## How to write it

- Use Pest if the project has it, otherwise PHPUnit. Match the style of the
  existing tests.
- Name the test after the behaviour, not the method:
  `it fails when the invoice is already paid`.
- Structure as arrange / act / assert, separated by blank lines.
- Build data with factories and states, not hand-built arrays.
- Use `RefreshDatabase` for tests that touch the database.
- Assert something meaningful: status code plus response data or database state
  (`assertDatabaseHas`), not just a 200.

## What not to do

- No network access: fake external clients (`Http::fake()`, `Queue::fake()`,
  `Mail::fake()`).
- Do not test the framework; test your own logic.
- Do not write a test that still passes with the implementation commented out.
- Do not bend a test to match behaviour that is wrong; establish what is correct
  first.
- `sleep()` in a test means the design is wrong.

## Running

Run the affected tests while working (`--filter`, or Test Impact Analysis in
Pest 5); run the full suite before calling the task done.
