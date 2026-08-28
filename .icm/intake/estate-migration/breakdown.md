# Breakdown: Estate migration — the pipeline rework's rollout

- epic-slug: estate-migration
- sources: the 2026-08-28 pipeline rework (decisions D10–D14, .icm/project.md; design:
  .icm/docs/pipeline-rework-design.md). Absorbed the remainders of ICM-010 and ICM-017
  (originals purged, D14).

## What I understood

The contracts, template and scripts landed in the rework PR; the dashboard's dual-shape
board lands in jamienisbet's own PR. Jamie then chose a clean slate (D14): every legacy
`PREFIX-NNN` ticket — open and archived — was purged across the estate in the same
session, so there is nothing to re-cut. What remains is one job: seed the widened
baseline across the estate, with the per-repo hook-wiring rulings that were owed. Fresh
backlogs arrive per repo from `/project` runs whenever a repo next earns one —
remi-ai's dormant `pipeline/` tree (keep, or retire for the `pipeline` profile) is
decided in its first such run.

## Build order

1. seed-estate-baseline — icm-check --fix estate-wide; per-repo hook wiring/refresh rulings — depends-on: none

## Out of scope (whole epic)

- Cutting any repo's fresh backlog — that is a gated /project run, per repo, on demand.
- Sustentus — exempt, untouched, already readable by the new board.
- The dashboard code itself — jamienisbet's ticket, in its own repo.
