# Why these documentation standards

Generated documentation fails in predictable ways. This page explains which
standards were adopted to counter which failure, and what was deliberately left
out.

## The failures being addressed

**One page doing several jobs.** A README that opens with a tutorial, continues
into a full option reference, and ends by arguing for a design choice serves
none of those readers well. The beginner drowns in options; the person looking
up a flag reads past three paragraphs of rationale.

**Prose that restates the code.** "This function returns the user" adds nothing
a reader could not get faster from the signature. The information a reader
cannot derive — why it works this way, what breaks if you deviate — is exactly
what tends to be missing.

**Tone that hides uncertainty.** Marketing adjectives and words like "simply"
and "just" imply the reader's difficulty is unusual. They also let a writer
avoid saying whether something was actually verified.

## Structure: Diátaxis

[Diátaxis](https://diataxis.fr/) separates documentation by what the reader is
doing: learning (tutorial), accomplishing a goal (how-to), looking something up
(reference), or trying to understand (explanation). One page serves one of
those.

It was chosen over alternatives for two reasons. It is a decision procedure, not
a taste, so the agent can apply it: name the type first, and if you cannot, the
page has more than one job. And its adoption is broad enough that its vocabulary
is already familiar — Python, Canonical, and LangChain organise documentation
this way.

The cost is real. Content that used to sit in one file now spans four, and
readers who liked one long page have to follow links. In a small project the
split is premature, which is why `/docs` says not to create the tree until there
is a second page of a given type.

## Prose: the Google style guide

The [Google developer documentation style guide](https://developers.google.com/style)
supplies the sentence-level rules: second person, present tense, active voice,
sentence case headings, no "simply", no marketing adjectives.

Its advantage over a hand-written style guide is that it is specific enough to
check. "Write clearly" cannot be verified by anyone; "second person, present
tense" can. That matters more when the writer is a model, which will comply with
a concrete instruction and drift on an abstract one.

Microsoft's guide would have served nearly as well. Google's was chosen for
being shorter and more prescriptive on the points that go wrong most often.

## Decisions: ADRs

An [architecture decision record](https://adr.github.io/) captures one choice:
the context that forced it, the options weighed, what was decided, and what that
costs. Accepted records are never edited; a new one supersedes an old one.

The practice has been in the ThoughtWorks Technology Radar's Adopt ring since
2018, which is a long time for a documentation practice to survive.

Here it pays twice. It is history for people, and it is a guard against the
agent reopening settled questions. `00-core.md` instructs Claude to read
`docs/adr/` before proposing an architectural change, so a decision you made
last month survives into a session that has no memory of it.

The failure mode to avoid is writing records nobody reads. An ADR is worth
writing when the decision was expensive to reverse and a reasonable person could
have chosen otherwise. Routine implementation choices do not qualify.

## What was left out, and why

**Vale.** A prose linter with packaged Google and Microsoft styles would turn
these rules from a request into a guarantee, matching how the hooks treat code.
It was left out of the default because it needs a binary installed, and this
config must stay useful in a project where nothing can be installed. The rules
were written to match what Vale checks, so adding it later requires no rewriting.

**A changelog standard.** Keep a Changelog and semantic versioning matter when
something is released on a schedule. This config is copied, not versioned by
consumers, so the rule would sit unused in most projects that adopt it.

**PHPDoc conventions as a separate layer.** The essential part is already in
`10-php.md`: a comment explains why, and a docblock that restates the signature
is noise. The remaining detail — array shapes for static analysis — is better
learned from PHPStan's own errors than from a rule that would fire on every PHP
file.
