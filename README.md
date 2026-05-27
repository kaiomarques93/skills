# Personal Agent Skills

A collection of [Cursor Agent Skills](https://cursor.com/docs/context/skills) — reusable instructions that teach the agent how to perform specialized workflows.

Each skill lives in its own directory with a `SKILL.md` file. The agent reads these when a task matches the skill's description or trigger phrases.

## Skills

| Skill | Description | Triggers |
|-------|-------------|----------|
| [crap-analysis](./crap-analysis/) | Full CRAP (Change Risk Anti-Patterns) analysis combined with Uncle Bob / Clean Code review. Flags risky methods and suggests prioritized refactors. Assumes 0% coverage when not provided. | `crap`, `crab`, `analyze crap`, `risk analysis`, `clean code review` |

## Installation

Install with the [skills CLI](https://github.com/vercel-labs/skills):

```bash
# Install all skills from this repo
npx skills@latest add kaiomarques93/skills

# Install a specific skill
npx skills@latest add kaiomarques93/skills --skill crap-analysis

# Install globally (available across all projects)
npx skills@latest add kaiomarques93/skills -g
```

Use `-a cursor` to target Cursor specifically. Run `npx skills@latest ls` to see what's installed.

## Usage

Once installed, mention the skill naturally in chat — for example:

- "Run a CRAP analysis on this file"
- "Clean code review on this module"
- "What's the CRAP score for these methods?"

The agent picks up the skill from its description and triggers.

## Adding a Skill

1. Create a directory: `my-skill/SKILL.md`
2. Add YAML frontmatter with at least `name` and `description`
3. Write the instructions the agent should follow
4. Add a row to the table above

See Cursor's [skill authoring guide](https://cursor.com/docs/context/skills) for the full format.

## Structure

```
skills/
├── README.md
└── crap-analysis/
    └── SKILL.md
```
