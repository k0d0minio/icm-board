# Stub: Wrap parity proof — OpenCode picks this stub up and wraps it itself

> Wrapped by Claude Code, not OpenCode (2026-09-04, Jamie's call). The harness roster
> was verified on disk — ticket-craft + pr-conventions present, session-start plugin
> loaded, auto-resume pinned — but criteria 1 and 2 name OpenCode and a Claude Code
> session cannot satisfy them. The native proof is re-cut as
> `opencode-executor/wrap-parity-proof-native`.

- feature-slug: wrap-parity-proof
- epic: opencode-executor
- priority: P1
- size: XS
- depends-on: push-gate-claude-branches
- sequence: 5 of 5
- sources: harness-parity ruling (Jamie, interrogation 2026-09-02) · precedent:
  `_done/opencode-buildout/_done/rails-smoke-test.md` (prove-in-place, harvest
  failures as triage)

## Problem

The wrap ritual — skill discovery via `.claude/skills/`, `git mv` the stub to
`_done/`, ticket-only commit straight to `main` — has never been executed under
OpenCode. If the wrap doesn't close, every OpenCode ticket ends half-done and the
positional-status model silently breaks: the board keeps showing done work as open.

## Proposed change

This stub is its own proving ground: **pick it up in an OpenCode session** at the
icm-board root on Jamie's machine and let the session wrap it. In order:

1. Skill discovery — the session loads `ticket-craft` (and reads `pr-conventions`)
   through OpenCode's native `.claude/skills/` discovery, unprompted beyond the
   `## Prompt` below.
2. Harness roster — confirm the session-start context appeared (stub 2's plugin, if
   done by then) and `opencode-auto-resume` is active (stub 1); note either absence,
   don't block on it.
3. The wrap itself — `git mv` this stub to the epic's `_done/`, one ticket-only
   commit, push to `main`. The push-to-`main` ask is the deliberate human gate:
   Jamie approves it from the notification.
4. Board truth — after the push, the stub reads done positionally (file in `_done/`,
   board reads `main`).

Any failure becomes a triage stub against the layer that broke (skill discovery →
this repo; plugin behaviour → the machine config); fix nothing inline beyond a
one-line machine-config correction, the smoke-test discipline.

## Acceptance criteria (rough)

- [ ] ticket-craft loaded by OpenCode via `.claude/skills/` without hand-holding
- [ ] The wrap executed by OpenCode end-to-end: mv → ticket-only commit → approved push
- [ ] Failures (if any) parked as triage stubs, not patched inline

## Prompt

You are an OpenCode session at the icm-board repo root (`~/Apps`) on Jamie's local
machine. Read `.icm/intake/opencode-executor/wrap-parity-proof.md` — this very stub —
and execute it: verify you can load the estate's ticket-craft skill, then perform the
wrap ritual on this stub itself (move it to
`.icm/intake/opencode-executor/_done/`, make one ticket-only commit, push to main
— the push will ask; that approval is Jamie's gate). Report which harness pieces
were present (session-start context, auto-resume) and park a triage stub for anything
that failed rather than fixing it inline.
