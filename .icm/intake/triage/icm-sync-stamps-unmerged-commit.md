# Stub: icm-sync.sh stamps whatever commit its checkout is on — a repo can claim a template main never had

- feature-slug: icm-sync-stamps-unmerged-commit
- lane: tweak
- found-by: decision-numbering + estate sync review, 2026-09-23
- priority: P1
- size: S
- sources: `_system/scripts/icm-sync.sh` (the `tv_commit` stamp — `git rev-parse --short HEAD` of
  the template's own checkout) · `.icm/template-version` on `origin/main` of the six pipeline repos,
  read 2026-09-23

## Problem

Every pipeline repo's `.icm/template-version` names a commit that is **not on icm-board's `main`**:
five name `5bef762` (the pre-squash head of #60's branch) and sustentus names `be76910` (#64's branch
before it was rebased over #66). `5bef762`'s template is byte-identical to what #60 merged, so those
five are only hard to trace. `be76910` is worse: it is D35–D37 **without** D38 — a template state
`main` never held — because the sync was run from the D37 branch while it was under test.

Nothing is corrupt (every repo's T files match the template at its stamp exactly — checked
2026-09-23), but `setup.sh`'s "current?" answer and any `git log main` lookup of a stamp fail, and
a sync from an unmerged branch can ship a template that is then changed before it merges.

## Proposed change

- `icm-sync.sh --apply`: when the template checkout's `HEAD` is not contained in `origin/main`, refuse
  unless an explicit `--from-branch` flag is given (the lab/testing case), and in that case write the
  branch name into `.icm/template-version` beside the commit so the stamp says what it is.
- Dry runs only warn.
- Document the flag in the script header and `_system/template/README.md`.

## Acceptance criteria

- [ ] `--apply` from a feature-branch checkout refuses without `--from-branch`, with a one-line reason
- [ ] `--apply --from-branch` stamps `branch: <name>` in `.icm/template-version`
- [ ] `--apply` from `main` behaves exactly as today
- [ ] `self-check.sh` green in CI

## Prompt

In icm-board (`~/Apps`), read `.icm/intake/triage/icm-sync-stamps-unmerged-commit.md` and carry it
out: make `_system/scripts/icm-sync.sh --apply` refuse to stamp a template commit that is not on
`origin/main` unless `--from-branch` is passed, record the branch in `.icm/template-version` when
it is, and document the flag. Prove it on scratch fixtures (a bare origin plus a throwaway target
repo), never on a real `projects/` repo. Ship it as a PR on a `claude/` branch; CI is the check.
