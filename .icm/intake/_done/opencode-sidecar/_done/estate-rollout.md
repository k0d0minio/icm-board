# Stub: Roll the AGENTS.md shape out across every non-sustentus repo

- feature-slug: estate-rollout
- epic: opencode-sidecar
- priority: P1
- size: L
- depends-on: template-and-checks
- sequence: 5 of 6
- sources: Jamie's widening, 2026-08-29 · precedent:
  `.icm/intake/_done/estate-migration/` (seed-estate-baseline — per-repo pass, human
  driven, no orchestrator)

## Problem

Once the template and checks carry the new shape, ~20+ estate repos under `projects/`
still hold the old one. Each needs the same small migration — CLAUDE.md content to
AGENTS.md, CLAUDE.md rewritten as the `@AGENTS.md` importer, opencode.json seeded —
without breaking any repo's Claude Code sessions, CI, or board presence in the process.

## Proposed change

A per-repo pass over every repo `icm-check` covers (sustentus excluded by its standing
exemption; dormant repos included — conformance still checks them): in each, `git mv
CLAUDE.md AGENTS.md`, write the one-line importer, seed opencode.json via `--fix`, and
open that repo's own PR on a claude/ branch — merged one by one on green CI, like the
seed-estate-baseline pass. A repo with no CLAUDE.md at all just gets the seeded assets.
Along the way, verify the dashboard's `createClientRepo` scaffold: if it writes a
CLAUDE.md for new client repos, park a stub in jamienisbet to teach it the new shape —
do not widen any PR here. The board needs nothing: it reads `.icm/` only.

## Acceptance criteria (rough)

- [ ] Every non-sustentus estate repo carries AGENTS.md + importer CLAUDE.md + opencode.json
- [ ] Each repo's own CI green on its migration PR; no PR bundles two repos
- [ ] A fresh Claude Code session in two spot-checked repos loads Layer 0 identically
- [ ] Conformance run over the estate: no identity warnings, sustentus still exempt
- [ ] `createClientRepo` verified; jamienisbet stub parked if it scaffolds CLAUDE.md

## Out of scope (this feature)

- Sustentus — sequence 6 handles it, minimally.
- Rewriting any repo's Layer 0 *content* — this pass moves and bridges; improving a
  repo's identity file is that repo's own work.

## Prompt

Migrate every non-sustentus estate repo to the AGENTS.md shape, one repo per PR. Read
.icm/intake/opencode-sidecar/estate-rollout.md for full context and the completed
agents-md-layer0 stub for the exact per-repo change. For each repo under projects/
(skip sustentus): git mv CLAUDE.md to AGENTS.md, write the one-line `@AGENTS.md`
CLAUDE.md, seed opencode.json with the conformance --fix, open that repo's PR on a
claude/ branch, and stop at push — CI is the source of truth, merges are Jamie's.
Verify createClientRepo's scaffold and park a jamienisbet stub if it writes CLAUDE.md.
