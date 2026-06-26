---
name: ship-it
description: Audits the implementation against the agreed requirements, optionally commits, and closes the GitHub issue with a structured comment.
triggers: ["ship this", "ship it", "wrap this up", "close this issue", "audit and close"]
---

## Step 1 — Acceptance audit

Derive the authoritative requirements from conversation context:
- the agent brief, if one exists in the issue comments
- otherwise the issue body and clarifying comments
- otherwise what was agreed in this conversation

Produce a short checklist mapping each requirement to concrete evidence:
- code changed
- tests added or updated
- commands run and their results
- manual verification, if relevant

Decision:
- If every requirement is met, continue to Step 2.
- If a requirement is not met but can be fixed now, fix it and re-audit before continuing.
- If a requirement cannot be met in this run, do **not** commit or close the issue. Add a comment to the issue documenting the unmet requirement, the blocker, current worktree state, and the next action needed. Then report the same to the user and stop here.
- If the implementation reveals an out-of-scope problem, decide whether it needs a new issue. Do not expand the current issue unless it is necessary to satisfy the original requirements. Slice issues rarely create follow-up issues themselves — the integration review issue mines and publishes them. Document anything the integration review must track.

## Step 2 — Commit (conditional)

If there are uncommitted code changes, stage the relevant files (no .env, no secrets, no unrelated changes) and commit:

```
git commit -m "$(cat <<'EOF'
<concise why-focused message>

Refs #<number>
EOF
)"
```

If there are no code changes (e.g. the task was configuration, documentation, or a process change), skip this step and note it in the closing comment.

## Step 3 — Close the issue

Use this **Follow-up issues** format in the closing comment. The integration review issue parses this section — ambiguous entries become untracked work.

**When there are no follow-ups:**

```
Follow-up issues:
- None
```

**When there are follow-ups**, one bullet per item — never combine `None` with deferred work:

```
Follow-up issues:
- defer → #<n> — <what was deferred and why it belongs there>
- needs-review — <what> — no target issue; integration review must disposition
```

Rules:

- Use `None` only when there is truly nothing for the integration review to track.
- `defer → #N` must name a real issue number when one exists (e.g. a later slice in the same batch).
- `needs-review` — work is not in this slice's scope and has no target issue yet; the integration review will disposition it.
- Do not write "None from this slice" with extra deferred-work prose on the same line — that contradicts `None` and hides follow-ups.

```
gh issue close <number> --comment "$(cat <<'EOF'
Implemented and verified.

Acceptance audit:
- <requirement>: met by <evidence>
- <requirement>: met by <evidence>

Verification:
- <command>: <result>

Follow-up issues:
- <None, or defer → #<n> — <description>, or needs-review — <description>>
EOF
)"
```

**Integration review issues** (published by `to-review`): usually no code changes. Skip Step 2 (commit). Close via this step after publishing follow-up issues and handling PRD closure per the issue body's AFK workflow.
