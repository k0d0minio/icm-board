# Breakdown: Pipeline file-level ownership — re-found the template, sync it, roll it out

## What I understood

`ICM_Refactoring_Directive_v5.md` (2026-09-18) asks for the estate pipeline to become a
**standalone, file-decoupled** architecture: sustentus is the reference implementation;
its `.icm/` is generalised into `_system/template/icm-pipeline/` with every repo identity
removed; each pipeline file is either **template-owned** (identical everywhere, synced) or
**project-owned** (seeded once, never touched); an idempotent `icm-sync.sh` proves the
split against sustentus before anything downstream is touched. The `approve` substage
(the asynchronous question sheet) is deleted — Scope interrogates live and emits `D-n`
decisions that `validate-decisions.sh` traces downstream. Recorded as D20 and D21 in
`.icm/project.md`. The dry-run gap analysis and the deep-dive audit (both in
`~/Downloads`, 2026-09-18) supplied the corrections the v5 text adopted and the ones it
did not (manifest-driven include list, strict profile guard, `notes.md` not `run.md`,
knowledge-map stays project-owned, the `lib/` dependency, the comma split).

## Where it sits

`_system/template/icm-pipeline/` (the template + `MANIFEST`), `_system/scripts/icm-sync.sh`
(new) and `icm-check.sh` (rewired), `_system/contracts/PIPELINE.md`, the seeded router
and PR template, and — for the reference sync — `projects/sustentus/.icm/` on its own PR.
Downstream repos (remi-ai first) are the third stub, a later session.

## Build order

1. `re-found-template-and-sync-tool` — the template re-founded and generalised, the
   manifest, the sync tool, the checker rewired, the docs and decisions.
2. `sustentus-first-sync` — sustentus's project-owned files written, the profile line,
   the first `--apply`, idempotency proven, its PR opened.
3. `downstream-rollout` — remi-ai reconciled (its ship-note flow re-homed as
   project-owned, `approve/` removed, stale runs archived), then every other pipeline
   repo; one PR per repo.

## Parallelizable

1 before 2 before 3. Within 3, repos are independent of each other.

## Out of scope (whole scope)

- Moving any CI release gate or quality workflow local (D21 draws the line at
  changed-files feedback).
- serviflow's adoption (E16 of the deep-dive — a separate ruling).
- The `pipeline-full` profile question (announce as a profile or as project rules —
  PIPELINE.md keeps the row, evidence decides later).
