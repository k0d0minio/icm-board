# Stub: Sync sustentus as the first target and prove idempotency

- feature-slug: sustentus-first-sync
- sequence: 2 of 3
- depends-on: re-found-template-and-sync-tool
- priority: P0
- sources: ICM_Refactoring_Directive_v5.md §6 Phases 1 and 3

## Problem

Until one real repo carries the template-owned files byte-for-byte and its project-owned
files untouched across two consecutive `--apply` runs, the ownership split is a claim.

## Proposed change

On a `claude/` branch in `projects/sustentus`: add `.icm/project.json` (name, docs path,
archive paths, required check, smoke check), `_shared/project-rules.md` (the identity the
template lost, re-homed), `scripts/notify.sh` (a stub — `release.yaml` announces), the
`- profile: pipeline` line, allowlist entries for the new scripts; run `icm-sync.sh --apply`
from icm-board; commit; run it again → `UNCHANGED`; run `env-check.sh` and
`validate-decisions.sh agentic-dashboard`; open the PR for Jamie to merge.

## Acceptance criteria (rough)

- [ ] `git status` on the sustentus branch after the sync shows only template-owned files changed
- [ ] second `--apply` → `RESULT: UNCHANGED`
- [ ] `env-check.sh` → `RESULT: PASS`; `validate-decisions.sh agentic-dashboard` → `RESULT: OK` (spec not yet written)

## Out of scope (this feature)

Merging the sustentus PR (Jamie's, from GitHub). Any other repo.

## Notes for Define

Done 2026-09-18 — sustentus/sustentus#1138 (https://github.com/sustentus/sustentus/pull/1138),
Jamie's to merge from GitHub.

## Prompt

Read `.icm/intake/pipeline-file-ownership/_done/sustentus-first-sync.md`. The work shipped
on a sustentus branch; the PR is Jamie's to merge. Nothing to do here.
