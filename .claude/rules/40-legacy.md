---
paths:
  - "public/**/*.php"
  - "includes/**"
  - "include/**"
  - "inc/**"
  - "lib/**"
  - "libs/**"
  - "admin/**"
  - "classes/**"
  - "modules/**"
  - "**/*.phtml"
---

# Legacy code

These paths indicate a project without a modern framework, or an old part of
one. Minimal-intervention mode applies.

## The main thing

Mirror the surrounding style down to indentation, quote characters, keyword
casing, and naming. After your edit the file should look as if its original
author made the change. Your opinion of good code is secondary here.

## Not without explicit approval

- Do not introduce Composer, autoloading, namespaces, a router, a template
  engine, or an ORM.
- Do not convert procedural code to classes and do not split files.
- Do not reformat the file: the diff should contain exactly what the task
  requires. A wholesale reformat hides the real change.
- Do not remove commented-out blocks or odd workarounds; there is usually a
  forgotten reason behind them. Ask first.
- Do not rename existing functions or variables.

## How to work

- Read the whole file before editing, not just the lines around your target. In
  legacy code, state is often set higher up the file or pulled in via `include`.
- Search the whole repository for callers of anything you change; signatures
  here have consequences in surprising places.
- Prefer putting substantial new code in its own file with an explicit include.
  That way it can later be replaced or removed in one move.
- With no tests available, capture the current behaviour before editing: write
  down the inputs and expected outputs, then check them afterwards. Tell the
  user the verification was manual.
- State the blast radius out loud: which other pages use this file.

## Security in legacy code

Your new code is always written safely: prepared statements, escaped output,
permission checks — even when the surrounding file does none of that.

If you find a vulnerability in nearby code, report it separately: what it is,
why it is dangerous, how it is fixed. Do not silently rewrite it alongside your
task.
