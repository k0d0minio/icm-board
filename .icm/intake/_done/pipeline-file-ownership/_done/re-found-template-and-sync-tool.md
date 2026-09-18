# Stub: Re-found the pipeline template from sustentus and ship the sync tool

- feature-slug: re-found-template-and-sync-tool
- sequence: 1 of 3
- depends-on: none
- priority: P0
- sources: ICM_Refactoring_Directive_v5.md · ~/Downloads/ICM_DryRun_Gap_Analysis.md ·
  ~/Downloads/ICM_Deep_Dive_Stage_Audit.md · .icm/project.md D20–D21

## Problem

The template lagged its source by fourteen sustentus PRs and still shipped the `approve`
substage sustentus deleted on 2026-09-15; its scripts lacked the `lib/` they source; nothing
distinguished a file the estate owns from one a repo owns, so "drift" was a report with no
lawful repair.

## Proposed change

Copy sustentus's `.icm/` contracts, shared docs, scripts and `lib/` into
`_system/template/icm-pipeline/`; remove every identity token per the vocabulary in the
verification report; delete `stages/01_scope/approve/` and every reference; add
`MANIFEST` (T/P ownership), `lib/project.sh`, `env-check.sh`, `validate-decisions.sh`, the
`P` stubs; write `_system/scripts/icm-sync.sh`; rewire `icm-check.sh` to the manifest with a
pipeline drift report and `--repo`; update `PIPELINE.md`, `template/README.md`,
`_system/README.md`, `AGENTS.md`, the conformance contract; record D20–D21.

## Acceptance criteria (rough)

- [ ] `grep -rn "sustentus|Jamie|Paul|David|apps/docs|#alerts|Quality Project|approve/"` over the template returns nothing
- [ ] `icm-check.sh` reads `MANIFEST`; no `approve` reference anywhere under `_system/`
- [ ] `icm-sync.sh --dry-run` then `--apply` on sustentus; a second `--apply` reports `UNCHANGED`

## Out of scope (this feature)

Downstream repos; CI workflow changes in any repo.

## Notes for Define

Done in the session that cut this epic (2026-09-18) — see the verification report in
`.icm/docs/`.

## Prompt

Read `.icm/intake/pipeline-file-ownership/_done/re-found-template-and-sync-tool.md` and
`.icm/project.md` D20. The work shipped in the PR that moved this stub here; nothing to do.
