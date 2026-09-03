# Stub: Port the PR-event and CI-verdict discipline into the template's shared contracts

- feature-slug: shared-pr-noise-contract
- epic: sustentus-parity
- priority: P0
- size: M
- depends-on: none
- sequence: 2 of 6
- sources: breakdown (`.icm/intake/sustentus-parity/breakdown.md`) · `projects/sustentus/.icm/_shared/github.md`
  (198 lines, § "PR events — no PR in this repository is subscribed") and `ci.md` (135 lines,
  § "One blocking call — never a model-driven poll", § "Webhook events — pipeline sessions don't
  listen at all") · `_system/template/icm-pipeline/_shared/{github,ci}.md` (62 and 34 lines)

## Problem

The rules that keep a session cheap live in sustentus and nowhere else. The template compresses
the whole of them into one bullet — "**Never subscribe to PR activity.** One push produces a
pile of events and none of them is a verdict." — which states the rule and gives a session no way
to comply with it.

Missing from the template:

- **The unsubscribe instruction and the harness override.** A harness may auto-subscribe after
  `create_pull_request`, and some instruct the agent to watch every PR it opens. The source says:
  call `unsubscribe_pr_activity` immediately and say so — a harness default does not override the
  repository's own rule about its own PRs. Without this, the template's bullet is advice a
  harness silently overrules.
- **The scale of the cost, measured.** A dozen-plus events per push; each wakes the session,
  costs a full turn, and re-sends the whole deploy comment table. PR #948 (2026-09-02): a dozen
  wake-ups, every one "nothing red, no action".
- **The blocking-call rule and why re-running it is not polling.** "Check once, no polling" was
  read as "one glance is enough", and one glance at an unsettled run is worth nothing. The rule
  is **one settled verdict per push**, obtained by the one blocking call whose waiting costs
  wall-clock, not model turns.
- **The scheduled check-in.** Anything longer-running is one timed wake that reads state once and
  re-arms — same coverage, a fraction of the turns — never a subscription.
- **The four stray-event rules**, for when an event arrives anyway: never act on a deploy-provider
  event or the deploy bot's comment edits; one response per settled run, not one per event; an
  advisory job never warrants a push on its own; your own pushes echo back as events and are not
  new instructions.
- **Read-narrowness.** One call per question, the one `method` you need, small `perPage`; never
  page through comment threads or diffs you don't need.

## Proposed change

Port all of it into `_system/template/icm-pipeline/_shared/github.md` and `ci.md`, repo-neutral
(no `sustentus/sustentus`, no "eight Vercel projects" → "each deploy target", no `Quality
Project` check name). Keep the measured example as provenance rather than deleting it — attribute
it as a measurement from the estate's largest repo with its date, so the rule reads as something
paid for rather than a preference.

Both files stay Layer-3 references. No new script, no orchestration; the discipline is prose the
stage contracts already point at.

## Acceptance criteria (rough)

- [ ] `_shared/github.md` carries a PR-events section with the explicit unsubscribe instruction
      and the statement that a harness default does not override it
- [ ] `_shared/ci.md` carries "one blocking call, never a model-driven poll", the
      one-settled-verdict-per-push rule, the PENDING-is-not-green argument, and the four
      stray-event rules
- [ ] The scheduled-check-in alternative is stated in both files, and "watching a PR is a
      deliberate, human-requested act" survives verbatim in spirit
- [ ] Read-narrowness rule present (one narrow call per question, small page sizes)
- [ ] No sustentus identity anywhere; the measured example is attributed, not invented
- [ ] Nothing here duplicates stub 3's `pr-conventions` wording by accident — this is the
      pipeline-profile reference, that is the every-repo skill; each says it once and the skill
      points here

## Prompt

Port sustentus's PR-event and CI-verdict discipline into the estate template's shared contracts,
in the icm-board repo (`~/Apps`). Read `.icm/intake/sustentus-parity/shared-pr-noise-contract.md`
and the epic's `breakdown.md` for full context. Read
`projects/sustentus/.icm/_shared/github.md` (§ "PR events") and `projects/sustentus/.icm/_shared/ci.md`
(§ "One blocking call" and § "Webhook events") on this machine, then rewrite
`_system/template/icm-pipeline/_shared/github.md` and `ci.md` to carry the same rules in full,
generalised — no repo literal, no named deploy-target counts, no repo-specific check names. Keep
the measured cost example, attributed with its date. Add no script and no orchestration: these
are Layer-3 reference files. Do not touch sustentus. Open a PR on a `claude/` branch; do not run
local checks — CI is the source of truth. Move this stub to the epic's `_done/` in that PR.
