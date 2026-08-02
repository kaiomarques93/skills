/orchestrate-backend-issues

Run the backend issue batch in `/root/api-langu-backend-nestjs` completely autonomously from investigation through verified squash-merge and final cleanup.

Target issue set: {{ISSUE_LIST}}. Treat this as an unordered worklist. Independently determine the dependency DAG, file-conflict clusters, safe parallel batches, implementation order, and merge order according to the `orchestrate-backend-issues` skill. Each target must keep its own branch, PR, QA ledger, review, and merge as required by the skill; never combine unrelated issues.

Read and follow the complete `orchestrate-backend-issues` skill, its bundled references/scripts, the repository's `AGENTS.md`/`CLAUDE.md`, and every relevant linked skill. Use the skill's durable state file and keep it current so context compaction or a resumed session cannot lose progress. Use up to three subagents as the skill permits, while strictly serializing every live-backend/e2e operation through `backend-lock.sh`.

## Autonomy

- Do not ask the human questions and do not wait for interactive replies. Investigate the issues, comments, repository, deployment files, current containers, and existing conventions; make the best defensible decision yourself and record the evidence and rationale.
- If a decision genuinely requires human authority—production deployment behavior, acceptable real data/message loss policy, a security-policy trade-off that cannot be resolved from evidence, paid external-service use, unavailable credentials, or an unbounded architectural repartition—open a detailed GitHub issue in this repository with the `ready-for-human` label. Include the parent issue, evidence, options, your recommendation, and the exact unblock condition. Continue all work not actually blocked by that decision. Do not turn ordinary implementation ambiguity into a human issue.
- If a target is already closed or merged, verify it and skip duplicate work. If related branches, worktrees, QA issues, or PRs exist, inspect and safely resume them rather than duplicating them.
- Remain active while subagents, CI, or review bots are pending. Poll with reasonable backoff. Never merge a red pipeline or bypass an unresolved/rate-limited review bot; follow the skill's retry and review rules.

## VPS authority and limits

- This VPS currently has no users. Application data in Postgres and transient state in Redis/RabbitMQ may be treated as disposable for this batch. You may seed, modify, truncate, reset, or recreate that data when necessary for reliable testing.
- You may stop, start, restart, remove, or recreate this repository's application, Postgres, Redis, and RabbitMQ Docker Compose containers and volumes when necessary. You may stop the Docker API service and run the backend directly with `npm run start:dev`. Inspect current state first and use the least disruptive action that reliably proves the change.
- Only the lock-holding serialized tester may manipulate the live backend or run `npm run start:dev`/e2e. Implementers and fixers remain isolated in their worktrees and obey the skill's unit/build/lint/prettier restrictions.
- Node 24 or newer is required. Confirm `node --version` before Node/npm commands; the launcher puts the newest installed NVM Node in PATH and refuses versions below 24.
- You may apply migrations and generate/check migration diffs. Preserve migration correctness and use the skill's monotonic timestamp helper for parallel migrations.
- Restore every edited `.env` byte-for-byte after testing. At completion, stop stray host Nest processes, release the backend lock, and leave the intended Docker Compose services healthy.
- This authority is scoped to the langU repository and its application data/services. Do not delete the repository, alter SSH/Claude/GitHub credentials, change host firewall/DNS, destroy Caddy TLS state, intentionally spend money on external APIs, or deploy newly merged code to production unless a target explicitly requires it. File `ready-for-human` if one of these becomes necessary.

## Required execution

1. Verify the main checkout is clean, fetch/prune, and fast-forward `main`; never discard unknown human changes.
2. Read every target issue and comment, verify its state and labels, resolve declared blockers, and construct the dependency/file-conflict plan and module map.
3. Run the complete per-issue pipeline: architecture, isolated implementation, bounded architect review, CRAP analysis, review loop, agent-testable QA issue, serialized local backend/e2e verification before PR, PR/CI/bot remediation, module-steward merge gate, squash merge, and per-issue cleanup.
4. Preserve every issue's required API, schema, transaction, security, idempotency, and performance behavior. Prove acceptance criteria with the relevant unit, integration, e2e, migration-diff, and runtime checks rather than assumptions.
5. If main is red, follow the orchestrator skill: file and land the minimum dedicated main-fix issue first, then rebase the queue. Never excuse or merge red CI.
6. After every target is merged, run the mandatory cleanup verifier. Completion requires all targets merged or already verified complete; all `ready-for-agent` QA ledgers closed; only legitimate `ready-for-human` issues open; no issue worktrees/branches or stale backend lock; clean synchronized `main` containing every merge SHA; no stray host backend; and Docker services healthy.

Do not stop at plans, partial implementations, open PRs, or a status report. Continue until the complete batch close-out condition is met or a genuine external impossibility remains after exhausting safe alternatives. The final response must summarize issue-to-PR-to-merge mappings, QA evidence, CI/review status, follow-up or `ready-for-human` issues, merge SHAs, cleanup-verifier result, and final Docker/backend health.
