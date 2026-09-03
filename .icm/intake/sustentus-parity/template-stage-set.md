# Stub: Re-found the template's pipeline profile on sustentus's current four stages

- feature-slug: template-stage-set
- epic: sustentus-parity
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 6
- sources: breakdown (`.icm/intake/sustentus-parity/breakdown.md`) · live read of
  `projects/sustentus/.icm/stages/` + `.icm/scripts/` 2026-09-03 · `_system/template/icm-pipeline/`
  · `_system/contracts/PIPELINE.md`

## Problem

The template's pipeline profile ships three stages — `01_define`, `02_build`, `03_release`.
Sustentus, the repo the profile was extracted from (D12), now runs four: `01_scope`,
`02_define`, `03_build`, `04_release`. The front (a written story committed verbatim, the
business logic interrogated, then an intake batch cut) is a stage in the source and absent from
the template, and `contracts/PIPELINE.md` documents the three-stage set at its layout block.

The template's `scripts/` is also short of the source: it carries `ci-status.sh`, `new-run.sh`,
`resolve-run.sh`, `validate-spec.sh`, `validate-intake.sh`; sustentus additionally has
`close-out.sh` (the archive move, run on the branch before the merge so the squash publishes it)
and `project-labels.sh` (the `stage:*` projection CI runs on every push).

The consequence is concrete: a repo declaring `- profile: pipeline` today is seeded with a shape
its own source has already left behind, and then has to be migrated later — which is stub 5–6 of
this epic.

## Proposed change

Re-found `_system/template/icm-pipeline/` on sustentus's current shape, **generalised** — not
templated. The template's own rule is "no substitutions; a copy is exact", so the work is
removing sustentus's identity, not parameterising it.

- `stages/` becomes `01_scope`, `02_define`, `03_build`, `04_release`. The three-stage set goes.
  Release carries sustentus's semantics: one stage, one human decision, the **Ready to merge**
  tick attesting the manual smoke test so the stage never re-asks for it.
- Strip every sustentus-specific fact: the `sustentus/sustentus` repo literal, named people
  (Paul, David, Jamie as the gate-ticker → "the owner"), the eight-Vercel-projects count,
  `apps/docs/archive/**` paths, `#alerts`, `Quality Project` as a required-check name.
- Add `close-out.sh` and `project-labels.sh`, repo-neutral in the house style: owner/repo derived
  from `origin` with `GITHUB_REPO` override, config from the environment, same exit-code contract
  as the existing five.
- Update `_system/contracts/PIPELINE.md` — the layout block, the prose that walks
  `01_define → 03_release`, the scripts table. Re-state the `pipeline-full` row honestly now that
  the front is standard (do not delete it — see the epic's Out of scope).
- Update `_system/template/claude-pipeline/skills/pipeline/SKILL.md` to route four stages, and
  `_system/template/README.md`'s tree.
- `github-pipeline/pull_request_template.md` keeps both gate anchors unchanged.

## Acceptance criteria (rough)

- [ ] `template/icm-pipeline/stages/` is exactly `01_scope`, `02_define`, `03_build`, `04_release`
- [ ] No sustentus identity survives anywhere in `template/`: no owner/repo literal, no personal
      names, no deploy-target counts, no `apps/docs/**` path, no repo-specific check name
- [ ] `close-out.sh` and `project-labels.sh` present, repo-neutral, documented in
      `template/README.md` and `PIPELINE.md`'s scripts table
- [ ] `PIPELINE.md` describes the four-stage spine; no stale `01_define`/`02_build`/`03_release`
      reference remains anywhere in `_system/`
- [ ] The pipeline SKILL.md routes `scope | define | build | release` plus the three lanes
- [ ] `_system/scripts/icm-check.sh` run against a scratch `- profile: pipeline` repo seeds the
      four-stage set and nothing stale (report only — this is not a build/lint/test)

## Prompt

Re-found the estate template's pipeline profile on sustentus's current four-stage shape, in the
icm-board repo (`~/Apps`). Read `.icm/intake/sustentus-parity/template-stage-set.md` and the
epic's `breakdown.md` for full context. The source of truth is
`projects/sustentus/.icm/stages/` and `projects/sustentus/.icm/scripts/` on this machine — read
them, then rewrite `_system/template/icm-pipeline/stages/` as `01_scope`, `02_define`,
`03_build`, `04_release`, add repo-neutral `close-out.sh` and `project-labels.sh`, and update
`_system/contracts/PIPELINE.md`, `_system/template/README.md` and
`_system/template/claude-pipeline/skills/pipeline/SKILL.md` to match. Generalise sustentus's
identity out (repo literal, people's names, deploy-target counts, `apps/docs/**` paths) — do not
parameterise it; the template is copied exactly, which is what makes its drift report honest. Do
not touch sustentus. Open a PR on a `claude/` branch; do not run local checks — CI is the source
of truth. Move this stub to the epic's `_done/` in that PR.
