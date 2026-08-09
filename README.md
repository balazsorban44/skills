# Skills

[![skills.sh](https://skills.sh/b/balazsorban44/skills)](https://skills.sh/balazsorban44/skills)

Agent skills I use day to day, packaged so they work in any repository and on any coding
agent. Each one is a single Markdown file (plus a script where a step is fiddly enough to
deserve one), small enough to read in a minute and change to fit your own workflow.

## Install

```bash
npx skills@latest add balazsorban44/skills
```

The installer asks which skills to take and which agents to install them on, then copies
them into your repo as ordinary files you own. Pull later changes with
`npx skills update`.

Prefer to do it by hand? Copy a skill's directory into `.claude/skills/` (Claude Code),
`.agents/skills/`, or wherever your agent looks for skills.

## The skills

| Skill | What it does |
| --- | --- |
| [gh-pr-before-after](./skills/gh-pr-before-after/SKILL.md) | Puts before/after screenshots in a GitHub PR description: capture a matched pair, host the images as commit-pinned blobs so GitHub renders them without leaving binaries in the diff, and embed them collapsed under the summary. |

## Contributing

Layout, frontmatter, and writing conventions live in [AGENTS.md](./AGENTS.md) — it is
written for agents, and it is the shortest description of the house style for humans too.

## License

[MIT](./LICENSE)
