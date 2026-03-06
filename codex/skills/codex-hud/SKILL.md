---
name: codex-hud
description: Surface Codex execution visibility by collecting hook surfaces, automation entrypoints, active runtime state, and recent tool-call events from logs. Use when the user asks for "codex-hud", "HUD", "뭐 하고 있는지 보여줘", or requests transparent status of what Codex is doing.
---

# Codex HUD

## Objective

Show observable execution state to the user in a reproducible snapshot.

## Quick Start

1. Run `scripts/hud_snapshot.sh`.
2. Share the sections with short interpretation notes.
3. For continuous refresh, run `scripts/hud_snapshot.sh --watch 3`.
4. For a specific repository, run `scripts/hud_snapshot.sh --repo /abs/path`.

## What To Report

- Hook and instruction surfaces:
  - `AGENTS.md`
  - workflow and trigger files
  - files with `hook` or `webhook` in path names
- Runtime state:
  - model/config signal from `~/.codex/config.toml`
  - git branch and working tree summary
  - active process snapshot
- Recent Codex activity:
  - `ToolCall` events
  - `update_plan` events
  - session ID currently sampled

## Guardrails

- Redact secrets before showing logs or env lines.
- Label inferred statements separately from direct observations.
- State limits clearly: internal model reasoning and hidden buffers are not directly observable.
- Avoid saying "all hooks executed" unless evidence includes execution output.

## Resources

- Snapshot script: `scripts/hud_snapshot.sh`
- Observability map: `references/observability-map.md`
- Report template: `assets/hud-report-template.md`
