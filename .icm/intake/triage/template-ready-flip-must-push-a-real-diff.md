# Stub: the Build ready flip's fallback push is an empty commit, which builds no preview

- lane: bug
- found-by: template-change (sustentus triage/build-ready-flip-empty-commit-builds-no-preview, the template half) · 2026-09-26
- priority: P1
- complexity: low
- sources: `_system/template/icm-pipeline/stages/03_build/CONTEXT.md:184` · `.icm/docs/ready-flip-previews.md` in sustentus (2026-09-15)

## Problem

Step 10 of Build says to flip the PR ready and push "an empty commit (`git commit --allow-empty`)
when nothing is pending". An empty diff makes Vercel's native "Skip deployment for unaffected
projects" drop every project before `turbo-ignore` runs, so the ready head has no preview and
nothing to host the pre-tick smoke. `ci-status.sh` learned to classify `Skipped - Not affected`
as skipped on 2026-09-15 (the repo half); the contract line that causes the empty push is
template-owned and unchanged.

## Proposed change

Commit `03_build/output/notes.md` (and the usage end line) *after* the flip rather than before it,
so the ready push always carries a real diff; delete the `--allow-empty` sentence; say in the same
step that a head whose every product project reads `Skipped - Not affected` has no preview and
is not a pass. Sync per repo; the source stub's template half retires with `- superseded-by:`.
