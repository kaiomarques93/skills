# Personal Agent Skills

A collection of [Cursor Agent Skills](https://cursor.com/docs/context/skills) — reusable instructions that teach the agent how to perform specialized workflows.

Each skill lives in its own directory with a `SKILL.md` file. The agent reads these when a task matches the skill's description or trigger phrases.

## Skills

| Skill | Description | Triggers |
|-------|-------------|----------|
| [crap-analysis](./crap-analysis/) | Full CRAP (Change Risk Anti-Patterns) analysis combined with Uncle Bob / Clean Code review. Flags risky methods and suggests prioritized refactors. Assumes 0% coverage when not provided. | `crap`, `crab`, `analyze crap`, `risk analysis`, `clean code review` |
| [guide](./guide/) | Guides the user step-by-step through any unfamiliar procedure (AWS, Play Store, App Store, Terraform, etc.), reading the codebase for context, waiting for confirmation before each step, and troubleshooting inline when something fails. | `guide me through`, `walk me through`, `step by step`, `teach me how to` |
| [ralph](./ralph/) | Autonomous dev loop — picks the next ready-for-agent GitHub issue, implements it with TDD, runs a CodeRabbit review, applies findings, grills the design, verifies requirements, commits, and closes the issue when satisfied. | `/ralph`, `run ralph`, `ralph loop`, `autonomous dev loop` |
| [ship-it](./ship-it/) | Audits the implementation against the agreed requirements, optionally commits, and closes the GitHub issue with a structured comment. | `ship this`, `ship it`, `wrap this up`, `close this issue`, `audit and close` |
| [to-review](./to-review/) | Publishes an integration-review issue for a batch of slice issues — defines upfront integration intent, links architecture docs, and gates the batch until slices are verified together. Run after `to-issues`. | `to-review`, `integration review`, `batch review`, `verify slices fit together` |
| [rate-difficulty](./rate-difficulty/) | Rates `ready-for-agent` issues by implementation difficulty — applies `difficulty:*` labels, posts scored rationale comments, and suggests a Cursor agent model for manual delegation. | `/rate-difficulty`, `rate difficulty`, `difficulty rating`, `score issues by difficulty` |

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
├── crap-analysis/
│   └── SKILL.md
├── guide/
│   └── SKILL.md
├── ralph/
│   └── SKILL.md
├── ship-it/
│   └── SKILL.md
├── to-review/
│   └── SKILL.md
└── rate-difficulty/
    └── SKILL.md
```
