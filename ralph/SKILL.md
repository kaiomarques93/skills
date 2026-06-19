---
name: ralph
description: Autonomous dev loop — picks the next ready-for-agent GitHub issue, implements it, and closes it when satisfied. Conditionally applies TDD, CodeRabbit review, and design grilling based on the nature of the issue.
triggers: ["/ralph", "run ralph", "ralph loop", "autonomous dev loop"]
---

You are running the Ralph autonomous dev loop. Work through the steps below in order without stopping to ask for approval between them.

## Step 1 — Pick the next issue

```
gh issue list --label ready-for-agent --state open --json number,title --jq 'sort_by(.number) | .[0]'
```

Then read the full spec:

```
gh issue view <number> --json number,title,body,comments
```

Announce the issue number and title. Briefly explain why it is the logical next step given the current state of the codebase.

## Step 2 — Understand the codebase

Before writing a line of code, read the relevant files. Understand existing patterns, naming conventions, and architecture decisions (check ADRs in docs/adr/ if present). Do not introduce abstractions that do not already exist.

## Step 2b — Plan the run

After understanding the issue and the codebase, decide which optional steps you will run. State your decision explicitly before proceeding:

**TDD** — mandatory for features and bug fixes. Skip for pure cleanup (deleting unused files, renaming, docs, config-only changes). Use judgment for everything else: apply TDD when tests would meaningfully increase confidence in the change.

**CodeRabbit review** — mandatory when production code is added or modified. Skip when there are no code changes (docs-only, config-only, file deletions with no logic). Use judgment for test-only changes.

**Design grilling** — mandatory when the change involves new abstractions or multiple valid design approaches. Skip for mechanical changes (deleting files, trivial bug fixes, pure config). Use judgment for everything else: grill when design decisions could go more than one way.

For each step you are skipping, print one line explaining why. Do not open the corresponding skill file — only fetch it if you will actually use it.

Example output:
> - TDD: skipping — this is a file cleanup with no logic changes.
> - CodeRabbit: running — production code is being modified.
> - Grilling: skipping — the change is mechanical with no design decisions.

## Step 3 — Implement

If TDD was decided: read `~/.agents/skills/tdd/SKILL.md` and follow those instructions verbatim, applied to the issue's requirement: red → green → refactor.

If TDD was skipped: implement the change directly, following existing patterns.

Leave all changes **uncommitted**.

## Step 4 — CodeRabbit review

*Skip this step entirely if CodeRabbit was decided off in Step 2b.*

```
coderabbit review --agent --type uncommitted
```

**CodeRabbit review typically takes 10–20 minutes.** Run this command in the background and use Monitor to watch for completion. Do not set a timeout shorter than 25 minutes. Do not poll in a loop that gives up early — wait for the process to signal completion.

If CodeRabbit completes within 25 minutes: parse the structured findings output and apply them as described below.

If CodeRabbit does not complete within 25 minutes: do not abort the run. Continue to Step 5 immediately, but record `CodeRabbit: timed out — review did not complete` in the Step 9 final report.

### Apply findings

For each finding decide:
- **Issue / bug**: always fix.
- **Nitpick**: apply if it improves correctness, safety, or readability; skip if purely cosmetic and you disagree.
- **Suggestion**: apply if it aligns with existing architecture; skip with a short note if it conflicts.

If the first run returned zero findings, skip the confirmation run. Otherwise, after applying fixes, run once more to confirm they are resolved:

```
coderabbit review --agent --type uncommitted
```

## Step 5 — Grill the design

*Skip this step entirely if grilling was decided off in Step 2b.*

Read `~/.agents/skills/grill-me/SKILL.md` and follow those instructions verbatim, applied to your implementation. Interview yourself (and the user if needed) relentlessly about every design decision, edge case, and assumption. Resolve every open branch before proceeding.

## Step 6 — Ship it

Read `~/.agents/skills/ship-it/SKILL.md` and follow those instructions verbatim. When returning to Step 3 to fix a failing requirement, continue the loop from there.

## Step 7 — Final report

Tell the user:
- whether the issue requirements were met
- whether the issue was closed
- what was implemented
- what tests and checks passed
- what CodeRabbit flagged and how it was handled; or that it timed out (>25 min) and review did not complete; or that it was skipped and why
- what grilling surfaced (or that it was skipped and why)
- whether any out-of-scope problem needs a new issue
