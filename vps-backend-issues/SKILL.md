---
name: vps-backend-issues
description: Launch a fully autonomous Claude backend-issue orchestration batch on the langU VPS, with a generated prompt, detached execution, and remote log monitoring. Use when the user supplies backend GitHub issue numbers and asks to solve, run, delegate, or orchestrate them on the VPS.
triggers: ["vps backend issues", "solve these issues on the vps", "run backend issues on vps", "delegate issues to claude", "launch claude on vps"]
argument-hint: "<issue-number> [issue-number ...]"
---

# VPS backend issues

Launch Claude on the langU VPS to implement and merge a user-supplied set of
backend issues. The local agent only launches and reports; the remote
`orchestrate-backend-issues` skill owns planning, implementation order, QA,
PRs, merges, and cleanup.

## Invocation

Accept issue numbers from the user as an unordered target set. Examples:

```text
/vps-backend-issues 334 335 332 333
Solve backend issues #334, #335, #332, and #333 on the VPS.
```

If no issue numbers were supplied, ask for them. Reject non-numeric values and
do not infer issue numbers from unrelated text.

## Launch workflow

1. Tell the user that launching creates a remote prompt/log and starts a
   detached, autonomous Claude process that may mutate the VPS application
   database and Docker services within the prompt's guardrails.
2. Run the bundled launcher with the issue numbers:

   ```bash
   bash ~/.agents/skills/vps-backend-issues/scripts/launch-backend-issues.sh <issues...>
   ```

3. Network or filesystem approval may be required. Request it when the tool
   requires approval; do not replace the launcher with ad-hoc SSH commands.
4. Report the launcher's paths and commands exactly: remote prompt, remote log,
   systemd unit, follow command, status command, and stop command.
5. Do not follow the log automatically after a successful launch. The user's
   local agent turn should end while remote Claude continues. Follow or inspect
   it only when the user asks.

## Behavior

- The remote orchestrator independently plans dependency order, conflict
  clusters, parallel batches, and merge order. Input order has no priority.
- The launcher uses `--permission-mode auto`: Claude refuses
  `bypassPermissions` under the VPS root account.
- Execution uses a transient systemd service, so it survives SSH disconnects
  and the user's computer being turned off. It does not survive a VPS reboot.
- Reusing the same issue set while its unit is active is rejected to prevent a
  duplicate orchestration run.
- Existing logs are timestamp-rotated before a later rerun of the same batch.
- Use `--dry-run` before the issue numbers only when the user asks to inspect
  the rendered prompt without uploading or launching it.

## Scope

Use this skill only for the langU NestJS backend VPS workflow. Do not use it for
mobile issues, local implementation, arbitrary VPS shell work, or merely
explaining how SSH/background processes work.
