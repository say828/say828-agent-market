#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  hud_snapshot.sh [--repo PATH] [--log PATH] [--limit N] [--session ID|latest] [--watch SEC]

Options:
  --repo      Target repository path (default: current directory)
  --log       Codex log path (default: $HOME/.codex/log/codex-tui.log)
  --limit     Number of recent events to print (default: 20)
  --session   Session thread_id or "latest" (default: latest)
  --watch     Refresh every N seconds until interrupted
  --help      Show this help
EOF
}

repo="$(pwd)"
log_path="${HOME}/.codex/log/codex-tui.log"
limit=20
session="latest"
watch_interval=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --log)
      log_path="${2:-}"
      shift 2
      ;;
    --limit)
      limit="${2:-}"
      shift 2
      ;;
    --session)
      session="${2:-}"
      shift 2
      ;;
    --watch)
      watch_interval="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! [[ "$limit" =~ ^[0-9]+$ ]] || [[ "$limit" -lt 1 ]]; then
  echo "--limit must be a positive integer" >&2
  exit 1
fi

if ! [[ "$watch_interval" =~ ^[0-9]+$ ]]; then
  echo "--watch must be a non-negative integer" >&2
  exit 1
fi

if [[ ! -d "$repo" ]]; then
  echo "Repository path not found: $repo" >&2
  exit 1
fi

redact() {
  sed -E \
    -e 's/sk-[A-Za-z0-9._-]{16,}/sk-[REDACTED]/g' \
    -e 's/ghp_[A-Za-z0-9]{16,}/ghp_[REDACTED]/g' \
    -e 's/\b(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|GH_TOKEN|GITHUB_TOKEN|OPENAI_API_KEY|API_KEY|SECRET_KEY|PASSWORD|TOKEN)[[:space:]]*=[^[:space:]]+/\1=[REDACTED]/gI' \
    -e 's/("?(password|token|secret|api[_-]?key|authorization)"?[[:space:]]*:[[:space:]]*")[^"]*"/\1[REDACTED]"/gI'
}

trim_lines() {
  awk '{ if (length($0) > 240) { print substr($0, 1, 240) "..."; } else { print; } }'
}

section() {
  echo
  echo "## $1"
}

discover_session_id() {
  if [[ "$session" != "latest" ]]; then
    printf '%s\n' "$session"
    return
  fi

  if [[ ! -f "$log_path" ]]; then
    echo ""
    return
  fi

  rg -o "thread_id=[0-9a-f-]{8,}" "$log_path" 2>/dev/null | tail -n 1 | cut -d '=' -f 2
}

print_header() {
  echo "CODEX HUD SNAPSHOT"
  echo "generated_at=$(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "repo=${repo}"
  echo "log=${log_path}"
}

print_instruction_surfaces() {
  section "Instruction and Hook Surfaces"
  (
    cd "$repo"
    find . \
      -type f \
      ! -path "*/.git/*" \
      ! -path "*/node_modules/*" \
      ! -path "*/.venv/*" \
      ! -path "*/venv/*" \
      ! -path "*/dist/*" \
      ! -path "*/build/*" \
      ! -path "*/__pycache__/*" \
      \( -name "AGENTS.md" -o -path "./.github/workflows/*.yml" -o -path "./.github/workflows/*.yaml" -o -iname "*hook*" -o -iname "*webhook*" \) \
      -print \
      | sort \
      | sed -n '1,80p'
  ) || true
}

print_runtime() {
  section "Runtime State"

  config_path="${HOME}/.codex/config.toml"
  model="unknown"
  effort="unknown"
  if [[ -f "$config_path" ]]; then
    model="$(sed -n 's/^model[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$config_path" | head -n 1)"
    effort="$(sed -n 's/^model_reasoning_effort[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$config_path" | head -n 1)"
  fi

  echo "model=${model:-unknown}"
  echo "reasoning_effort=${effort:-unknown}"

  if git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
    dirty_count="$(git -C "$repo" status --short 2>/dev/null | wc -l | tr -d ' ')"
    echo "git_branch=${branch}"
    echo "git_changed_files=${dirty_count}"
  else
    echo "git=not_a_repository"
  fi

  echo
  echo "active_processes:"
  ps -eo pid,etime,args \
    | rg -i "codex|uvicorn|pytest|npm|pnpm|node|docker|cloudflared|python|bash -lc" \
    | sed -n '1,25p' \
    | redact \
    | trim_lines || true
}

print_recent_events() {
  section "Recent Codex Events"

  if [[ ! -f "$log_path" ]]; then
    echo "log_missing"
    return
  fi

  session_id="$(discover_session_id)"
  if [[ -n "$session_id" ]]; then
    echo "session_id=${session_id}"
    events="$(rg "thread_id=${session_id}" "$log_path" | rg "ToolCall:|update_plan" | tail -n "$limit" || true)"
  else
    echo "session_id=unknown"
    events="$(rg "ToolCall:|update_plan" "$log_path" | tail -n "$limit" || true)"
  fi

  if [[ -z "$events" ]]; then
    echo "events=none"
    return
  fi

  printf '%s\n' "$events" | redact | trim_lines
}

print_limits() {
  section "Visibility Limits"
  cat <<'EOF'
- Internal model reasoning is not directly visible.
- Snapshot reflects files/processes/log lines available at collection time.
- Missing log entries do not prove missing activity.
EOF
}

render_snapshot() {
  print_header
  print_instruction_surfaces
  print_runtime
  print_recent_events
  print_limits
}

if [[ "$watch_interval" -gt 0 ]]; then
  while true; do
    clear
    render_snapshot
    sleep "$watch_interval"
  done
else
  render_snapshot
fi
