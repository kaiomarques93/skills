---
name: ralph
description: Autonomous dev loop — picks the next ready-for-agent GitHub issue, implements it on the current branch using TDD, runs CodeRabbit CLI review on uncommitted changes, applies findings, then grills the design with /grill-me before committing.
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

## Step 7 — Commit

Once grilling is complete and all concerns are addressed:
- Stage the relevant files (no .env, no secrets, no unrelated changes)
- Commit with a message that explains **why**, not just what

```
git commit -m "$(cat <<'EOF'
<concise why-focused message for the issue>

Closes #<number>
EOF
)"
```

Report what was implemented, what CodeRabbit flagged and how it was handled, and what grilling surfaced.
