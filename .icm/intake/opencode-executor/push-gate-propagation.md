# Stub: Propagate the narrowed push gate across the estate

- feature-slug: push-gate-propagation
- epic: opencode-executor
- priority: P1
- size: M
- depends-on: push-gate-claude-branches
- sequence: 4 of 5
- sources: repo survey 2026-09-02 — all 24 `projects/*` repos carry the rails
  `opencode.json` (sustentus included) · precedent: opencode-sidecar's
  estate-rollout + the opencode-rails-propagation triage stub (PR #22)

## Problem

Once the template narrows the push gate, every estate repo's `opencode.json` drifts
from canonical and unattended OpenCode runs still block at push everywhere except
icm-board. Conformance reports the drift but never repairs it — closing it is a
deliberate per-repo pass.

## Proposed change

**Local disk only** — `projects/` repos are gitignored here and exist only on Jamie's
machine; a cloud session cannot see them.

For each `projects/*` repo carrying the rails `opencode.json` (all 24 as of
2026-09-02, sustentus included — its `.icm/` exemption is about the ticket baseline,
not the rails file it accepted in the sustentus-opencode stub):

- Apply the same edit as the template: keep `"git push*": "ask"`, add
  `"git push* claude/*": "allow"` after it. Preserve any repo-local additions —
  the repo's copy wins on everything else; this is a targeted edit, not a re-seed.
- One PR per repo on a `claude/` branch, CI green each, per the estate PR
  conventions. Do not run local checks anywhere.
- Repos whose file has diverged in ways that make the edit non-obvious get a triage
  stub in their own repo rather than an improvised merge.

Done when the estate conformance drift report is clean again for `opencode.json`.

## Acceptance criteria (rough)

- [ ] Every rails-carrying repo has the narrowed gate; repo-local additions untouched
- [ ] Per-repo PRs merged, CI green each
- [ ] `estate-conformance` / `icm-check` drift for opencode.json back to clean

## Prompt

Run this on Jamie's machine only — the `projects/*` repos live solely on his local
disk. Read `.icm/intake/opencode-executor/push-gate-propagation.md` in the icm-board
repo (`~/Apps`) for full context, and the already-merged template change in
`_system/template/root/opencode.json` for the exact lines. In every `projects/*` repo
carrying the rails `opencode.json`, apply the same narrowed push gate (`claude/*`
pushes allow, everything else asks), preserving repo-local config. One PR per repo on
a `claude/` branch; do not run local checks — CI is the source of truth. Park a triage
stub in any repo whose file has diverged too far to edit mechanically. Finish by
confirming the estate drift report is clean and moving this stub to the epic's
`_done/` in a ticket-only commit.
