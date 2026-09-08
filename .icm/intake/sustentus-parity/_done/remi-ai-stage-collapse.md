# Stub: Collapse remi-ai's six stages to the estate's four

- feature-slug: remi-ai-stage-collapse
- epic: sustentus-parity
- priority: P1
- size: L
- depends-on: remi-ai-relocate, template-stage-set
- sequence: 6 of 6
- sources: breakdown (`.icm/intake/sustentus-parity/breakdown.md`) · live read of
  `projects/remi-ai/pipeline/stages/` 2026-09-03 (six contracts) · `projects/sustentus/.icm/stages/`
  (four) and its `_shared/github.md` § Labels on the retired `verify`/`ship`/`design` vocabulary ·
  `projects/remi-ai/.github/labels.yml`

## Problem

remi-ai runs six stages — Scope, Design, Define, Build, Verify, Ship. Sustentus runs four — Scope,
Define, Build, Release — having folded Verify and Ship into one stage resting on one human
decision: the **Ready to merge** tick attests all manual and signed-in testing, so Release never
re-asks for it. Design is retired there too; `type:design` survives in `labels.yml` only so
historical PRs keep their label.

Two stages of ceremony per run, and a second gate, for work that has one owner.

remi-ai's `.github/labels.yml` still carries `stage:define | build | verify | ship`, its
`pipeline.yaml` derives the stage label from six-stage output paths, and its
`.claude/skills/pipeline/SKILL.md` frontmatter advertises "the six-stage spine" with `design`,
`verify` and `ship` subcommands.

## Open question — settle before writing the contracts

**Where does the Design stage's demo loop go?** remi-ai has `apps/demo` (port 3005), a mock-data
sandbox built specifically for Design: prototype the agreed scope, deploy it, iterate until the
owner approves from the live URL. Sustentus has no equivalent and retired Design outright, so the
template cannot answer this. Three candidates — fold the demo loop into Scope as an optional step,
keep it as a lane, or drop it and let Build own prototyping. **Ask Jamie before writing any
contract**, and record the answer in the PR description and in remi-ai's `AGENTS.md`.

## Proposed change

Collapse against the corrected template (`template-stage-set`), not by hand-porting sustentus — the
template is where the generalised four-stage contracts now live.

- `.icm/stages/` becomes `01_scope`, `02_define`, `03_build`, `04_release`
- Release absorbs Verify and Ship: gate read → CI verdict → review passes → off-ticket findings
  parked as `intake/triage/` stubs → docs and changelog on the branch → close-out on the branch →
  squash-merge, and the stage ends at the merge
- Design resolved per the open question above
- `.github/labels.yml`: `stage:` vocabulary becomes `define → build → release`;
  `stage:verify`, `stage:ship` and `type:design` stay in the file documented as **historical
  only**, so the five archived runs' PRs keep their labels
- `.github/workflows/pipeline.yaml`: stage derivation re-pointed at the new output paths, still
  mapping the five legacy run layouts
- `.claude/skills/pipeline/SKILL.md`: frontmatter description and routing table cut to four
  stages; `design` / `verify` / `ship` subcommands retired
- `AGENTS.md` § "How work gets done here" updated
- **remi-ai's `_shared/github.md` and `ci.md` reconciled with the template's** (stub 2). After the
  relocation they read as drift against the template; this is where that is settled deliberately
  rather than left as a silent divergence — the PR-event and CI-verdict discipline lands here

## Acceptance criteria (rough)

- [ ] The demo-loop question answered by Jamie before any contract is written, and the answer
      recorded in the PR description and `AGENTS.md`
- [ ] Exactly four stage contracts; no design / verify / ship contract remains
- [ ] `/pipeline design|verify|ship` no longer route; the router's help lists four stages
- [ ] `labels.yml` keeps the retired values, marked historical-only, and the five archived runs'
      PRs still carry valid labels
- [ ] `pipeline.yaml` derives `stage:*` from the new paths and still handles the five legacy runs
- [ ] remi-ai's `_shared/github.md` and `ci.md` carry the PR-event and CI-verdict discipline
- [ ] `AGENTS.md` describes the four-stage spine
- [ ] CI green on the PR

## Prompt

Collapse remi-ai's six-stage pipeline to the estate's four (Scope, Define, Build, Release). Work
in `~/Apps/projects/remi-ai`; read `~/Apps/.icm/intake/sustentus-parity/remi-ai-stage-collapse.md`
and that epic's `breakdown.md` for full context. This depends on two finished tickets: the pipeline
tree must already live at `.icm/` (remi-ai-relocate), and the estate template's four-stage
contracts must exist at `~/Apps/_system/template/icm-pipeline/stages/` (template-stage-set) —
collapse against the template, not by hand-porting sustentus. **Before writing any contract, ask
Jamie where the Design stage's `apps/demo` prototype loop should go** — fold into Scope, become a
lane, or drop — and record the answer in the PR description and `AGENTS.md`. Then: rewrite
`.icm/stages/` as the four stages with Release absorbing Verify and Ship (one human gate — the
Ready-to-merge tick attests the manual smoke test, so Release never re-asks); update
`.github/labels.yml` to the `define → build → release` vocabulary while keeping the retired values
documented as historical-only so the five archived runs' PRs stay valid; re-point
`.github/workflows/pipeline.yaml`'s stage derivation at the new output paths while still mapping
the legacy run layouts; cut `.claude/skills/pipeline/SKILL.md` to four stages; update `AGENTS.md`;
and reconcile remi-ai's `.icm/_shared/github.md` and `ci.md` with the template's so the PR-event
and CI-verdict discipline lands. Open a PR on a `claude/` branch; do not run local checks — CI is
the source of truth. Do not subscribe to the PR. Move this stub to `_done/` in `~/Apps` (it lives
in icm-board, not remi-ai) once the PR merges.
