# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a public skills repository installable via:

```bash
npx skills@latest add kaiomarques93/skills
npx skills@latest add kaiomarques93/skills --skill crap-analysis
npx skills@latest add kaiomarques93/skills -g   # global install
```

The `skills` CLI (`npm: skills`) auto-discovers skills by scanning for `SKILL.md` files — no manifest required.

## Skill Structure

Each skill is a directory with a `SKILL.md` file, plus optional bundled resources (`references/`, `scripts/`, `assets/`) referenced from the body:

```
<skill-name>/
├── SKILL.md      ← YAML frontmatter + agent instructions
└── references/   ← optional supporting files (progressive disclosure)
```

Skills may be nested in grouping folders (the CLI discovers `SKILL.md` at any depth). Skills distilled from *Fundamentals of Software Architecture* live under `architecture/` — see `architecture/README.md` for the method before adding chapter skills there.

### Required frontmatter fields

```yaml
---
name: kebab-case-name        # identifier, lowercase + hyphens
description: one-liner       # shown in skill discovery
triggers: ["phrase", ...]    # natural-language phrases that activate the skill
---
```

`version` is not part of the official spec — omit it.

## Adding a Skill

1. Create `<skill-name>/SKILL.md` with the frontmatter above.
2. Write agent instructions in the body — be specific about output format and any formulas/conventions used.
3. Add a row to the table in `README.md`.

## CRAP Formula Convention

Coverage in `crap-analysis` is a **decimal (0.0–1.0)**, not a percentage:

```
CRAP(m) = CC(m)² × (1 - Coverage(m))³ + CC(m)
```

If coverage is unknown, assume `0.0` and label the column "unknown" in output tables.
