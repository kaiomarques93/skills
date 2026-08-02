# Architecture Skills

Skills distilled from *Fundamentals of Software Architecture* (Mark Richards & Neal Ford), organized so the book's knowledge is usable on real projects — both greenfield and brownfield.

## The method

Each chapter's knowledge is used at three different **moments**, and the skills are organized by moment of use — not by the book's table of contents:

1. **Design time (greenfield)** — rules that shape decisions before code exists.
2. **Review time (brownfield)** — rules that find and prioritize refactors in existing code.
3. **Measurement time (once per project)** — turning abstract equations into deterministic, language-specific commands.

The per-chapter recipe:

1. Distill the chapter into compact **reference files** (rankings, equations, decision rules — no prose). These live in `references/` inside the skill that uses them.
2. Wire the knowledge into the **chapter skill** with two workflows: a brownfield audit and a greenfield design review.
3. Add any new metrics to **`arch-calibrate`**, the run-once-per-project skill that maps each metric to a deterministic measurement for the project's language and writes the recipe into the target repo.

This separation means the theory is written once, audits are reproducible (numbers come from the project's calibration file, not vibes), and adding a new chapter is mechanical.

## Chapter → skill map

| Book chapter | Skill(s) | Status |
|---|---|---|
| Ch. 3 — Modularity (cohesion, coupling, connascence) | [arch-modularity](./arch-modularity/), [arch-calibrate](./arch-calibrate/) | ✅ |
| Ch. 4–5 — Architecture characteristics | `arch-characteristics` (planned) | — |
| Ch. 6 — Measuring & governing (fitness functions) | extend `arch-calibrate` (planned) | — |
| Ch. 7+ — Components, styles, … | TBD | — |

## Cross-project usage

```bash
# install globally, available in every repo
npx skills@latest add kaiomarques93/skills --skill arch-modularity -g
npx skills@latest add kaiomarques93/skills --skill arch-calibrate -g
```

Then, per project:

1. Run **arch-calibrate** once — it writes `docs/architecture/calibration.md` into the project with deterministic measurement commands for that stack.
2. Run **arch-modularity** whenever — to audit existing code or review a proposed design. It reads the calibration file when present.
