# Stub: Narrow the push gate — claude/* branches allow, everything else asks

- feature-slug: push-gate-claude-branches
- epic: opencode-executor
- priority: P1
- size: S
- depends-on: none
- sequence: 3 of 5
- sources: Jamie's ruling, interrogation 2026-09-02 ("allow push on claude/
  branches") · rails proof: `_done/opencode-buildout/_done/rails-smoke-test.md`
  check 3 (last-match-wins confirmed live)

## Problem

The estate rails say `"git push*": "ask"` — so even with auto-resume installed, every
unattended OpenCode run blocks at the push, including pushes to `claude/*` branches
whose real gate is the PR merge on GitHub. The ask is doing gate work the PR review
already does, at the cost of babysitting every run.

## Proposed change

In `_system/template/root/opencode.json` **and this repo's own root `opencode.json`**:

- After the existing `"git push*": "ask"` line, add
  `"git push* claude/*": "allow"` — OpenCode bash permissions are last-match-wins
  over whole-command globs (proven live in the rails smoke test), so the allow must
  sit after the ask to win for `claude/*` pushes while everything else still asks.
- Pushes to `main` keep asking — ticket-only commits go straight to `main` in this
  estate, and that push staying human-approved is the deliberate gate.
- Caveat to verify and document in a comment: a **bare** `git push` (upstream already
  set) names no branch and still hits the ask — correct behaviour; prompts and PR
  conventions already push with the branch named. Verify the glob matches the real
  forms (`git push -u origin claude/foo`, `git push origin claude/foo`) in a live
  session the way the smoke test did, using `--dry-run` so a surprise approval stays
  harmless.

One PR here on a `claude/` branch; CI green. Expect the estate conformance drift
report to light up for every un-propagated repo afterwards — that is the report doing
its job; the next stub (`push-gate-propagation`) clears it. Drift is reported, never
auto-synced.

## Acceptance criteria (rough)

- [ ] Template + icm-board root opencode.json carry the narrowed gate, comment explaining order
- [ ] Live `--dry-run` check: `claude/*` push allowed, `main` push asks
- [ ] PR merged, CI green

## Prompt

Work in the icm-board repo (`~/Apps`). Read
`.icm/intake/opencode-executor/push-gate-claude-branches.md` for full context. In
`_system/template/root/opencode.json` and the repo root `opencode.json`, narrow the
push gate: keep `"git push*": "ask"` and add `"git push* claude/*": "allow"` after it
(last-match-wins), with a short comment on the ordering and the bare-`git push`
caveat. Verify the rules in a live OpenCode session with `git push --dry-run` before
opening the PR. Open a PR on a `claude/` branch; do not run local checks — CI is the
source of truth.
