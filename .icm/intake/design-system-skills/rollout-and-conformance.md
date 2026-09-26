# Stub: Rollout — MANIFEST, conformance checks, estate sync, D46 recorded

- feature-slug: rollout-and-conformance
- scope: design-system-skills
- priority: P1
- size: M
- depends-on: prove-on-one-repo
- sequence: 7 of 7
- sources: `breakdown.md` → Where it sits · `_system/template/icm-pipeline/MANIFEST` ·
  `_system/scripts/icm-check.sh` (CANONICAL, BASELINE, PIPELINE_ICM lists; `--fix` seeds,
  never overwrites) · `_system/scripts/icm-sync.sh` (`--apply`, dry-run default, T files only,
  no deletions — D20) · `.icm/project.md` (the register; D45 is the last entry) · the
  `unify-setup-project` epic's rollout stub (the estate-sync shape to copy, including
  serviflow's branch and sustentus's ruleset)

## Problem

After the proof, the design layer exists in the template and in one repo. The other 26 repos,
the conformance scripts and the register do not know it exists. Until `icm-check.sh` counts a
missing `DESIGN.md` and a drifted `design` skill, and until D46 is in the register, the layer is
a local fact, not an estate rule.

## Proposed change

1. **Conformance.** `DESIGN.md` joins the presence checks (`P`: seeded when missing, then the
   repo's); `skills/design/**` are `T` lines (drift-reported, synced by `--apply`); `setup.sh`'s
   Baseline section knows both (`estate-conformance.sh` was retired on 2026-09-26; the disk walk is the only checker).
   `self-check.sh` proves icm-board is held to it too — this repo has no UI, so its own
   `DESIGN.md` is the untouched stub and its `setup.sh` shows the `[WARN]` honestly.
2. **The register.** Jamie records D46 in `.icm/project.md` from the proposal stub 1 wrote and
   stub 6 amended — this stub's PR body quotes the final text and links the report; the
   session does not write the row.
3. **The estate.** `icm-sync.sh --apply` per adopted repo (the same list and the same
   exceptions as the last rollout: serviflow to its open branch, sustentus through a PR on its
   guarded `main`); `icm-check.sh --fix` for the unadopted repos so each gets its `DESIGN.md`
   stub. Plumbing commits go straight to `main` where the estate convention allows; the
   template-version stamp moves with them. `DESIGN.md` is seeded empty everywhere — filling it
   is each repo's next `/setup` run, never this stub.
4. **The board.** `icm-check.sh` run clean across the estate at the end; the warning count
   before and after in the PR body; a triage stub cut for anything it reports that this epic
   did not cause.

## Acceptance

- [ ] `icm-check.sh` reports a repo lacking `DESIGN.md` or drifting on `skills/design/**`, and
      `--fix` seeds only the former
- [ ] Every adopted repo is at one template-version stamp carrying the design skill; every
      unadopted repo has the `DESIGN.md` stub; the per-repo commit/PR list is in the PR body
- [ ] `.icm/project.md` carries D46 in Jamie's hand, and the row links
      `.icm/docs/design-system-skills-research.md`
- [ ] The epic's seven stubs are in `_done/` and the epic folder moves to `intake/_done/` in
      the same commit that closes this one

## Prompt

Read `.icm/intake/design-system-skills/rollout-and-conformance.md` and
`.icm/intake/design-system-skills/breakdown.md`. Confirm `prove-on-one-repo` has landed and read
its run's `handoff.md`. Read `_system/scripts/icm-check.sh`, `icm-sync.sh`, `self-check.sh` and
the previous estate rollout stub under `.icm/intake/_done/`. Do parts 1, 3 and 4 as an
icm-board PR plus per-repo plumbing; part 2 is Jamie's — hand him the text and stop there.
