# Stub: img2threejs — a user-global, opt-in skill for the one repo that renders 3D

- feature-slug: img2threejs-machine-install
- epic: design-system-skills
- priority: P2
- size: S
- depends-on: research-fit-and-overlap
- sequence: 5 of 7
- sources: `breakdown.md` → What I understood (2: sustentus marketing is the only three.js
  user) · `img2threejs/img2threejs` README + `SKILL.md` (33 KB; install is `git clone …
  ~/.claude/skills/img2threejs`, user-global, also `~/.codex/skills/`; Python 3.10+; writes
  `.img2threejs/state.json`, `object-sculpt-spec.json`, `src/create<Name>Model.ts` into the
  target project; profiles `generic | character | cs2 | animated-character`; Apache-2.0)

## Problem

img2threejs turns a reference image into a procedural Three.js model. It is heavy (a Python
stage pipeline, a 33 KB skill, its own state directory inside the target repo) and its
upstream install is user-global by design. One estate repo depends on three.js today. Putting
it in the template would seed every repo with a capability 26 of them cannot use.

## Proposed change

Unless stub 1's report reverses the verdict, keep it off the template entirely:

1. Install once on Jamie's machine per upstream (`~/.claude/skills/img2threejs`, symlinked for
   OpenCode if the report found a reachable path), pinned to the SHA the report read; record
   the install and pin in the machine-local tools note, not in any repo.
2. In `projects/sustentus`, one line in `.icm/_shared/project-rules.md` → Capability skills
   naming it as an available machine-level skill for `apps/marketing`, with the two
   gitignore lines its outputs need (`.img2threejs/`, and the render/comparison sheets) — a
   PR in sustentus, through its ruleset-guarded `main`.
3. Nothing in `_system/template/`. If a second repo ever needs 3D, that is a new triage stub,
   not a reason to reopen this one.

If the report instead finds a general use (say, hero imagery for every landing page), replace
this stub's plan with that finding and re-cut — do not widen it in place.

## Acceptance

- [ ] `~/.claude/skills/img2threejs/SKILL.md` present at the pinned SHA; the machine note
      records the SHA and the Python version found
- [ ] sustentus `project-rules.md` names the skill and the ignore lines are in its
      `.gitignore`, merged via PR
- [ ] `git grep img2threejs _system/template` in icm-board returns nothing

## Prompt

Read `.icm/intake/design-system-skills/img2threejs-machine-install.md` and
`.icm/intake/design-system-skills/breakdown.md`, then the img2threejs verdict in
`.icm/docs/design-system-skills-research.md`. If it says "machine-level, opt-in", do the three
steps above — the machine install is Jamie's act to confirm, the sustentus change is a PR in
that repo. If the verdict differs, stop and say what it says instead.
