# Coupling — the Martin metrics

Measured per **component** (package/namespace/directory — whatever the project's calibration file defines as a component), not per class.

## Definitions

| Metric | Formula | Range | Meaning |
|---|---|---|---|
| **Ca** — afferent coupling | count of external components that depend **on** this one (incoming) | 0..n | how many would break if this changes |
| **Ce** — efferent coupling | count of external components this one depends **on** (outgoing) | 0..n | how many can break this |
| **I** — instability | `Ce / (Ce + Ca)` | 0.0–1.0 | 1.0 = nothing depends on it, free to change; 0.0 = heavily depended-upon, painful to change |
| **A** — abstractness | `abstract types / total types` (interfaces + abstract classes over all types in the component) | 0.0–1.0 | 1.0 = pure abstractions; 0.0 = fully concrete |
| **D** — distance from the main sequence | `|A + I − 1|` | 0.0–1.0 | how far the component sits from the ideal A/I balance |

Edge case: `Ce + Ca = 0` (isolated component) → I is `unknown`, not 0.

## The main sequence

The line **A + I = 1** is the ideal: a component should be exactly as abstract as it is stable.

- **Stable (low I) → must be abstract (high A).** Many things depend on it, so it should expose interfaces that rarely change.
- **Unstable (high I) → fine to be concrete (low A).** Nothing depends on it; abstraction there is ceremony.

```
A 1.0 ┃ Zone of           ╲
      ┃ USELESSNESS        ╲   ← main sequence (A + I = 1)
      ┃ (abstract, no       ╲
      ┃  dependents)         ╲
      ┃                       ╲
      ┃            ╲           ╲
      ┃  Zone of    ╲
      ┃  PAIN        ╲
  0.0 ┗━━━━━━━━━━━━━━━━━━━━━━━━━
      0.0            I         1.0
```

- **Zone of pain** (A≈0, I≈0): concrete and heavily depended-upon. Every change ripples. Classic residents: database schemas, shared utility/domain classes. Fix: extract interfaces at the boundary, invert dependencies.
- **Zone of uselessness** (A≈1, I≈1): abstract with no dependents. Speculative interfaces nobody implements against. Fix: delete or collapse into the concrete implementation.

## Interpretation bands for D

Pragmatic defaults (the book gives the formula, not thresholds):

| D | Verdict |
|---|---|
| ≤ 0.25 | healthy |
| 0.25–0.5 | watch — check the trend, not just the snapshot |
| > 0.5 | refactor candidate — name which zone it's drifting toward and the corresponding fix |

## Caveats

- These are **directional instruments, not grades**. A component in the zone of pain that never changes (a stable schema) may be acceptable debt — flag it, state the trade-off, don't reflexively demand refactoring.
- A only counts type-level abstraction; in languages without interfaces/abstract classes (Go pre-generics idioms, Python duck typing, JS) the calibration file must define what counts as "abstract" (e.g., protocol classes, exported interface types) or A is `unknown`.
