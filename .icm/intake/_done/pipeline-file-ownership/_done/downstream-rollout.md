# Stub: Roll the template-owned pipeline files out to the downstream repos

- feature-slug: downstream-rollout
- sequence: 3 of 3
- depends-on: sustentus-first-sync
- priority: P1
- sources: ICM_Refactoring_Directive_v5.md §1 (the boundary this session honoured) ·
  ~/Downloads/ICM_DryRun_Gap_Analysis.md §2.5, §5.2, §5.4, §6.6 ·
  ~/Downloads/ICM_Deep_Dive_Stage_Audit.md §5 G

## Problem

`remi-ai` is on the template's previous shape: it still carries `stages/01_scope/approve/`
(an orphan — its router no longer lists it), a `04_release` with its own ship-note flow
(`scripts/send-ship-note.sh`, step 12) that sustentus's generalised Release does not know,
two "in flight" run folders whose PRs merged on 2026-09-09, five scripts its allowlist
never names, and a `pipeline.yaml` labels job on the diff spelling sustentus documented as
wrong. Any other repo that later declares the pipeline profile inherits the same
questions.

## Proposed change

Per repo, one PR on a `claude/` branch:

1. Write the repo's project-owned files first — `.icm/project.json` (name, `docs_path`,
   archives at the estate defaults, its required check names — a name may contain a comma,
   the array handles it), `_shared/project-rules.md` (who the operator is, how it
   announces: for remi-ai, wire `notify.sh` to what `send-ship-note.sh` does and record
   the script as project-owned), `_shared/knowledge-map.md` (its own pages).
2. `_system/scripts/icm-sync.sh --dry-run projects/<repo>` — read the diff; anything the
   repo's copy had that the template lacks is either folded into the template first (its
   own PR here) or moved into `project-rules.md`.
3. `--apply`, commit; `git rm -r .icm/stages/01_scope/approve/` and any other retired path
   the sync reported; `git mv` merged runs to `runs/_done/`; add the allowlist entries
   (`env-check.sh`, `validate-decisions.sh`, `notify.sh`, `close-out.sh`, `new-run.sh`,
   `ci-status.sh`, `validate-intake.sh`); fix `pipeline.yaml`'s diff spelling to
   `origin/$BASE_REF...$HEAD_SHA`.
4. `.icm/scripts/env-check.sh` → `PASS`; second `--apply` → `UNCHANGED`; open the PR.

## Acceptance criteria (rough)

- [ ] `icm-check.sh` reports `projects/remi-ai (pipeline)` with no `missing` and no pipeline drift
- [ ] remi-ai's ship note still sends after a merge (via `notify.sh` or its CI — project-rules.md says which)
- [ ] no `approve/` folder in any pipeline repo; no merged run in any `runs/`

## Out of scope (this feature)

serviflow (a separate adoption ruling); intake-profile repos (the profile is never seeded
without a declared `- profile: pipeline`).

## Notes for Define

Run from a single session with no worktree sweeper active — four worktrees share one
`projects/` tree. The directive's session boundary (icm-board + sustentus only) ends with
the sustentus PR; this stub is the next session.

Done 2026-09-18 — remi-ai k0d0minio/remi-ai#105
(https://github.com/k0d0minio/remi-ai/pull/105), Jamie's to merge from GitHub. The four steps
ran as written: project-owned files first (`notify.sh` wired to what `send-ship-note.sh` did,
reduced to the one-line summary the contract now sends, `SKIPPED` where the secrets are absent),
`--apply` (28 files, 0 differ afterwards), `approve/` · `send-ship-note.sh` · `_design/` removed,
the three merged runs closed out with `close-out.sh` (`nutrition-knowledge` archived as a
completed epic), the allowlist mirrored on sustentus's, `pipeline.yaml` on the
`origin/$BASE_REF...$HEAD_SHA` spelling; `env-check.sh` → `PASS`, second `--apply` →
`UNCHANGED`, `icm-check.sh --repo` → no gaps, no drift. Two extras the rollout surfaced: the
template's `validate-spec.sh` carried sustentus's persona vocabulary (fixed here, read from
`project.json` now); a gates workflow that projects the PR body is renamed `(advisory)` so the
template's rule-based classification never reds on it. remi-ai's backlog was retriaged into the
template's stub shape in the same PR. **No other repo declares `- profile: pipeline`**, so there
is no further downstream target and the epic is complete.

## Prompt

Read `.icm/intake/_done/pipeline-file-ownership/_done/downstream-rollout.md`. The work shipped
on a remi-ai branch; the PR is Jamie's to merge. Nothing to do here.
