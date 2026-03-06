# Observability Map

## Directly Observable

- Instruction surfaces: `AGENTS.md`, skill files, workflow YAML, trigger scripts
- Runtime metadata: cwd, git state, model setting from `~/.codex/config.toml`
- Process list: currently running commands and service processes
- Recent Codex events in logs: `ToolCall` and `update_plan`

## Partially Observable

- Hook intent vs actual execution outcome
- Multi-step automation progress when only start/end logs exist
- Session continuity across restarts

## Not Directly Observable

- Internal chain-of-thought or hidden buffers
- Tool calls that were not logged
- Historical data rotated out of current log file

## Reporting Rules

1. Split sections into `Observed`, `Inferred`, and `Unknown`.
2. Include command source for each section.
3. Add `confidence: high|medium|low` per summary statement.
