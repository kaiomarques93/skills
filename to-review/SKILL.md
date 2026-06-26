---
name: to-review
description: Publish an integration-review issue for a batch of slice issues — defines upfront integration intent, links big-picture docs, and gates the batch until slices are verified together. Use after /to-issues, when the user says /to-review, integration review, batch review, or verify slices fit together.
disable-model-invocation: true
---

# To Review

Publish an **integration review issue** for a batch of slice issues. Run this right after `/to-issues`, before agents implement the slices.

This skill does **not** run the audit. It plans the audit: integration intent, architecture anchors, slice inventory, and blocking relationships. An AFK agent (or you) works the review issue once the slices are closed.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

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

1. **Slice audit** — For each slice in **Slice inventory**, verify acceptance criteria against code, tests, and the slice's closing comment.
2. **Integration audit** — Verify every scenario under **Integration intent** against the combined codebase. Run relevant tests or commands.
3. **Architecture audit** — Confirm **Architectural invariants** and **Architecture anchors** still hold in the implementation.
4. **Follow-up mining** — Read every slice's closing comment. Extract anything listed under "Follow-up issues" or described as out-of-scope / deferred. Nothing stays buried in comments.

### Follow-up disposition

For each finding, assign exactly one disposition and present the full list to the user for approval before creating issues or closing this issue:

| Disposition | When to use |
|-------------|-------------|
| **new-issue** | Needs tracked work |
| **defer** | Intentionally postponed — record where (PRD Out of Scope, ADR, backlog) and why |
| **absorb** | Fold into an existing open issue — link it |
| **dismiss** | Not actionable — record why |

Ask the user to approve the disposition list. Iterate if they disagree.

### Publish follow-ups

After approval, act on each disposition:

- **new-issue** — Create an issue. Label `ready-for-agent` for clear implementation work; `ready-for-human` for design ambiguity or product decisions.
- **defer** — Add a comment to the relevant anchor doc or PRD; do not create an issue.
- **absorb** — Comment on the target issue with what to fold in.
- **dismiss** — Record in this issue's closing comment only.

Use the same issue body style as `/to-issues` slices (What to build, Acceptance criteria, Blocked by) for **new-issue** items.

### PRD closure

<Include this section only when a Parent PRD exists.>

Audit the PRD's user stories and acceptance against the combined implementation.

- **High confidence** every in-scope story is met and no blocking doubts remain → close the PRD issue with an audit comment.
- **Any ambiguity** — leave the PRD open. Create a **PRD closure review** issue (`ready-for-human`) listing open questions. Do not close the PRD until that issue is resolved.

## Acceptance criteria

- [ ] Every slice in **Slice inventory** audited against its spec and closing comment
- [ ] Every **Integration intent** scenario verified (or gap recorded as follow-up)
- [ ] **Architectural invariants** checked against the codebase
- [ ] Follow-ups mined from slice closing comments and dispositioned
- [ ] User approved the disposition list
- [ ] All **new-issue** follow-ups published with correct triage labels
- [ ] PRD closed (high confidence) OR PRD closure review issue created (`ready-for-human`)

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

- Do **not** modify `/to-issues` slice issues beyond the cross-link comment in step 5.
- Do **not** close slice issues or the parent PRD when publishing the review issue.
- Do **not** run the integration audit in this session — only publish the review issue.
- When working the review issue later, read `ship-it` for the close workflow after acceptance criteria are met.
