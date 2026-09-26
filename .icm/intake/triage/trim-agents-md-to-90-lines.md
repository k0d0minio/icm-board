# Stub: AGENTS.md is 96 lines — trim it under the Layer-0 ceiling icm-check now enforces

- lane: chore
- found-by: estate audit 2026-09-26 (AUDIT #6 closed: the ceiling is 90 lines, routing not teaching) · 2026-09-26
- priority: P2
- complexity: low

## Problem

`icm-check.sh` warns on any Layer 0 over 90 lines (Jamie, 2026-09-26, replacing the old "≤50"
question). This repo's own `AGENTS.md` is 96: the "What this repo is" bullets restate
`CONTEXT.md`, and the standing rules repeat doctrine `_system/README.md` § House doctrine already
holds. A rule the repo exempts itself from is a rule it should delete.

## Proposed change

Cut the restated bullets, keep identity, the routing table and the standing rules that exist
nowhere else; link out for the rest. Under 90, on a `claude/` PR (Layer 0 is not a ticket file).
