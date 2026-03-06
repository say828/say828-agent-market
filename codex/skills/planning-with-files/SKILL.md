---
name: planning-with-files
description: Persist and execute work through a markdown plan file inside the active repo. Use when the user asks for "Planning with Files", "플래닝 위드 파일스", a durable checklist, or any multi-step task that must stay auditable across edits, tests, and deployment.
---

# Planning with Files

## Objective

Create a plan file early, keep it live during execution, and close it with verification evidence.

## Quick Start

1. Run `scripts/new_plan.sh "<title>"`.
2. Open the created file under `docs/plans/`.
3. Fill scope, assumptions, and acceptance criteria before major edits.
4. Update checklist and work log after each meaningful action.
5. Close with validation status and remaining risks.

## Workflow

1. Define scope and constraints in the plan file.
2. Break work into 5-10 concrete checklist items.
3. Keep exactly one item in active progress.
4. Append short evidence logs after edit/test/deploy steps.
5. Replan the remaining checklist when blockers appear.
6. End with explicit pass/fail validation notes.

## Resources

- Template: `assets/plan-template.md`
- Rules and examples: `references/plan-rules.md`
- Scaffolder: `scripts/new_plan.sh`

## Guardrails

- Keep plan entries factual and concise.
- Avoid stale checklists; update instead of accumulating dead items.
- Never mark validation complete without command-level evidence in the log.
