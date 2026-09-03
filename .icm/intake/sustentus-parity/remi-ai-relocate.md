# Stub: Move remi-ai's pipeline into .icm/ and declare the pipeline profile

- feature-slug: remi-ai-relocate
- epic: sustentus-parity
- priority: P1
- size: M
- depends-on: none
- sequence: 5 of 6
- sources: breakdown (`.icm/intake/sustentus-parity/breakdown.md`) · live read of
  `projects/remi-ai/` 2026-09-03 — `pipeline/` tree, `.icm/CONTEXT.md`,
  `.claude/skills/pipeline/SKILL.md`, `.github/workflows/pipeline.yaml`,
  `.github/pull_request_template.md`, `.github/labels.yml`, `AGENTS.md`

## Problem

remi-ai's `.icm/CONTEXT.md` declares `- profile: intake`, yet the repo carries a complete
six-stage delivery pipeline at **`pipeline/`** — a root folder the estate has since replaced with
`.icm/`. Because the profile line says `intake`, `icm-check.sh` never checks or seeds the pipeline
assets, and because the tree is at `pipeline/` it would not find them if it did.

The half-move has already broken something live: remi-ai's real intake moved to `.icm/intake/`
(the `patient-record` and `patient-surface` epics plus `triage/` are there now), while
`.claude/skills/pipeline/SKILL.md` still globs `pipeline/intake/*/*.md` — which matches nothing.
`/pipeline new` finds no stubs. `pipeline/intake/` holds a single orphaned `CONTEXT.md`.

The old paths are also hardcoded in CI and the PR template:

- `.github/workflows/pipeline.yaml` reads `pipeline/runs/$slug/03_define/output/spec.md` (label
  projection) and greps changed paths against `^pipeline/runs/[^/]+/03_define/output/spec.md$`
- `.github/pull_request_template.md` points the canonical spec link at the same path
- `AGENTS.md` routes to `pipeline/CONTEXT.md` and `pipeline/stages/NN_*/CONTEXT.md`

## Proposed change

Mechanical relocation only — **no stage semantics change here**; the six stages move as they are
and stub 6 collapses them. Splitting it this way keeps the path rewrite reviewable on its own and
lets CI prove the move before any contract is rewritten.

- `git mv pipeline/{stages,lanes,runs,_shared,scripts,_design}` → `.icm/`, and fold
  `pipeline/CONTEXT.md`'s map into `.icm/CONTEXT.md`
- Delete the orphaned `pipeline/intake/` — `.icm/intake/` is already the real one
- `.icm/CONTEXT.md`: `- profile: intake` → `- profile: pipeline`
- Rewrite every `pipeline/` path reference in: `.claude/skills/pipeline/SKILL.md` (including the
  stub glob, which starts finding the two live epics again), `.github/workflows/pipeline.yaml`,
  `.github/pull_request_template.md`, `AGENTS.md`'s routing table, and each stage/lane contract's
  own Inputs
- The five run folders (`anamnesis-structure`, `data-care`, `migrate-preview-guard`,
  `pantry-essentials`, `profile-fields`) move **as-is**. Their internal stage numbering is not
  renumbered — Jamie's call 2026-09-03 — so `pipeline.yaml`'s label derivation must keep reading
  their historical layout, the way sustentus's `project-labels.sh` maps legacy paths

One PR. CI is the proof the paths are right.

## Acceptance criteria (rough)

- [ ] No `pipeline/` directory remains, and no file in the repo references `pipeline/` as a path
- [ ] `.icm/CONTEXT.md` declares `- profile: pipeline`
- [ ] `/pipeline new` resolves stubs from `.icm/intake/*/*.md` and finds the live
      `patient-record` / `patient-surface` work
- [ ] The five run folders resolve under `.icm/runs/` and still label correctly
- [ ] PR template's canonical spec link points at the new path
- [ ] `AGENTS.md` routing table points at `.icm/`
- [ ] CI green on the PR
- [ ] `icm-check.sh` run from icm-board now sees remi-ai as a pipeline-profile repo

## Prompt

Relocate remi-ai's delivery pipeline from `pipeline/` into `.icm/` and adopt the estate pipeline
profile. Work in `~/Apps/projects/remi-ai`; read
`~/Apps/.icm/intake/sustentus-parity/remi-ai-relocate.md` and that epic's `breakdown.md` for full
context. This is a **mechanical move only** — do not change any stage's semantics or count; a
later ticket collapses six stages to four. `git mv` `stages/`, `lanes/`, `runs/`, `_shared/`,
`scripts/` and `_design/` into `.icm/`, fold `pipeline/CONTEXT.md` into `.icm/CONTEXT.md`, delete
the orphaned `pipeline/intake/` (the real intake is already `.icm/intake/`), and set
`- profile: pipeline`. Then rewrite every `pipeline/` path reference in
`.claude/skills/pipeline/SKILL.md` (its stub glob currently matches nothing — that is the bug this
fixes), `.github/workflows/pipeline.yaml`, `.github/pull_request_template.md`, `AGENTS.md` and
each stage and lane contract. Move the five existing run folders as-is without renumbering their
internal stages, and keep the CI label derivation reading their historical layout. Open a PR on a
`claude/` branch; do not run local checks — CI is the source of truth. Do not subscribe to the PR.
Move this stub to `_done/` in `~/Apps` (it lives in icm-board, not remi-ai) once the PR merges.
