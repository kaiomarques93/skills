---
name: to-review
description: Publish an integration-review issue for a batch of slice issues — defines upfront integration intent, links big-picture docs, and gates the batch until slices are verified together. Use after to-issues, when the user says to-review, integration review, batch review, or verify slices fit together.
disable-model-invocation: true
---

# To Review

Publish an **integration review issue** for a batch of slice issues. Run this right after `to-issues` (`~/.agents/skills/to-issues/SKILL.md`), before agents implement the slices.

This skill does **not** run the audit. It plans the audit: integration intent, architecture anchors, slice inventory, and blocking relationships. An AFK agent (or you) works the review issue once the slices are closed.

The issue tracker and triage label vocabulary should have been provided to you — read `~/.agents/skills/setup-matt-pocock-skills/SKILL.md` if not.

## Skill paths

Related skills live at `~/.agents/skills/<name>/SKILL.md`. How you invoke them depends on the tool (`/to-issues` in Cursor, `$to-issues` in Codex, etc.) — when this skill tells you to use another skill, **read the file path**, not a particular invocation syntax.

## Process

### 1. Gather context

Work from session context first. If the user passes references (issue numbers, PRD link, batch name), use those.

**Infer the batch (hybrid):**

1. Session context — issues or PRD mentioned in this conversation
2. Issue tracker — children sharing a `Parent`, issues linked from a PRD issue body, or issues the user named
3. If anything is missing or ambiguous, ask the user to confirm or complete the list

Also collect **architecture anchors** from session context when present:

- Parent PRD issue (if any)
- `CONTEXT.md` or entries from `CONTEXT-MAP.md`
- Relevant ADRs (`docs/adr/`, or paths from `docs/agents/domain.md`)
- Any other big-picture doc the user or session referenced

If the big picture is unclear, ask **one question at a time** until you can write a meaningful integration intent. Do not guess at architectural invariants.

### 2. Draft integration intent

Synthesize **integration scenarios** — end-to-end paths and cross-slice touchpoints that must work when all slices land. Also list **architectural invariants** the combined implementation must respect (from PRD, ADRs, `CONTEXT.md`, or session decisions).

Examples:

- "Dry-run API persists run history and reads it back through the same PostgreSQL backing the live path"
- "Missing broker credentials fail at the adapter boundary, not settings validation"

This is what individual slice agents will not see while working in isolation.

### 3. Quiz the user

Present:

- **Batch**: slice issues in scope (with numbers/titles)
- **Blocked by**: which slices gate this review (default: all slices in the batch; show overrides if the user requested any)
- **Architecture anchors**: PRD, `CONTEXT.md`, ADRs, other docs
- **Integration scenarios**: numbered end-to-end paths
- **Architectural invariants**: bullets

Ask:

- Are the right slices in scope?
- Are the blocking relationships correct?
- Do the integration scenarios capture "put together correctly"?
- Anything missing from architecture anchors?

Iterate until the user approves.

### 4. Publish the integration review issue

Publish to the issue tracker with the template below. Apply the `ready-for-agent` triage label.

Publish **after** slice issues exist so real issue identifiers appear in **Blocked by** and **Slice inventory**.

### 5. Cross-link slice issues

On **each slice issue** in the batch, add a short comment:

```
Integration review: #<review-issue-number> — verifies this batch fits together after all slices close. This slice is a blocker for that review.
```

Do not modify slice issue bodies or labels.

---

## Integration review issue template

```markdown
## Parent

<PRD issue reference, if one exists — otherwise omit this section>

## Architecture anchors

- <PRD, CONTEXT.md, ADR, or other doc — one bullet per anchor with issue number or path>

## Slice inventory

- #<n> — <title>
- #<n> — <title>

## Integration intent

End-to-end scenarios that must hold when this batch is complete:

1. <scenario>
2. <scenario>

Architectural invariants:

- <invariant>
- <invariant>

## What to do

This issue is blocked until every issue listed under **Blocked by** is closed. When unblocked, run the integration audit below. Do not start early.

### Integration audit

1. **Slice audit** — For each slice in **Slice inventory**, verify acceptance criteria against code, tests, docs, migrations, and the slice's closing comment (see `~/.agents/skills/ship-it/SKILL.md` format).
2. **Integration audit** — Verify every scenario under **Integration intent** against the combined codebase. Run relevant tests or commands.
3. **Architecture audit** — Confirm **Architectural invariants** and **Architecture anchors** still hold in the implementation.
4. **Follow-up mining** — For each slice, read the full comment thread and closing comment. Extract every follow-up, deferred item, CodeRabbit skip, and out-of-scope note. See **Follow-up mining rules** below.

#### Follow-up mining rules

- Parse the **Follow-up issues** section of each slice's ship-it closing comment.
- **Contradiction flag** — If a slice says `None` (or "none from this slice") but the same bullet or comment describes deferred work, treat it as an undocumented follow-up and disposition it.
- **Vague deferral flag** — If deferred work does not name a target issue (`#N`), PRD section, or ADR, disposition it (usually **new-issue** `ready-for-human` or **absorb** into an open issue).
- **Cross-check** — If a slice deferred work to another issue in **Slice inventory**, verify that issue's implementation and closing comment actually addressed it.
- **Code vs comments** — If the combined codebase reveals gaps not mentioned in any slice closing comment, disposition those too. Do not rely on comments alone.

### AFK workflow (required)

This issue is labeled `ready-for-agent`. Complete it **autonomously** — do not stop to ask for human approval on findings or dispositions.

Work in this order:

1. Run the integration audit above.
2. **Disposition** every finding using the table below. Decide yourself; record rationale in your working notes.
3. **Publish follow-ups** — act on each disposition **before** closing this issue (step 4).
4. **PRD closure** (if **Parent** exists) — close the PRD via ship-it when high confidence; otherwise create a **PRD closure review** issue (`ready-for-human`) and leave the PRD open.
5. **Close this issue** — always read `~/.agents/skills/ship-it/SKILL.md` and close this issue. An integration review is an audit gate, not a container for open work. Open work lives in newly created issues.

**Never** leave this issue open with a "please approve" or "waiting for confirmation" comment.

### Follow-up disposition

For each finding, assign exactly one disposition:

| Disposition | When to use |
|-------------|-------------|
| **new-issue** | Needs tracked work — create an issue before closing this review |
| **defer** | Intentionally postponed and already covered by PRD Out of Scope, an ADR, or a named future milestone — record where and why; no issue needed |
| **absorb** | Fold into an existing open issue — comment on that issue with what to add |
| **dismiss** | Not actionable after cross-check — record why in this issue's closing comment |

### Publish follow-ups

Act on each disposition **before** closing this issue:

- **new-issue** — Create an issue. Label `ready-for-agent` for clear implementation work; `ready-for-human` for design ambiguity or product decisions. Use the same body style as `to-issues` slices (`~/.agents/skills/to-issues/SKILL.md` — What to build, Acceptance criteria, Blocked by). Reference this review issue and the originating slice in the new issue body.
- **defer** — Record in this issue's ship-it closing comment (and the PRD closing comment if closing the PRD). Do not create an issue.
- **absorb** — Comment on the target issue with what to fold in.
- **dismiss** — Record in this issue's ship-it closing comment only.

### PRD closure

<Include this section only when a Parent PRD exists.>

Audit the PRD's user stories and acceptance against the combined implementation.

- **High confidence** every in-scope story is met and no blocking doubts remain → close the PRD via `~/.agents/skills/ship-it/SKILL.md` with an audit comment. List any **defer** items and new issue numbers in the PRD closing comment.
- **Any ambiguity** — leave the PRD open. Create a **PRD closure review** issue (`ready-for-human`) listing open questions. Close **this** review issue anyway.

## Acceptance criteria

- [ ] Every slice in **Slice inventory** audited against its spec and closing comment
- [ ] Every **Integration intent** scenario verified, or gap recorded as follow-up
- [ ] **Architectural invariants** checked against the codebase
- [ ] Follow-ups mined (including contradiction and vague-deferral flags) and dispositioned
- [ ] All **new-issue** follow-ups published with correct triage labels
- [ ] PRD closed via ship-it (high confidence) OR PRD closure review issue created (`ready-for-human`)
- [ ] **This issue closed** via ship-it — always, regardless of follow-ups created

## Blocked by

- #<slice-issue>
- #<slice-issue>

Or adjusted per user override during the quiz.
```

---

## PRD closure review issue template

Use when the integration audit cannot close the PRD with high confidence:

```markdown
## Parent

<PRD issue reference>

## Context

Integration review #<n> completed. PRD was left open because:

- <specific doubt or gap>

## What to resolve

<Concise list of questions or decisions needed before the PRD can close>

## Acceptance criteria

- [ ] Each open question answered or resolved
- [ ] PRD closed with audit comment, or PRD updated and follow-up issues created

## Blocked by

None - can start immediately
```

Apply the `ready-for-human` triage label.

---

## Rules

- Do **not** modify `to-issues` slice issues beyond the cross-link comment in step 5.
- Do **not** close slice issues or the parent PRD when publishing the review issue.
- Do **not** run the integration audit in this session — only publish the review issue.
- Integration review issues are always `ready-for-agent` — the issue body's **AFK workflow** requires autonomous completion; see `~/.agents/skills/ship-it/SKILL.md` when closing.
