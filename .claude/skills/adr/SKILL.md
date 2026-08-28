---
name: adr
description: Record an architecture decision as a numbered ADR file in docs/adr, or find the existing record for a decision. Use when a choice with lasting consequences is made, when a previous decision is being reversed, or before proposing an architectural change.
---

# Architecture decision records

An ADR captures one decision: what forced it, what was considered, what was
chosen, and what that costs. It exists so nobody re-argues a settled question,
including you in a future session.

## When to write one

Write an ADR when the decision would be expensive to reverse and someone could
reasonably have chosen otherwise:

- Choosing between libraries, storage engines, protocols, hosting.
- A structural convention the whole codebase now depends on.
- Deliberately rejecting a common approach — the most valuable kind to record.
- Reversing an earlier decision.

Do not write one for a routine implementation choice, or for anything the code
makes obvious.

## Before proposing an architectural change

Read `docs/adr/` first. If a record covers the area, treat its decision as
standing. To go against it, say explicitly that you are proposing to supersede
ADR NNNN, and why the context has changed.

## Writing one

1. Find the next number: the highest existing file in `docs/adr/`, plus one.
   Start at `0001` if the directory is new.
2. Copy `.claude/templates/adr-template.md` to
   `docs/adr/NNNN-short-kebab-title.md`.
3. Fill it in. Rules that make an ADR worth having:

   - **Context** states the forces, not the conclusion. Someone who disagrees
     with the decision should still agree with the context.
   - **Options** includes the one you rejected, with its real merits. An ADR
     that strawmans the alternatives is worthless later.
   - **Decision** is one sentence in the active voice: "We use X."
   - **Consequences** includes what becomes harder. If nothing gets worse, you
     have not thought it through.

4. Keep it to one page. If it needs more, the decision is really several.

## After acceptance

An accepted ADR is never edited. To change the decision, write a new ADR and
set the old one's status to `superseded by NNNN`, adding a link. The history of
what you believed and when is the point.

## Bootstrapping an existing project

When a codebase already has years of implicit decisions, do not invent ADRs for
all of them. Write one only when a decision comes up again — someone asks "why
is it done this way", or a change is proposed that contradicts it. Record it
then, with the real historical context if you can establish it, and say in the
record that it documents an existing decision rather than a new one.
