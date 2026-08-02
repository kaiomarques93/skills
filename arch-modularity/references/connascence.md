# Connascence

Two components are **connascent** if a change in one requires a change in the other to keep the system correct (Meilir Page-Jones). Connascence refines "coupling" into named, rankable forms — it tells you *which* coupling to attack first and *what to turn it into*.

## Types, weakest → strongest

**Static** — visible in the source code:

| Rank | Type | Both sides must agree on… | Example | Detection checklist |
|---|---|---|---|---|
| 1 | **Name** (CoN) | the name of an entity | callers use `getUser()` | renames ripple — unavoidable, and fine |
| 2 | **Type** (CoT) | the type of an entity | param must be `int` | type changes ripple — fine in typed languages |
| 3 | **Meaning** (CoM) | the meaning of a value (convention) | `1` = success, `"ADMIN"` inline | magic numbers/strings, stringly-typed flags, duplicated literals |
| 4 | **Position** (CoP) | the order of values | 4th positional arg is `isRetry` | long positional param lists, tuple returns, CSV column order |
| 5 | **Algorithm** (CoA) | a particular algorithm | client and server hash a token the same way | duplicated hashing/validation/serialization logic on both sides |

**Dynamic** — only visible at runtime (all rank above every static form):

| Rank | Type | Both sides must agree on… | Example | Detection checklist |
|---|---|---|---|---|
| 6 | **Execution** (CoE) | order of execution | `init()` before `send()` or it breaks | temporal APIs, setters that must precede calls |
| 7 | **Timing** (CoTg) | timing of execution | race between two threads/requests | sleeps in tests, race-sensitive code, timeout-dependent logic |
| 8 | **Values** (CoV) | several values changing together | invariants across records; distributed writes | multi-table updates without a transaction, denormalized copies |
| 9 | **Identity** (CoI) | referencing the same instance | two modules must share one mutable object/queue | shared mutable singletons, same-instance requirements across boundaries |

## The three properties

- **Strength** — the rank above; how hard it is to refactor. Stronger = worse.
- **Locality** — how far apart the connascent parts are. The *same* connascence is worse the farther apart it is.
- **Degree** — how many parties share it. Position-coupling 2 callers is a smell; 50 callers is an incident.

## Rules

Page-Jones:

1. Minimize overall connascence by breaking the system into encapsulated elements.
2. Minimize any connascence that **crosses** encapsulation boundaries.
3. **Maximize** connascence **within** boundaries — strong forms are acceptable when local.

Jim Weirich's corollaries:

- **Rule of Degree** — convert high-degree forms into weaker forms.
- **Rule of Locality** — as distance increases, use weaker forms. Cross-service contracts should be name+type only; inside one class, algorithm connascence is fine.

## Severity scoring (used by the audit's refactor ranking)

```
locality multiplier: same class = 1 · same component = 2 · cross-component = 4 · cross-service = 8
severity = strength rank (1–9) × locality multiplier × degree (number of parties)
```

Sort findings by severity, descending. This encodes the book's graph: refactor strong, distant, widespread connascence first; leave weak or local forms alone.

## Downgrade table — every fix is a conversion to a weaker form

| From | To | How |
|---|---|---|
| Position | Name | named/keyword parameters, options object, DTO instead of tuple |
| Meaning | Name | named constants, enums, value types |
| Algorithm | Name | extract to one shared library/service; one authority, others call it |
| Execution | weaker static | make invalid orderings unrepresentable (builder that only yields a ready object, constructor injection) |
| Timing | Execution | explicit synchronization, queues, idempotency instead of races |
| Values | Name | single source of truth; transactions or a saga instead of parallel writes |
| Identity | Values/Name | pass IDs and look up, or route through a mediator, instead of sharing mutable instances |
| Type (dynamic langs) | — | schemas/type hints at boundaries turn hidden meaning/type risk into checked CoT |
