# Stub: Prove the loop on one repo — a real UI ticket, DESIGN.md to polished preview

- feature-slug: prove-on-one-repo
- epic: design-system-skills
- priority: P1
- size: M
- depends-on: design-md-contract, design-capability-skill, preview-inspection-tooling
- sequence: 6 of 7
- sources: `breakdown.md` → Out of scope ("the proof stub picks up an existing UI ticket") ·
  `projects/casey-hebbel/.icm/intake/` (landing-page epic, €800, a separate designer owns the
  brand — the hardest `DESIGN.md` case: the brand arrives from outside) ·
  `projects/lourenco-botelho/.icm/intake/` (website-copy-v2 — a real redesign on a small repo)
  · `_system/template/icm-pipeline/scripts/icm-sync.sh` (how a single repo gets the new T files
  before the estate does)

## Problem

Stubs 2–4 are each proven on fixtures. Nothing yet shows a Build session on a client repo
reading its `DESIGN.md`, loading the design skill by trigger, inspecting the preview deploy and
closing a critique loop — with a client-visible result at the end. One real run finds what the
fixtures cannot: the trigger that does not fire, the section the schema lacked, the screenshot
the SSO wall ate.

## Proposed change

1. **Pick the repo.** casey-hebbel first (a designer-owned brand tests whether `DESIGN.md` can
   be filled from a supplied brand, not invented); lourenco-botelho if casey-hebbel's designer
   assets are not in hand on the day. Say which and why in the run's `decisions.md`.
2. **Sync only that repo.** `icm-sync.sh --apply <repo>` for the new T files; `icm-check.sh
   --fix <repo>` seeds `DESIGN.md`; run `/setup` and answer the brand questions from the
   designer's material. This is the first `DESIGN.md` written from outside evidence — record
   every section the material could not answer.
3. **Run one existing UI stub** from that repo's intake through the pipeline as a normal run.
   Do not change the ticket to fit the tooling. The Build stage must: load `design` by trigger
   (registry line only in context), build to `DESIGN.md`, wait for the preview deploy,
   `inspect.sh --critique`, close the critique loop, and hand off with the screenshots in
   `output/`.
4. **Write the retrospective** into the run's `handoff.md` → what broke, what was invented,
   what the dials were set to and whether the client-facing result read as the brand. Every
   fix goes back to the template stub that owns it (2, 3 or 4) as a follow-up change on this
   epic, never as a repo-local edit to a T file (the template-change guard, D33).

## Acceptance

- [ ] One client repo carries a filled `DESIGN.md`, the `design` skill and `inspect.sh`, all at
      one template-version stamp, via that repo's own PRs
- [ ] One run on that repo shows in `handoff.md`: the skill loaded by trigger, three
      screenshots per pass, a critique list, and the polish pass — with the preview URL
- [ ] Every defect found is either fixed in icm-board's template (and re-synced) or cut as a
      stub on this epic; the client repo has no in-place edit to a T file
- [ ] Jamie has looked at the preview and said whether it reads as the brand — recorded as
      his words in `handoff.md`, not inferred

## Prompt

Read `.icm/intake/design-system-skills/prove-on-one-repo.md` and
`.icm/intake/design-system-skills/breakdown.md`. Confirm `design-md-contract`,
`design-capability-skill` and `preview-inspection-tooling` have all landed on icm-board `main`.
Pick the repo per the stub, sync it, fill its `DESIGN.md` through `/setup`, then run one of
its existing UI stubs through `/pipeline` in that repo as a normal run. Bring every template
defect back here as a change on the owning stub. Stop at the run's gates — they are Jamie's.
