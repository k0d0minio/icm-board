# Breakdown: Estate migration — the pipeline rework's rollout

- epic-slug: estate-migration
- sources: the 2026-08-28 pipeline rework (decisions D10–D13, .icm/project.md; design:
  .icm/docs/pipeline-rework-design.md). Absorbs the remainders of ICM-010 (seed
  canonical assets) and ICM-017 (hook wiring) — both recut here, originals in
  intake/_done/.

## What I understood

The contracts, template and scripts landed in the rework PR; the dashboard's dual-shape
board lands in jamienisbet's own PR. What remains is the rollout: seed the widened
baseline across the estate (with the per-repo hook-wiring decisions the old tickets
carried), then re-cut each ticketed repo's flat backlog into epics and triage — /project
work at Jamie's gate, re-cut from evidence per the standing drop-bias, never converted
mechanically. The jamienisbet migration waits for the dashboard parser to be live so the
board never goes dark; every other repo can migrate as soon as the baseline is seeded.

## Build order

1. seed-estate-baseline — icm-check --fix estate-wide; per-repo hook wiring/refresh rulings — depends-on: none
2. migrate-jamienisbet — re-cut its 7 open JN tickets; needs the dashboard PR merged — depends-on: seed-estate-baseline
3. migrate-remi-ai — re-cut 18 open REMI tickets; decide the dormant pipeline/ tree vs the pipeline profile — depends-on: seed-estate-baseline
4. migrate-agorasim — re-cut 13 open AGORA tickets — depends-on: seed-estate-baseline
5. migrate-small-repos — dungeons-dragons (1), casey-hebbel (0), collabimmo (0) — depends-on: seed-estate-baseline

## Parallelizable

2–5 are independent of each other; the linear order is priority (board visibility
first), not dependency.

## Out of scope (whole epic)

- Sustentus — exempt, untouched, already readable by the new board.
- Dormant repos' backlogs — they have none; they receive only the seeded baseline.
- The dashboard code itself — jamienisbet's ticket, in its own repo.
