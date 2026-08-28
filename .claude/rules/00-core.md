# Working in this repository

## Rule of precedence

The conventions of the existing code outrank the rules in this file. Before
creating a new file, read 2-3 neighbouring ones and mirror how they are built:
layout, naming, error handling, comment style. If a rule below contradicts what
the project already does, follow the project and say so.

## Before writing code

- Look for an existing solution first: helper, service, trait, utility. A
  duplicate implementation is worse than an imperfect existing one.
- Determine the PHP version and stack from `composer.json`. Do not use syntax
  newer than the declared `require.php`.
- If a task touches more than three files, or has a fork in the road, propose a
  plan before writing code.

## Boundaries of a change

- Change only what the task requires. No drive-by refactors, renames,
  reformatting of other people's files, or dependency upgrades.
- Do not change public method signatures or API response shapes without being
  asked.
- A new entry in `composer.json` or `package.json` needs explicit approval.
- Schema changes go in a new migration or a new script. Migrations that have
  already run are not edited.
- Do not delete code as "unused" without searching the repository for callers.

## Commits

- Never add yourself as an author or co-author. No `Co-Authored-By` trailer, no
  `Claude-Session` line, no "Generated with" footer, no tool name in the body.
  The commit is authored by the person running the session.
- Write the message as that person would: take the format, tense, and prefix
  scheme from `git log`, not from a convention you prefer.
- Describe what changed and why. Do not mention that an agent was involved.
- Commit or push only when explicitly asked.

## Secrets and data

- Do not read or write `.env`, keys, certificates, or database dumps.
- Use placeholders in examples and tests, never real values.
- Do not embed real email addresses, tokens, or internal URLs in code.

## Reporting

- Report what actually happened: if tests were not run, say so; if they fail,
  show the output. Never claim "done" without verifying.
- If part of the task is unfinished or blocked, name it explicitly instead of
  glossing over it.
- If you find a problem outside the task, report it but do not fix it unasked.
