# AGENTS.md

This repository publishes standalone agent skills, distributed through
[skills.sh](https://skills.sh/balazsorban44/skills). Every skill here gets copied into
somebody else's repo, so nothing may assume this one.

## Layout

```
skills/
  <skill-name>/
    SKILL.md          # the skill itself — the only required file
    <script>.sh       # optional, only when a step is fiddly enough to automate
README.md             # human entry point: install + skill index
AGENTS.md             # this file — conventions for changing the repo
```

The directory name is the skill's name, and both must match the `name` in frontmatter.
The `skills` CLI discovers skills by walking this tree; there is no manifest to update.

## Writing a skill

Frontmatter carries two required fields:

```yaml
---
name: kebab-case-name
description: Use when <the situation that should trigger this> — <what it then does>.
---
```

The description is the only part of a skill loaded into an agent's context at all times.
It is what decides whether the skill fires, so lead with the triggering situation, name
each distinct case the skill handles, and cut anything the body already says.

The body is for what an agent cannot infer from the repo it is working in:

- **Steps in order, reference material after them.** An agent reads top-down and acts on
  the first thing it can act on.
- **State the target behaviour, not the prohibition.** "Pin the SHA" beats "don't use a
  branch URL" — a ban puts the banned thing in context and half-reads as an instruction.
- **Say the why once, where it changes a decision.** A constraint a reader would
  otherwise route around needs its reason attached; the rest does not.
- **No repo-specific paths, tools, or names.** Where a choice depends on the host repo,
  give the rule for choosing rather than one repo's answer.
- **Close with a checklist** when the skill has a definition of done worth verifying.

Keep it short enough that an agent reads all of it. Push anything only some runs need
into a sibling file and point at it from the body.

## Changing the repo

- Adding a skill also means adding a row to the table in `README.md`.
- Scripts are POSIX-friendly bash, `set -euo pipefail`, executable bit set, with a usage
  line at the top and a comment explaining what they do.
- Test a skill by running it in a real repo before pushing it.
