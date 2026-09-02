# Stub: Pull courseday and pierpont back into projects/

- lane: chore
- found-by: Vercel env research session 2026-09-02 · Jamie's ruling same session
- priority: P2
- sources: kodominio Vercel listing 2026-09-02 — both deploy from `k0d0minio` GitHub
  repos (`courseday`, `pierpont`) with no local clone

## Problem

courseday and pierpont deploy on kodominio but have no folder in `projects/`, so they
are invisible to every estate ritual — icm-check, ticket scouting, the coming env
system's registry. Jamie's call: these two live on (unlike the six being retired) and
belong back on disk.

## Proposed change

Clone `k0d0minio/courseday` and `k0d0minio/pierpont` into `projects/` (gitignored
here — no commit in icm-board beyond this stub's move). That is the whole stub:
baseline gaps become icm-check's findings, and proper adoption (intent, lenses,
tickets) is `/project`'s judgment work when Jamie runs it — not a side effect here.
Once the env system's registry exists, add both repos to it (or note them for the
registry stub if it hasn't landed yet).

## Prompt

Clone the two returning estate repos in the icm-board repo's machine (`~/Apps`):
`k0d0minio/courseday` and `k0d0minio/pierpont` into `projects/`. Read
.icm/intake/triage/adopt-courseday-pierpont.md for context. Clone only — do not run
adoption, cut tickets in those repos, or fix baseline gaps; icm-check and /project own
that. If `_system/scripts/vercel-env-registry.json` exists, add both repos' kodominio
mappings. Move this stub to triage's `_done/` in a ticket-only commit to main.
