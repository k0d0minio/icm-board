# Stub: Migrate jamienisbet's backlog to the epic layout

- feature-slug: migrate-jamienisbet
- epic: estate-migration
- priority: P1
- size: S
- depends-on: seed-estate-baseline
- sequence: 2 of 5
- blocked: the dashboard's dual-shape board PR must be merged and live first — the board reads this repo
- sources: pipeline rework 2026-08-28 · jamienisbet .icm/intake (7 open JN tickets as of 2026-08-28)

## Problem

jamienisbet still carries flat `JN-NNN` tickets (7 open: onboarding forms, biz API,
dark mode, leads cockpit, money glanceability, compliance calendar, the stale
JN-020). Until re-cut, the board shows them via the legacy parser and the hygiene report
flags the repo `legacy-unmigrated` every day.

## Proposed change

Run `/project jamienisbet` with migration in scope: re-cut the survivors from evidence
into epics (the leads-cockpit + money work batches naturally; JN-028 is the API the
business-state epic here depends on) and triage; check the visibly stale JN-020
(scaffolding shipped) against the code and bank or drop it; old files to
`intake/_done/` with `> Recut as` / `> Dropped:` lines. Jamie gates the cut.

## Acceptance criteria (rough)

- [ ] No flat tickets left in jamienisbet's `.icm/intake/`
- [ ] Every surviving ticket is a sequenced stub in an epic or a lane-tagged triage stub
- [ ] The board shows the repo correctly in the new shape
- [ ] Nothing deleted; every old file archived with its note

## Out of scope (this feature)

- The dashboard code — its own JN stubs, cut in that repo.

## Prompt

Migrate the jamienisbet repo's ticket backlog to the 2026-08-28 epic layout. Read
.icm/intake/estate-migration/migrate-jamienisbet.md, then run the /project ritual
(workspaces/deliver/stages/project/CONTEXT.md) on projects/jamienisbet with the
migration step in §5: re-cut the open JN tickets from evidence into epics and triage per
_system/contracts/TICKETS.md, archive the old files with Recut/Dropped notes, and gate
the cut with Jamie. Confirm the dashboard's dual-shape board is live before pushing.
