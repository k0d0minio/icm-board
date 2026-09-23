# Stub: preview_<branch> database names overflow Atlas's shared-tier 38-byte cap

- lane: bug
- found-by: sync-mongodb-databases-sustentus · 2026-09-23
- priority: P1
- complexity: standard

## Problem

D36's first real PR (sustentus/sustentus#1150, branch `claude/sentry-web-instrumentation`) failed
its `Migrate preview database` step. `db-migrate.yaml`'s copy (`mongodump | mongorestore
--nsFrom/--nsTo`) tried to create `preview_claude_sentry_web_instrumentation` — 42 bytes, under
`lib/db-name.mjs`'s `MAX_DB_NAME = 63` — and Atlas refused it:

    Failed: preview_claude_sentry_web_instrumentation: error reading database: (AtlasError)
    Database name preview_claude_sentry_web_instrumentation is too long. Max database name
    length is 38 bytes.

MongoDB's own 63-byte limit only applies to dedicated (M10+) clusters. Shared and free tiers
(M0/M2/M5) — what D36 put `sustentus-staging` (the non-production cluster every `preview_<branch>`
and `run_<slug>` lands on) on — cap database names at 38 bytes. `db-name.mjs` was written against
the wrong limit, so any branch name longer than about 30 characters after normalising (very
common — this one is 34) breaks the copy step, not just a rare long-name edge case.

The mongorestore failure then cascades: mongodump's writer sees the piped mongorestore exit and
fails with `broken pipe`, which is a symptom, not a second bug.

## Proposed change

In `_system/template/icm-pipeline/scripts/lib/db-name.mjs`:
- Make the cap a parameter, not the hard-coded `MAX_DB_NAME = 63`, and read it from
  `database.mongodb.limits` (alongside the existing `databases`/`collections` counts) with a
  default that matches Atlas's shared/free tiers (38), since that's what every adopter so far
  (sustentus) is actually on. A dedicated-tier adopter declares `limits.name_bytes: 63` (or
  whatever M10+ allows) to get the longer form.
- The FNV-1a fallback logic already handles "too long" — it just needs the right threshold, and
  the CLI/`databaseName()` call sites need the limit threaded through from `project.json` rather
  than the module constant.
- Re-derive `preview_claude_sentry_web_instrumentation` under the new cap and confirm it lands
  under 38 bytes with the hash suffix, then re-run PR #1150's `Migrate preview database` step.

## Progress

- 2026-09-23, night: fix up as k0d0minio/icm-board#64 (D37 — `limits.name_bytes`, default 38; the
  CLI reads it from `project.json`), CI green, **unmerged** (merging is Jamie's call). Synced from
  its branch (stamp `be76910`) as sustentus/sustentus#1152, **unmerged**. That PR's own branch
  proved the copy on the real cluster: `claude/sync-template-d37-db-name-cap` →
  `preview_claude_sync_template__fbabc977` (38 bytes), 6907 documents restored, no pending
  migrations. Its `Preview smoke` failed 4 of 6 walks on React #418, sustentus's own parked
  `triage/react-418-hydration-mismatch-on-three-routes`, not this bug. (The branch in this stub
  normalises to 41 bytes, not 42.) **Left:** merge #64, merge #1152, then
  `gh pr update-branch 1150` in sustentus. A re-run of the old job would reuse the old merge ref
  and fail again. #1150's `Migrate preview database` should then copy into
  `preview_claude_sentry_web_ins_65692577`. Then move this stub to `_done/`.

## Prompt

In icm-board, read `.icm/intake/triage/mongo-preview-db-name-atlas-shared-tier-cap.md` and the
D35/D36 rows of `.icm/project.md`. Fix `lib/db-name.mjs`'s name-length cap to be configurable via
`database.mongodb.limits` (default 38, matching Atlas shared/free tiers) instead of the hard-coded
63-byte MongoDB dedicated-tier limit, as a template PR on a `claude/` branch. Prove it against a
branch name that reproduces this failure (`claude/sentry-web-instrumentation`), then sync the fix
into sustentus and re-run sustentus/sustentus#1150's preview-migrate step.
