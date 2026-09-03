# Stub: Give intake repos the agent-economy rules they can actually act on

- feature-slug: intake-agent-economy
- epic: sustentus-parity
- priority: P0
- size: M
- depends-on: none
- sequence: 3 of 6
- sources: breakdown (`.icm/intake/sustentus-parity/breakdown.md`) · estate inventory 2026-09-03
  (23 of 26 repos under `projects/` are `- profile: intake`; all 23 plus icm-board carry
  `pr-conventions/SKILL.md` byte-identical to the template) ·
  `_system/template/claude/skills/pr-conventions/SKILL.md` · `_system/README.md` § House doctrine

## Problem

The discipline in stub 2 lands in `_shared/`, which only pipeline-profile repos receive. That is
one repo today (sustentus, exempt) and one more after stub 6 (remi-ai). The other 23 are
`- profile: intake`: they get `pr-conventions` and `ticket-craft` and nothing else.

These are the repos where the noise is worst. Every one deploys on Vercel, so every push produces
a deploy-status burst and a bot comment table that is edited repeatedly — and a session subscribed
to that PR wakes for each one. `pr-conventions/SKILL.md` currently says only:

> **CI is the source of truth. Never run `build`/`lint`/`typecheck`/`test` locally** — push and
> read the checks. A red check is the task; a green check is the proof.

That tells a session to read the checks. It does not say how, does not say that zero checks on a
fresh push is PENDING rather than green, does not say that a subscription will wake it a dozen
times per push, and does not tell it what to do when a harness subscribes on its behalf. Every
correction Jamie makes about PR noise in a small repo is a correction the reference file should
have made — the House doctrine's own "edit the source, not just the output".

## Proposed change

Add an agent-economy section to the canonical
`_system/template/claude/skills/pr-conventions/SKILL.md`, written for a repo with **no**
`.icm/scripts/` and no runs:

- Never subscribe to PR activity. If the harness subscribed for you — some auto-subscribe after
  opening a PR — unsubscribe immediately and say so. A harness default does not override the
  repo's rule about its own PRs.
- Read state instead of being told about it: **one blocking read per push**
  (`gh pr checks --watch`), whose waiting costs wall-clock rather than model turns. Never a
  sleep-and-re-read loop; never a bare glance at an unsettled run.
- PENDING is a third value, not a soft green. Zero checks on a freshly pushed commit is PENDING —
  it takes GitHub seconds to register a workflow.
- Never act on a deploy-provider event or the deploy bot's comment-table edits; they carry no
  verdict.
- Your own pushes come back as events. The stream echoes what you just did; that is not a new
  instruction.
- Anything longer-running is a **scheduled check-in** — one timed wake that reads once and
  re-arms — never a subscription. Watching a PR is a deliberate, human-requested act only.
- Narrow reads: one call per question, small page sizes, never page through diffs or comment
  threads you don't need.

Point at `_shared/github.md` and `ci.md` for pipeline-profile repos rather than restating them —
each rule lives once.

Add one House doctrine line in `_system/README.md` (it sits naturally beside "CI is the source of
truth"), and update **icm-board's own** `.claude/skills/pr-conventions/SKILL.md` in the same PR —
this repo is held to its own baseline.

**Verify before recommending:** confirm `gh pr checks` reports commit statuses (where Vercel
deploys land) and not only Actions check runs. If it misses a surface, the skill must say which,
rather than implying a complete verdict — that misreading is exactly what `ci-status.sh` exists
to prevent in the pipeline repos.

## Acceptance criteria (rough)

- [ ] `gh pr checks` surface coverage established by testing it against a real PR, and the skill's
      wording matches what was found
- [ ] Every rule is actionable in a repo with no scripts and no runs
- [ ] The skill points at `_shared/` for pipeline repos rather than duplicating stub 2's text
- [ ] `_system/README.md` § House doctrine gains one line on PR-event economy
- [ ] icm-board's own copy updated in the same PR; template and icm-board copies byte-identical
      afterwards
- [ ] `_system/scripts/icm-check.sh` reports the 23 client copies as drift afterwards — expected,
      and the input to stub 4

## Prompt

Give the estate's intake-profile repos the agent-economy rules, in the icm-board repo (`~/Apps`).
Read `.icm/intake/sustentus-parity/intake-agent-economy.md` and the epic's `breakdown.md` for full
context, plus `projects/sustentus/.icm/_shared/github.md` and `ci.md` for the source doctrine. Add
an agent-economy section to `_system/template/claude/skills/pr-conventions/SKILL.md` covering: no
PR subscriptions (and unsubscribe when a harness did it for you), one blocking read per push via
`gh pr checks --watch`, PENDING is not green, never act on deploy events or bot comment edits,
your own pushes echo back, long waits are scheduled check-ins, and narrow GitHub reads. Write it
for a repo with no `.icm/scripts/`. First verify whether `gh pr checks` reports commit statuses as
well as check runs, and word the skill to match what you find. Add one House doctrine line in
`_system/README.md`, and update icm-board's own `.claude/skills/pr-conventions/SKILL.md` to match
the template in the same PR. Open a PR on a `claude/` branch; do not run local checks — CI is the
source of truth. Move this stub to the epic's `_done/` in that PR.
