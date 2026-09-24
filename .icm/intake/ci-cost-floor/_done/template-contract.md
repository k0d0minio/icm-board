# Stub: The template speaks the cost floor — contracts, setup.sh, the reference quality workflow (D43)

- feature-slug: template-contract
- epic: ci-cost-floor
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 7
- sources: D43 (`.icm/project.md`) · `.icm/docs/2026-09-24-github-actions-audit.md`

## Problem

`_shared/ci.md` said the draft head runs "the cheap tier" of a quality workflow and that label
projection "is CI's job"; Build's step 3 told the session to skip `project-labels.sh` because
`pipeline.yaml` would do it; the project-rules stub asked each repo to name its required checks;
`setup.sh` looked for a reference `labels.yaml`. Every one of those is a minute a private repo
pays for seconds of work.

## Proposed change

Done in the PR that cut this epic (icm-board, `claude/github-actions-audit-98e8ed`):

- `_shared/ci.md` — a new section, **What CI is for — the cost floor**: the table of what
  belongs in CI and what does not; `required_checks` empty by default; the draft head owes
  nothing; advisory is not optional; never add a workflow because it is cheap. The phase table's
  Draft row, the check-run inventory and the smoke section reworded to match.
- `stages/03_build/CONTEXT.md` — the cadence paragraph, step 3 (project the label yourself after
  the `notes.md` push), step 7 (`lint.sh` before every push), step 9 (the pre-flip verdict is the
  scripts'), step 12, Verify.
- `_shared/github.md` → Labels and → Build; `stages/04_release/CONTEXT.md` step 1 and step 3.
- `_shared/project-rules.md` (P stub) → The factory: the verdict, the advisory job, every other
  workflow and what it costs.
- `scripts/setup.sh` §10: looks for `release` / `quality`; names a retired chore workflow, a
  quality workflow with a `push:` trigger, and a build step.
- `github-pipeline/workflows/labels.yaml` deleted; `quality.yaml` added (advisory, ready-only,
  path-filtered, one job, no build, no push).
- The `setup` and `pipeline` skills; `_system/contracts/PIPELINE.md`'s reference-workflow list.

## Acceptance

- [x] `grep -rn 'pipeline.yaml\|labels job' _system/template` returns nothing that says CI
      projects labels.
- [x] `setup.sh` on a repo carrying `pipeline.yaml` warns; on one whose quality workflow has
      `push:` warns.
- [ ] The rollout stubs (2–6) each cite the file the session followed.

## Prompt

Read this stub. The work is done; verify the acceptance lines against the template and close
the stub if anything is left.
