# Stub: Migrate the small ticketed repos

- feature-slug: migrate-small-repos
- epic: estate-migration
- priority: P2
- size: S
- depends-on: seed-estate-baseline
- sequence: 5 of 5
- sources: pipeline rework 2026-08-28 · dungeons-dragons (1 open DND), casey-hebbel (0 open, 10 done), collabimmo (0 open, 1 done)

## Problem

Three repos carry legacy-shape intake with little or nothing open: dungeons-dragons has
one open ticket (blocked on a Jamie decision), casey-hebbel and collabimmo only have
`_done/` history. They'll flag `legacy-unmigrated` until touched.

## Proposed change

Per repo, the light form of the migration: dungeons-dragons's open ticket becomes a
triage stub or a single-stub epic (Jamie's call, given its blocked decision);
casey-hebbel and collabimmo need only their `_done/` left as the archive it already is —
confirm the seeded baseline sits alongside cleanly and the hygiene report goes quiet.

## Acceptance criteria (rough)

- [ ] No open flat tickets in any of the three
- [ ] `_done/` histories untouched
- [ ] Hygiene report clean for all three

## Out of scope (this feature)

- Cutting new work for these repos — that's a /project run when Jamie wants one.

## Prompt

Migrate the small ticketed repos (projects/dungeons-dragons, projects/casey-hebbel,
projects/collabimmo) to the 2026-08-28 epic layout. Read
.icm/intake/estate-migration/migrate-small-repos.md, then per repo: re-home
dungeons-dragons's one open ticket per _system/contracts/TICKETS.md (ask Jamie whether
its blocked decision keeps it), leave every _done/ archive untouched, and confirm
ticket-hygiene.sh reports the repos clean. Ticket-only commits go straight to each
repo's main.
