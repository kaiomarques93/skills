# Cohesion

How related the parts of a module are to one another. A module is only as cohesive as its **least**-related responsibility — classify by the worst type present.

## The 7 types, ranked best → worst

| Rank | Type | The parts are grouped because… | Typical smell |
|---|---|---|---|
| 1 | **Functional** | together they perform exactly one well-defined task; every part is essential | none — this is the target |
| 2 | **Sequential** | output of one part is input to the next | pipeline stages bundled in one module; acceptable, watch boundaries |
| 3 | **Communicational** | they operate on the same data | "everything that touches `Customer`" modules |
| 4 | **Procedural** | they must execute in a certain order but don't share data flow | `doStepOneThenTwo()` wrappers |
| 5 | **Temporal** | they run at the same time (init, shutdown) | `StartupManager` doing config + cache + logging |
| 6 | **Logical** | they are the same *kind* of thing, not the same task | `StringUtils`, `converters/` grab-bags |
| 7 | **Coincidental** | no relationship at all | `utils.js`, `misc/`, `common/` |

**Guidance:** 1–3 are acceptable module designs (3 with care). 4–7 mean the boundary is wrong: split by task, not by order, time, kind, or accident.

## LCOM — Lack of Cohesion of Methods

Structural proxy for cohesion: do the methods of a class share its fields? Methods clustering around **disjoint field sets** indicate the class is really N classes glued together.

### LCOM (Chidamber–Kemerer)

```
P = number of method pairs sharing NO fields
Q = number of method pairs sharing ≥ 1 field
LCOM = max(P − Q, 0)
```

Unbounded integer; 0 = cohesive. Hard to compare across classes of different sizes — prefer LCOM96b for reporting.

### LCOM96b (Henderson-Sellers variant, used in the book)

```
m      = number of methods
a      = number of attributes (fields)
μ(Aj)  = number of methods that access attribute j

LCOM96b = (1/a) × Σ over j of (m − μ(Aj)) / m
```

Range **0.0–1.0** (decimal, per repo convention). 0.0 = every method touches every field (fully cohesive); values approaching 1.0 = fields are barely shared (split candidate).

**Pragmatic bands** (defaults, not book canon): ≤ 0.4 fine · 0.4–0.7 inspect · > 0.7 likely split.

### Caveats — do not apply blindly

- DTOs, records, and config objects legitimately score high; skip them.
- Classes with no fields or one method are out of scope for LCOM.
- LCOM measures **structural** cohesion only. A class can score 0.0 and still be logically incoherent (or vice versa). The type classification above is the primary judgment; LCOM is supporting evidence.
