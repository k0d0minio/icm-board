# Stub: Migrate remi-ai — backlog re-cut and pipeline consolidation

- feature-slug: migrate-remi-ai
- epic: estate-migration
- priority: P1
- size: M
- depends-on: seed-estate-baseline
- sequence: 3 of 5
- sources: pipeline rework 2026-08-28 · remi-ai .icm/intake (18 open REMI tickets) + its zero-run pipeline/ tree · AUDIT.md open question 2 (answered by D12)

## Problem

remi-ai runs two ticket systems side by side: 18 open flat `REMI-NNN` tickets in
`.icm/intake/` and a fully specified six-stage `pipeline/` tree with **zero runs** — the
direct ancestor of the estate pipeline template. Several open tickets are blocked on
ticket files that don't exist on disk, and ~10 carry free-text conditional statuses the
new model retires.

## Proposed change

Run `/project remi-ai` with migration in scope: re-cut the 18 survivors from evidence
into epics (the existing REMI dependency chains suggest the seams) and triage; resolve
the phantom depends-on references; archive old files with notes. Put the consolidation
decision to Jamie: retire the dormant `pipeline/` tree in favour of declaring
`- profile: pipeline` in `.icm/CONTEXT.md` and seeding the template (recommended — the
template is its descendant and the tree has never run), or keep it and record why.

## Acceptance criteria (rough)

- [ ] No flat tickets left; every survivor a sequenced stub or triage stub
- [ ] No stub depends on work that doesn't exist on disk
- [ ] The pipeline/ tree's fate is a recorded decision in remi-ai's `.icm/project.md`
- [ ] Nothing deleted; every old file archived with its note

## Out of scope (this feature)

- Building anything the re-cut stubs describe.

## Prompt

Migrate the remi-ai repo to the 2026-08-28 epic layout and settle its pipeline
consolidation. Read .icm/intake/estate-migration/migrate-remi-ai.md, then run the
/project ritual on projects/remi-ai with the migration step in §5: re-cut the 18 open
REMI tickets from evidence per _system/contracts/TICKETS.md, fix the phantom
dependencies, archive old files with Recut/Dropped notes, and put the pipeline/-tree vs
pipeline-profile decision to Jamie (recommend the profile; the tree has zero runs).
Jamie gates the cut.
