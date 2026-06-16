---
name: ralph
description: Autonomous dev loop — picks the next ready-for-agent GitHub issue, implements it on the current branch using TDD, runs CodeRabbit CLI review on uncommitted changes, applies findings, grills the design, verifies the issue requirements, commits, and closes the issue when satisfied.
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

## Step 3 — Implement with TDD

Read ~/.agents/skills/tdd/SKILL.md and follow those instructions verbatim, applied to the issue's requirement: red → green → refactor.

Leave all changes **uncommitted**.

## Step 4 — CodeRabbit review

```
coderabbit review --agent --type uncommitted
```

Wait for it to complete. Parse the structured findings output.

## Step 5 — Apply findings

For each finding decide:
- **Issue / bug**: always fix.
- **Nitpick**: apply if it improves correctness, safety, or readability; skip if purely cosmetic and you disagree.
- **Suggestion**: apply if it aligns with existing architecture; skip with a short note if it conflicts.

After applying fixes, run the review again to confirm the findings are resolved:

```
coderabbit review --agent --type uncommitted
```

## Step 6 — Grill the design

Read ~/.agents/skills/grill-me/SKILL.md and follow those instructions verbatim, applied to your implementation. Interview yourself (and the user if needed) relentlessly about every design decision, edge case, and assumption. Resolve every open branch before proceeding.

## Step 7 — Acceptance audit

Before committing, audit the implementation against the issue contract.

Treat the authoritative requirements as:
- the agent brief, if one exists in the issue comments
- otherwise the issue body and clarifying comments

Produce a short checklist mapping each requirement to concrete evidence:
- code changed
- tests added or updated
- commands run and their results
- manual verification, if relevant

Decision:
- If every requirement is met, continue to commit and close the issue.
- If a requirement is not met but can be fixed now, return to Step 3 and continue the loop.
- If a requirement cannot be met in this run, do **not** commit or close the issue. Report the unmet requirement, the blocker, current worktree state, and the next action needed.
- If the implementation reveals an out-of-scope problem, decide whether it needs a new issue. Do not expand the current issue unless it is necessary to satisfy the original requirements.

## Step 8 — Commit

Once grilling is complete and all concerns are addressed:
- Stage the relevant files (no .env, no secrets, no unrelated changes)
- Commit with a message that explains **why**, not just what

```
git commit -m "$(cat <<'EOF'
<concise why-focused message for the issue>

Refs #<number>
EOF
)"
```

## Step 9 — Close the issue

Close the issue only after the acceptance audit passes and the commit succeeds.

```
gh issue close <number> --comment "$(cat <<'EOF'
Implemented and verified.

Acceptance audit:
- <requirement>: met by <evidence>
- <requirement>: met by <evidence>

Verification:
- <command>: <result>

Follow-up issues:
- <none, or describe the out-of-scope problem and why it should become a new issue>
EOF
)"
```

## Step 10 — Final report

Tell the user:
- whether the issue requirements were met
- whether the issue was closed
- what was implemented
- what tests and checks passed
- what CodeRabbit flagged and how it was handled
- what grilling surfaced
- whether any out-of-scope problem needs a new issue
