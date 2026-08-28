# Stub: Migrate agorasim's backlog to the epic layout

- feature-slug: migrate-agorasim
- epic: estate-migration
- priority: P2
- size: S
- depends-on: seed-estate-baseline
- sequence: 4 of 5
- sources: pipeline rework 2026-08-28 · agorasim .icm/intake (13 open AGORA tickets)

## Problem

agorasim carries 13 open flat `AGORA-NNN` tickets with non-contiguous numbering. Its
`workspaces/` content factory is a separate, working system and is not in scope — only
the ticket backlog migrates.

## Proposed change

Run `/project agorasim` with migration in scope: re-cut the survivors from evidence into
epics and triage; archive old files with notes; Jamie gates the cut.

## Acceptance criteria (rough)

- [ ] No flat tickets left; every survivor a sequenced stub or triage stub
- [ ] The workspaces/ content factory untouched
- [ ] Nothing deleted; every old file archived with its note

## Out of scope (this feature)

- The geo-content workspace and its stages.

## Prompt

Migrate the agorasim repo's ticket backlog to the 2026-08-28 epic layout. Read
.icm/intake/estate-migration/migrate-agorasim.md, then run the /project ritual on
projects/agorasim with the migration step in §5: re-cut the 13 open AGORA tickets from
evidence per _system/contracts/TICKETS.md, archive the old files with Recut/Dropped
notes, leave workspaces/ strictly alone, and gate the cut with Jamie.
