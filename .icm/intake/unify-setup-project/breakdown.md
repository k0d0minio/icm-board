# Breakdown: One command, one file — /setup absorbs /project's adoption ritual (D45)

- scope-slug: unify-setup-project
- sources: `.icm/intake/triage/_done/merge-setup-and-project.md` (the original find, settled
  as this epic) · `.icm/project.md` D45 · D23 (the split this replaces) · lourenco-botelho
  adoption evidence, k0d0minio/lourenco-botelho#7 · Jamie, 2026-09-25 — "I want a single
  entry point for running all the current project and setup steps... contained to a single
  file... runnable from the cloud sessions (i.e a command in each repo)"

## What I understood

D23 split repo adoption across two homes: `/setup` (in the repo, project-owned config,
callable with zero icm-board in view — a deliberate cloud-session requirement) and `/project`
(in icm-board, intent, lens analysis, ticket cutting). Adopting a repo today is four steps
across those two homes. Worse, nothing stops `/setup`'s config questions being asked and
answered before `/project` has ever established intent — exactly what happened on
lourenco-botelho, where `/project`'s later interrogation overturned two answers `/setup` had
already locked in an hour earlier, landing as extra commits on the open setup PR.

Jamie's call (D45): fuse both into **one skill file**, synced to every repo, that a cloud
session with no icm-board can run standalone — running intent interrogation *before* any
config question is asked, so the ordering bug can't recur. This is a genuine build, not a
reorder: `/project`'s ritual (register, posture, interrogation, lens fan-out, reconcile,
ticket cut) has **zero footprint in the synced template today** — `LENSES.md`, `PROJECT.md`
and the `project-lens`/`ticket-scout` agents exist only in icm-board. They need a home in the
template before the merged skill can use them standalone.

## Where it sits

`_system/template/claude-pipeline/skills/setup/SKILL.md` (rewritten in place — same skill
name/slot, new contents), `_system/template/claude/agents/` (two new files), the template
`MANIFEST`, and — on the icm-board side — `workspaces/deliver/stages/project/CONTEXT.md` and
`.claude/commands/project.md` (retired once rollout lands). Proven first on one repo before
any estate-wide sync.

## Build order

1. `sync-lens-and-scout-agents` — `project-lens.md` and `ticket-scout.md` promoted from
   icm-board-only to `T` files, synced to every repo's `.claude/agents/`.
2. `port-lenses-and-register-contract` — the lens roster and the `.icm/project.md` register
   shape get a template-owned home (inlined in the new skill or a small new `T` reference
   file); `project.md` added to the MANIFEST as `P` (seeded once, never resynced).
3. `write-unified-setup-skill` — the actual merged skill: `setup.sh` checks and questions
   fused with `/project`'s register/posture/interrogate/lens/reconcile/ticket-cut ritual, in
   one file, intent-first.
4. `prove-on-one-repo` — run the new skill end-to-end on a real repo (lourenco-botelho is the
   obvious candidate — it's the repo that surfaced the bug, and it's small), fix what breaks.
5. `retire-project-command-and-rollout` — repoint or retire icm-board's `/project` command,
   sync the new skill across the rest of the estate.

## Parallelizable

1 and 2 are independent of each other; both must land before 3. 3 before 4 before 5.

## Out of scope (whole scope)

- Changing `/setup`'s no-default-template-source design (D23) — untouched.
- Changing D22's `complexity`-in-`project.json` shape — untouched.
- Ticket commit conventions (ticket-only straight to `main`, register on a `claude/` PR) —
  unchanged; "one file" means one entry point Jamie runs, not one git operation.
