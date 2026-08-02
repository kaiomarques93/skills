#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin${PATH:+:$PATH}"

usage() {
  cat <<'EOF'
Usage: launch-backend-issues.sh [--dry-run] <issue-number> [issue-number ...]

Environment overrides:
  LANGU_VPS_HOST       VPS address (default: 187.127.39.14)
  LANGU_VPS_USER       SSH user (default: root)
  LANGU_VPS_KEY        SSH private key (default: ~/.ssh/langu-hostinger-prod)
  LANGU_VPS_REPO       Remote backend repo (default: /root/api-langu-backend-nestjs)
EOF
}

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
  shift
fi

if (($# == 0)); then
  usage >&2
  exit 2
fi

declare -a issues=()
declare -A seen=()
for value in "$@"; do
  value="${value#\#}"
  if [[ ! "$value" =~ ^[1-9][0-9]*$ ]]; then
    printf 'ERROR: invalid issue number: %s\n' "$value" >&2
    exit 2
  fi
  if [[ -z "${seen[$value]:-}" ]]; then
    issues+=("$value")
    seen[$value]=1
  fi
done

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template="$skill_dir/assets/backend-orchestration-prompt.md"
[[ -f "$template" ]] || { echo "ERROR: prompt template missing: $template" >&2; exit 1; }

vps_host="${LANGU_VPS_HOST:-187.127.39.14}"
vps_user="${LANGU_VPS_USER:-root}"
vps_key="${LANGU_VPS_KEY:-$HOME/.ssh/langu-hostinger-prod}"
vps_repo="${LANGU_VPS_REPO:-/root/api-langu-backend-nestjs}"
remote="${vps_user}@${vps_host}"

issue_slug="$(printf '%s\n' "${issues[@]}" | sort -n | paste -sd-)"
issue_list=""
for issue in "${issues[@]}"; do
  [[ -z "$issue_list" ]] || issue_list+=", "
  issue_list+="#$issue"
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
rendered_prompt="$tmp_dir/backend-issues-${issue_slug}.md"
sed -e "s/{{ISSUE_LIST}}/$issue_list/g" "$template" >"$rendered_prompt"

if [[ "$dry_run" == true ]]; then
  cat "$rendered_prompt"
  exit 0
fi

[[ -f "$vps_key" ]] || { echo "ERROR: SSH key missing: $vps_key" >&2; exit 1; }
command -v ssh >/dev/null || { echo "ERROR: ssh is not installed" >&2; exit 1; }
command -v scp >/dev/null || { echo "ERROR: scp is not installed" >&2; exit 1; }

ssh_opts=(-i "$vps_key" -o BatchMode=yes -o ConnectTimeout=15)
remote_prompt="/root/.claude/prompts/backend-issues-${issue_slug}.md"
remote_log="/root/.claude/logs/backend-issues-${issue_slug}.jsonl"
unit="claude-langu-backend-issues-${issue_slug}"

ssh "${ssh_opts[@]}" "$remote" 'mkdir -p /root/.claude/prompts /root/.claude/logs'
scp "${ssh_opts[@]}" "$rendered_prompt" "$remote:$remote_prompt"

ssh "${ssh_opts[@]}" "$remote" bash -s -- \
  "$unit" "$remote_prompt" "$remote_log" "$vps_repo" <<'REMOTE'
set -Eeuo pipefail

unit="$1"
prompt_path="$2"
log_path="$3"
repo="$4"

[[ -d "$repo/.git" ]] || { echo "ERROR: backend repo missing: $repo" >&2; exit 1; }
[[ -s "$prompt_path" ]] || { echo "ERROR: remote prompt missing: $prompt_path" >&2; exit 1; }
[[ -f /root/.claude/skills/orchestrate-backend-issues/SKILL.md ]] || {
  echo "ERROR: remote orchestrate-backend-issues skill is missing" >&2
  exit 1
}
[[ -f /root/.claude/skills/implement-issue/SKILL.md ]] || {
  echo "ERROR: remote implement-issue dependency is missing" >&2
  exit 1
}

claude_path="$(command -v claude || true)"
[[ -n "$claude_path" ]] || claude_path=/root/.local/bin/claude
[[ -x "$claude_path" ]] || { echo "ERROR: Claude CLI is missing" >&2; exit 1; }
"$claude_path" auth status | grep -q '"loggedIn": true' || {
  echo "ERROR: Claude is not authenticated on the VPS" >&2
  exit 1
}

node_path="$(find /root/.nvm/versions/node -path '*/bin/node' -type f 2>/dev/null | sort -V | tail -n 1)"
[[ -n "$node_path" ]] || { echo "ERROR: Node is missing under /root/.nvm" >&2; exit 1; }
node_dir="${node_path%/node}"
node_major="$($node_path -p 'Number(process.versions.node.split(".")[0])')"
((node_major >= 24)) || { echo "ERROR: Node 24+ required; found major $node_major" >&2; exit 1; }

if systemctl is-active --quiet "$unit.service"; then
  echo "ERROR: batch is already active: $unit.service" >&2
  exit 1
fi

if [[ -e "$log_path" ]]; then
  mv "$log_path" "$log_path.$(date -u +%Y%m%dT%H%M%SZ).bak"
fi

runtime_path="$node_dir:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
systemd-run \
  --unit="$unit" \
  --collect \
  --service-type=exec \
  --property="WorkingDirectory=$repo" \
  --setenv=HOME=/root \
  --setenv=SHELL=/usr/bin/zsh \
  --setenv="PATH=$runtime_path" \
  /bin/bash -c 'exec "$1" -p --permission-mode auto --effort max --output-format stream-json --verbose --forward-subagent-text "$(<"$2")" >"$3" 2>&1' \
  _ "$claude_path" "$prompt_path" "$log_path"
REMOTE

printf '\nStarted autonomous VPS backend batch.\n'
printf 'Issues: %s\n' "$issue_list"
printf 'Prompt: %s:%s\n' "$remote" "$remote_prompt"
printf 'Log: %s:%s\n' "$remote" "$remote_log"
printf 'Unit: %s.service\n\n' "$unit"
printf 'Follow:\nssh -i %q %q %q\n\n' "$vps_key" "$remote" "tail -f $remote_log"
printf 'Status:\nssh -i %q %q %q\n\n' "$vps_key" "$remote" "systemctl status $unit.service --no-pager"
printf 'Stop:\nssh -i %q %q %q\n' "$vps_key" "$remote" "systemctl stop $unit.service"
