# Stub: Prove the merged skill end-to-end on one real repo

- feature-slug: prove-on-one-repo
- epic: unify-setup-project
- priority: P0
- size: M
- depends-on: write-unified-setup-skill
- sequence: 4 of 5
- sources: `.icm/project.md` D45 · lourenco-botelho adoption (k0d0minio/lourenco-botelho#7) —
  the repo that surfaced the original bug

## Problem

The merged skill (`write-unified-setup-skill`) is unproven until it runs against a real repo
end-to-end. It needs to be checked from a cold cloud session — no icm-board on disk — to
actually validate D23's standalone requirement, not just read as plausible.

## Proposed change

Run the new skill on lourenco-botelho (small, and the repo that produced the original bug —
its earlier corrections make a natural regression check: did intent-first ordering avoid
re-asking or re-overturning the same two answers). Simulate a cold cloud session (a fresh
clone with no `~/Apps` mounted, or equivalent) to prove the no-icm-board requirement holds.
Fix whatever breaks in the skill text or the newly-synced reference material.

## Acceptance

- [ ] One session run, standalone, produces: `setup.sh` → `RESULT: OK`, a project-owned-files
      PR, an updated `.icm/project.md`, and a ticket cut — in one pass
- [ ] No step reached for `_system/` or icm-board
- [ ] The `editor`/`production_url`-style overturn from the original bug does not recur

## Prompt

Read `.icm/intake/unify-setup-project/prove-on-one-repo.md` and
`.icm/intake/unify-setup-project/breakdown.md`. Confirm `write-unified-setup-skill` has
landed. Run the merged skill against lourenco-botelho from a session with no icm-board
reachable; fix what breaks; report the acceptance checks above.
