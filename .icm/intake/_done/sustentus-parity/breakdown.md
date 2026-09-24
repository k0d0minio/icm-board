# Breakdown: Sustentus parity — the estate inherits the operating discipline and the current stage set

- epic-slug: sustentus-parity
- sources: interrogation 2026-09-03, Jamie's rulings — propagation is **per-repo PRs**, no
  `--sync` tooling; remi-ai migrates **fully** (relocate + profile + collapse) with its five
  existing runs archived as-is, not renumbered · live read of sustentus
  `.icm/_shared/{github,ci}.md`, `.icm/stages/`, `.icm/scripts/`, `.claude/settings.json` ·
  live read of `_system/template/` and `_system/contracts/PIPELINE.md` · inventory of all 26
  repos under `projects/` (profile line, Layer 0, canonical assets, byte-drift) · live read of
  remi-ai `pipeline/`, `.github/`, `.claude/skills/pipeline/SKILL.md`

## What I understood

Sustentus has paid for its operating discipline in incidents, and the estate has not inherited
it. Two things are wrong at once, and they are the same thing seen from two ends.

**The doctrine never left sustentus.** Its `.icm/_shared/github.md` (198 lines) and `ci.md`
(135) carry the rules that keep an agent session cheap: no PR in the repository is subscribed —
and the rule binds the harness, not just the pipeline, because a harness may auto-subscribe
after `create_pull_request` and some instruct the agent to watch every PR it opens, so a
session that finds itself subscribed unsubscribes and says so. One push produces a dozen-plus
events — every deploy target cycling `pending`→`success`, the deploy bot posting and re-editing
its comment table, each Actions job starting and finishing — and not one of them is a verdict.
Measured on PR #948 (2026-09-02): a dozen wake-ups, every one of them "nothing red, no action".
The answer is one blocking CI call per push, whose waiting costs wall-clock rather than model
turns, plus one review-comments read at the merge point. Anything longer-running is a
**scheduled check-in** — one timed wake that reads state once and re-arms — never a
subscription. The template's copies of those two files compress all of it into a single bullet
("Never subscribe to PR activity") with no unsubscribe instruction, no harness-default
override, and none of the stray-event rules. And those two files are **pipeline-profile only**:
23 of the 26 repos under `projects/` are `- profile: intake` and receive `pr-conventions` +
`ticket-craft` and nothing else — so the discipline reaches none of the repos where the noise is
worst. Every one of them deploys on Vercel; every push is a deploy-status burst.

**The template has drifted from the source it was extracted from.** Sustentus is the origin of
the estate pipeline (D12) and it now runs four stages — Scope, Define, Build, Release, where
Release replaced Verify and Ship with one stage resting on one human tick. The template still
ships three (`01_define`, `02_build`, `03_release`), and is missing `close-out.sh` and
`project-labels.sh`. `contracts/PIPELINE.md` documents the three-stage set. Any repo adopting
the pipeline profile today inherits a shape its source already left behind — which is exactly
the trap remi-ai is in: it declares `- profile: intake`, carries a **six**-stage pipeline
(scope, design, define, build, verify, ship) at `pipeline/` rather than `.icm/`, so `icm-check`
cannot see, check or seed it; its intake already moved to `.icm/intake/` while
`.claude/skills/pipeline/SKILL.md` still globs `pipeline/intake/*/*.md` and therefore finds
nothing, and its CI and PR template hardcode `pipeline/runs/<slug>/03_define/output/spec.md`.

So: fix the template first (stubs 1–2), give the intake repos the half they can act on (3),
carry it to them by hand (4), and land remi-ai on the corrected shape (5–6).

Propagation is deliberately unautomated. `--fix` seeds only what is missing and drift is
reported, never repaired — repos own their copies (D7) — and Jamie's ruling on 2026-09-03 was
to keep it that way: the rollout is per-repo PRs, exactly as `push-gate-propagation` carried
the narrowed OpenCode push gate to 24 repos. No sync tool.

## Build order

1. template-stage-set — template pipeline profile re-founded on sustentus's current four stages — depends-on: none
2. shared-pr-noise-contract — the PR-event + CI-verdict discipline ported into the template's `_shared/` — depends-on: none
3. intake-agent-economy — the same discipline in the form an intake repo can act on: `pr-conventions` + House doctrine — depends-on: none
4. discipline-propagation — the updated canonical skill carried to 23 repos, one PR each — depends-on: intake-agent-economy
5. remi-ai-relocate — `pipeline/` → `.icm/`, `- profile: pipeline`, CI and PR-template paths — depends-on: none
6. remi-ai-stage-collapse — six stages → the template's four — depends-on: remi-ai-relocate, template-stage-set

## Out of scope (whole epic)

- **A `--sync` mode for `icm-check.sh`** — considered and rejected 2026-09-03. D7 stands: repos
  own their copies, drift is a report. Propagation is per-repo PRs.
- **Renumbering remi-ai's five existing run folders** (`anamnesis-structure`, `data-care`,
  `migrate-preview-guard`, `pantry-essentials`, `profile-fields`) — Jamie's call: they move
  as-is and the label derivation keeps reading their historical paths, the way sustentus's
  `project-labels.sh` already maps legacy layouts.
- **Canonicalising sustentus's `route-request.sh`** (the UserPromptSubmit lane classifier) —
  useful, not obviously required now. Revisit when a second pipeline repo asks for it.
- **Shipping `ci-status.sh` into intake-profile repos** — it would mean a new `.icm/scripts/`
  folder in 23 repos to enforce one rule that `gh pr checks --watch` already satisfies (a
  blocking read, wall-clock not model turns). Stub 3 verifies that claim before relying on it.
- **Touching sustentus** — exempt, and it is the source. Nothing here edits it.
- **courseday / pierpont** — unadopted, no `.icm/` at all; already tracked in
  `.icm/intake/triage/courseday-pierpont-unadopted.md`.
- **Retiring the `pipeline-full` profile row in PIPELINE.md** — the front moving into the
  standard profile narrows what is left of it, but whether the row survives is a later call,
  made with evidence.
