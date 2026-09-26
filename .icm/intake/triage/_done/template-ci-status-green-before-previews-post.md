# Stub: ci-status.sh settles GREEN before a ready head's Vercel statuses have posted

- lane: bug
- found-by: template-change (sustentus triage/template-change-ci-status-green-before-previews-post · sustentus triage/template-change-ci-status-premature-full-gate-green) · 2026-09-26
- priority: P1
- complexity: medium
- sources: `_system/template/icm-pipeline/scripts/ci-status.sh:385` · sustentus run smoke-visual-verdict (PR 1162, push 28a8620) error.log

## Problem

On a READY head whose declared product projects have posted nothing yet, `ci-status.sh` prints
`[INFO] <ctx>: expected … not yet posted — not waited on` and returns `RESULT: GREEN` "settled on
the full gate". Vercel had the build `BUILDING` at that moment. Build step 12 reads GREEN as the
full verdict, so a stage can hand over a preview that has not built — or has failed — as green.
Two sustentus stubs describe the same root (the D43 gate is the deploy status, and the deploy
status is not there yet).

## Proposed change

A declared product project with no status on a READY head is PENDING, not absent: wait for it the
way workflow checks are waited for (bounded — the existing `--watch` budget), and only settle GREEN
once every declared product project has posted READY, `Skipped - Not affected` or
`Canceled by Ignored Build Step`. Fixture the three states. Sync per repo; both source stubs retire
with `- superseded-by:`.
