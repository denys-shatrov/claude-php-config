---
name: legacy-refactor
description: Safely changing legacy PHP that has no tests and no framework - capture current behaviour, make a minimal edit, verify, isolate new code. Use for edits in old code and for incremental improvement of an inherited codebase.
---

# Editing legacy code

The risk here is not ugliness, it is breaking something invisible elsewhere. The
whole process is built around that.

## 1. Establish the blast radius

Before changing anything:

- Read the **whole** file, not the lines around your target. In legacy code,
  state is set higher up and pulled in through `include`.
- Find every use of what you are changing:
  `grep -rn "function_name" --include="*.php" .`
- Follow the `include` / `require` chain — which other pages pull this file in.
- Check for a copy of the same code nearby. Legacy codebases usually have one,
  and fixing a single copy creates a divergence.

Tell the user the blast radius before you edit: which pages are affected.

## 2. Capture the current behaviour

Editing blind is not acceptable. Pick whichever applies:

- If you can run tests, write a characterisation test that describes the
  behaviour **as it is today**, quirks included. It must pass before your change.
- If you cannot run tests, write a checklist: concrete inputs and expected
  outputs, edge cases included. Tell the user explicitly that verification is
  manual and what exactly needs checking.

Do not "fix" oddities you find along the way — something may rely on them.
Report them separately.

## 3. Make the smallest change

- The diff contains exactly what the task needs. No reformatting.
- Mirror the surrounding style: indentation, quotes, casing, naming.
- Do not introduce namespaces, autoloading, classes, or Composer without
  explicit approval.
- Where possible, put substantial new code in its own file with an explicit
  include, so it can later be replaced or removed whole.
- Do not change existing function signatures. If new behaviour is needed, add a
  new function or an optional trailing parameter.

## 4. Write new code safely

Even if the whole surrounding file does otherwise, **your** code uses prepared
statements instead of SQL concatenation, escapes output, checks permissions, and
never calls `unserialize` on user data.

Report a vulnerability in neighbouring code as a separate message: what you
found, why it is dangerous, how it is fixed, how much work it is. Do not rewrite
it silently.

## 5. Verify

- `php -l` on every file you touched.
- Walk the checklist from step 2.
- If the change touches a shared file, list the pages the user should open by
  hand.

## Incremental improvement

When the goal is health rather than a point fix, only the incremental approach
works: write new functionality in isolation and in a modern style, touch old
code when there is a reason, and keep the boundary between old and new explicit.
A big "rewrite it all" with no tests is the creation of new unverified code, not
a refactor. Propose small steps, each of which can be verified.
