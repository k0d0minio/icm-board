# Breakdown: OpenCode executor — unattended parity, the harness closes the loop

- epic-slug: opencode-executor
- sources: parity & shared-config report 2026-09-02
  (`.icm/docs/2026-09-02-opencode-parity-report.md`) · live config read of
  `~/.config/opencode` + `~/.opencode` (v1.18.25) · interrogation 2026-09-02, Jamie's
  rulings: flash stays the driver, escalation stays by hand with no artifact; no
  assignment marker — dispatch stays copy-the-prompt (D3); pin `opencode-auto-resume`;
  harness parity both ways (session-start context + proven wrap); push narrowed to
  auto-allow `claude/*` branches; session-start as a global plugin; **no** proving-run
  stubs — real tickets get fed organically, failures harvested as triage

## What I understood

`opencode-sidecar` made the estate's repos speak OpenCode and `opencode-buildout`
configured the tool itself; what's missing is the last mile that lets an OpenCode
session take a stub's `## Prompt` and carry it to a merged-ready PR without being
babysat. Jamie's call is that power comes from the harness, not from model spend: the
near-free default stays, and this epic instead closes the four capability gaps —
mid-ticket stalls (pin the community auto-resume plugin, reviewed like DCP was),
blind session starts (a hand-rolled global plugin surfacing `.icm/` context, sibling
to notify.js), the push gate blocking unattended runs (narrow `git push*: ask` so
`claude/*` branch pushes auto-allow while main keeps asking — template first, then
per-repo PRs across the estate), and the never-proven wrap ritual (the last stub picks
itself up in OpenCode and wraps itself). Stubs 1–2 are machine work on Jamie's box
(global config is uncommitted); stub 3 is one PR here; stub 4 fans out per-repo PRs
and **must run on the local disk** — `projects/` is invisible to cloud sessions.

## Build order

1. auto-resume-plugin — review + pin `opencode-auto-resume` in the global config — depends-on: none
2. session-start-plugin — hand-rolled `.icm` context surfacing, sibling to notify.js — depends-on: none
3. push-gate-claude-branches — template + this repo: `claude/*` pushes allow, rest ask — depends-on: none
4. push-gate-propagation — the narrowed gate rolled to every estate repo, per-repo PRs — depends-on: push-gate-claude-branches
5. wrap-parity-proof — an OpenCode session picks this stub up and wraps it itself — depends-on: push-gate-claude-branches

## Out of scope (whole epic)

- Proving-ground runs of real open tickets — Jamie's call 2026-09-02: none; he feeds
  OpenCode real tickets organically and failures become triage stubs then.
- Any model-tier change — the committed default stays `vercel/zai/glm-5.3-flash`;
  escalation stays a by-hand gesture with no config or doctrine artifact.
- Assignment machinery (`- runner:` markers, pickup commands) — dispatch stays "copy
  the prompt"; D3 stands.
- Porting /day, /client, /project to native OpenCode commands — still no daily-use
  gap (carried from opencode-buildout).
- Memory plugins / MCP additions / the v2 beta runtime — ICM carries the context;
  stay on v1 stable.
