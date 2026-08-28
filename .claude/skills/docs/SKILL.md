---
name: docs
description: Write or revise project documentation using the Diataxis structure and the Google developer documentation style. Use when writing a README, a docs page, or a guide, and when auditing existing documentation for drift or mixed content types.
---

# Writing documentation

Two failure modes dominate: a page that mixes teaching with reference, and a
page that restates the code instead of explaining it. This skill exists to
prevent both.

## 1. Decide the type before writing

Name it out loud: tutorial, how-to, reference, or explanation. If you cannot
choose, the page has more than one job — split it.

| The reader is | Type | You must |
|---|---|---|
| new, wants to learn by doing | Tutorial | guarantee a working result, remove every choice |
| competent, has a goal | How-to | assume the concepts, give the shortest path |
| looking up a fact | Reference | be dry, complete, and consistent in shape |
| trying to understand | Explanation | give context, alternatives, trade-offs |

## 2. Find the audience's actual question

Write the one question this page answers, in the reader's words, before the
first heading. If you cannot phrase it, you do not yet know what to write.

Then cut everything that does not serve that question. Most weak documentation
is not wrong; it is padded.

## 3. Write

Apply `rules/60-docs.md`. The parts most often violated:

- Lead with the answer, not with background.
- Second person, present tense, active voice.
- No "simply", "just", "easily". No marketing adjectives.
- Document why, not what.
- Do not paste a directory tree or a dependency list; tooling shows those.

## 4. Verify every example

Run the commands. Paste real output, not invented output. If something cannot
be run here, label it unverified and say why — never present a guess as a
working example.

Check that referenced files, flags, and paths actually exist:

```
git grep -n "<flag or path>" -- <where it should be>
```

## 5. Audit mode

When asked to review existing documentation rather than write new pages, report
findings in this order:

1. **Wrong** — statements that contradict the code. These are defects; name the
   file and line that disproves each one.
2. **Stale** — describes behaviour that existed but no longer does.
3. **Mixed type** — a page doing two jobs, with the proposed split.
4. **Padding** — sections that answer no question a reader has.

Do not report style nits during an audit unless the user asked for a style
pass. Wrong beats ugly.

## Where things go

- `README.md` — what this is, who it is for, how to start. One screen if
  possible. Links out; does not contain everything.
- `docs/how-to/` — task-shaped guides, named by the task.
- `docs/reference/` — the exact facts.
- `docs/explanation/` — why the system is like this.
- `docs/adr/` — decisions and their consequences; use the `/adr` skill.

In a small project, do not create the tree until there is a second page of that
type. One good README beats an empty structure.
