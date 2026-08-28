---
paths:
  - "**/*.md"
  - "**/*.mdx"
  - "docs/**"
---

# Documentation

## One page, one type

Every documentation page is exactly one of four types. Name the type before you
write; if a page needs two, split it and link them.

| Type | Answers | Reader is |
|---|---|---|
| Tutorial | "teach me, I'm new" | learning by doing, needs a guaranteed outcome |
| How-to | "I need to accomplish X" | competent, has a specific goal |
| Reference | "what are the exact options" | looking something up, wants no prose |
| Explanation | "why is it built this way" | trying to understand, not to act |

Signals you have mixed them:

- A reference section that pauses to justify a design choice → move it to
  explanation.
- A tutorial that enumerates every flag → the reader is lost; move it to
  reference.
- A how-to that teaches a concept before the steps → link to the explanation.
- An explanation with copy-paste commands → that is a how-to.

A tutorial must end with something that works. A how-to must assume the reader
already knows the concepts. Reference is dry and complete. Explanation may
discuss alternatives and trade-offs, and is the only place that argues.

## Style

- Second person, present tense, active voice: "you run", not "the command
  should be run".
- Sentence case for headings. No trailing colons, no numbering unless order
  matters.
- Describe what the reader does, not what the system permits. "Run `x`", not
  "the system allows you to run `x`".
- Define an abbreviation on first use, then use it consistently.
- Link text names the destination. Never "click here" or "see this".
- Serial comma. One idea per sentence.
- Write out what a step does when it is not obvious from the command.

## Content

- Document why, not what. The code already states what.
- The valuable content is the part a reader cannot derive: traps, constraints,
  the reason a non-obvious choice was made, what breaks if you deviate.
- Do not document what tooling already shows: directory trees, dependency
  lists, generated signatures.
- Every example must run as written. Do not invent flags, paths, or output.
- Show real output when the reader needs to recognise success or failure.
- Update the documentation in the same change as the code. Documentation that
  has drifted is worse than none, because it is trusted.
- If you cannot verify a claim, do not write it. Mark unverified steps as
  unverified.

## Formatting

- No emoji in headings.
- Bold only for something genuinely dangerous or easy to miss. Bold on every
  paragraph means nothing is emphasised.
- Tag every code block with its language.
- Use a table to compare items across a shared set of attributes. Use a list
  for anything else.
- Keep line length reasonable in source; do not reflow files that use a
  different convention.
