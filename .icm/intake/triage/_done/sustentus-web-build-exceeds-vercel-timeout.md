# Stub: sustentus's `web` build hit Vercel's maximum build time

- lane: bug
- found-by: sync-mongodb-databases-sustentus · 2026-09-24
- priority: P2
- complexity: standard

## Problem

sustentus/sustentus#1150 (`claude/sentry-web-instrumentation`)'s `web` preview deployment
(`dpl_ECvZgCVoAXQjqe3qZvRG5LvPr44b`) errored with `BUILD_EXCEEDED_MAXIMUM_TIME` — the build ran
past Vercel's per-deployment time limit rather than failing on a compile error. It never reached
`Preview smoke` as a result (unrelated to the D35–D37 MongoDB work, which the copy and migrate
steps on the same PR passed). Adding Sentry instrumentation is a plausible trigger (source-map
upload during build can be slow), but that's a guess — nothing here confirms the cause.

## Proposed change

Read the full build log for `dpl_ECvZgCVoAXQjqe3qZvRG5LvPr44b` (`npx vercel inspect
dpl_ECvZgCVoAXQjqe3qZvRG5LvPr44b --logs` from a shell with `VERCEL_TOKEN`, or the Vercel
dashboard) to find where the build stalled or slowed. If it's the Sentry source-map upload,
either scope it to production builds only or move it off the critical build path. If it's
something else, this stub is the place to record what was actually found.

## Prompt

In icm-board, read `.icm/intake/triage/sustentus-web-build-exceeds-vercel-timeout.md`. Pull the
full build log for `dpl_ECvZgCVoAXQjqe3qZvRG5LvPr44b` (sustentus's `web` project) and work out
why the build exceeded Vercel's maximum build time. Fix it in `projects/sustentus` on a `claude/`
branch, through a PR (sustentus requires one).
