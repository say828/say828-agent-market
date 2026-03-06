#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPO_PATH="${CODEX_HUD_REPO:-${CODEX_INLINE_WORKDIR:-$PWD}}"
LIMIT="${CODEX_HUD_LIMIT:-10}"
INTERVAL="${CODEX_HUD_INTERVAL:-2}"

exec bash "${ROOT_DIR}/codex/skills/codex-hud/scripts/hud_snapshot.sh" \
  --repo "${REPO_PATH}" \
  --limit "${LIMIT}" \
  --watch "${INTERVAL}"
