# Extend the config

Use this when the setup does not yet cover something you keep repeating.

## Choose the right mechanism

Match the trigger to the mechanism. Putting a rule in the wrong layer is the
usual reason it stops working.

| What happened | What to add |
|---|---|
| Claude got the same convention wrong twice | a line in an existing `rules/` file |
| The instruction applies to part of the tree only | a new file in `rules/` with `paths:` |
| You keep typing the same multi-step prompt | a skill in `skills/` |
| It must happen every time, without the model deciding | a hook |
| A task floods the session with output you will not reread | a subagent in `agents/` |

## Add a path-scoped rule

Create `.claude/rules/NN-topic.md` with YAML frontmatter:

```markdown
---
paths:
  - "app/Domain/**"
  - "**/*.graphql"
---

# Topic

- One instruction per bullet.
- Concrete enough to check: "use `X`", not "handle this properly".
```

Number the file so it sorts near related rules. Rules with no `paths:` load in
every session, so leave the field out only when the instruction genuinely
applies everywhere.

Verify it loaded: start a session, open a matching file, then run `/context` and
look under **Memory files**.

## Add a skill

Create `.claude/skills/<name>/SKILL.md`:

```markdown
---
name: your-skill
description: What it does and when to use it. Claude matches this text against
  the task, so name the trigger, not just the subject.
---

# Title

Steps, in the order they must happen.
```

The description is the only part loaded at session start. If Claude never
invokes the skill on its own, the description is too vague about *when* to use
it.

## Add a hook

Write the script in `.claude/hooks/`, make it executable, and register it in
`.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/your-hook.sh" }
        ]
      }
    ]
  }
}
```

Three rules for a hook that will not get in your way:

- Read the event JSON from stdin, and exit 0 for anything you do not handle.
- Exit 0 when the tool you need is missing. This config must stay harmless in a
  project with no Composer.
- Exit 2 only to hand a problem back to Claude. The message on stderr is what it
  reads.

Test it before registering it:

```bash
echo '{"tool_input":{"file_path":"/tmp/x.php"}}' | bash .claude/hooks/your-hook.sh
echo "exit=$?"
```

Then add cases to `tests/run.sh` — at minimum the blocking case and the case
that must pass through untouched:

```bash
check "your-hook: blocks X" 2 your-hook.sh "$(json_cmd 'the dangerous command')"
check "your-hook: allows Y" 0 your-hook.sh "$(json_cmd 'the safe command')"
```

Verify the test would catch a regression: break the hook deliberately, confirm
the case fails, then restore it. A hook test that passes against a broken hook
is worse than no test, because it is trusted.

```bash
./tests/run.sh
```

## Record a project decision

Conventions specific to one project do not belong in this shared config. Put
them in that project's own `.claude/rules/`, or write an ADR with `/adr`.

Include the reasoning. "We rejected X because Y" stops the next session from
proposing X again; "do not use X" invites the argument a second time.

## Keep the always-on portion small

`00-core.md`, plus any rule without `paths:`, loads on every request. Keep the
total under roughly 200 lines. When it grows, move the path-specific parts into
scoped rules and the procedural parts into skills.

Check the current size:

```bash
wc -l .claude/rules/00-core.md
```

## Use it with other agents

Claude Code reads `CLAUDE.md`, not `AGENTS.md`. If the project also serves other
tools, keep `AGENTS.md` at the root and import it:

```markdown
@AGENTS.md
```
