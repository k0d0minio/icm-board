# Stub: Give the lens roster and the project register a template-owned home

- feature-slug: port-lenses-and-register-contract
- epic: unify-setup-project
- priority: P1
- size: M
- depends-on: none
- sequence: 2 of 5
- sources: `.icm/project.md` D45 · `_system/contracts/LENSES.md` · `_system/contracts/PROJECT.md`
  · `_system/template/icm-pipeline/MANIFEST` (no `project.md` entry today, neither `T` nor `P`)

## Problem

`/project`'s analysis fans lenses per `LENSES.md`, and writes `.icm/project.md` per the shape
`PROJECT.md` defines — both contracts live only in icm-board's `_system/contracts/`. A
cloud session running the merged skill standalone can't reach either. `.icm/project.md`
itself isn't tracked in the MANIFEST at all today (not `T`, not `P`), so nothing currently
seeds it, syncs it, or protects it from being overwritten by a future sync.

## Proposed change

- Add `project.md` to the MANIFEST as `P` (seeded once by `icm-check.sh --fix` /
  `setup.sh --fix`, then the repo's forever — same discipline as `project.json`).
- Give the lens roster a template-owned home: either inline the lens list (name + one-line
  angle, per `LENSES.md`) directly into the new unified skill (`write-unified-setup-skill`),
  or add a small new `T` reference file (e.g. `_shared/lenses.md`) the skill and the
  `project-lens` agent both read. Decide by what keeps the skill file itself readable — this
  stub's job is to land the content somewhere synced; `write-unified-setup-skill` decides
  exactly how it's referenced.
- Fold `PROJECT.md`'s register shape (Decisions table, Features table, Open questions, Run
  log) into the same new material, generalised — no icm-board-specific structure (icm-board's
  own `project.md` keeps whatever extra sections it already has; this is about what a *repo's*
  register needs).

## Acceptance

- [ ] `project.md` is `P` in the MANIFEST
- [ ] The lens roster and register shape are readable from inside a repo with no `_system/`
      reachable (grep the new material for any `../_system` or `../../_system` path — none)

## Prompt

Read `.icm/intake/unify-setup-project/port-lenses-and-register-contract.md` and
`.icm/intake/unify-setup-project/breakdown.md`. Add `project.md` as `P` to the MANIFEST, and
land the `LENSES.md` roster and `PROJECT.md` register shape somewhere synced and
self-contained — inlined or as a new small `T` file, your call on which reads better.
