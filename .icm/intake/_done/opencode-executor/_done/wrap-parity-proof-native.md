# Stub: Wrap parity proof, natively — the wrap ritual executed by OpenCode itself

- feature-slug: wrap-parity-proof-native
- epic: opencode-executor
- priority: P1
- size: XS
- depends-on: push-gate-claude-branches
- sequence: 6 of 6
- sources: `_done/wrap-parity-proof.md` (same proof, wrapped by Claude Code instead —
  Jamie's call 2026-09-04, so the OpenCode criteria went unmet) · harness-parity ruling
  (Jamie, interrogation 2026-09-02)

## Problem

`wrap-parity-proof` was picked up by a Claude Code session and wrapped from there. The
move, the ticket-only commit and the push to `main` all worked — but that proves the
Claude harness, which was never in doubt. Its first two acceptance criteria name
OpenCode explicitly, and both are still unproven: no OpenCode session has yet loaded
`.claude/skills/` unprompted, and none has closed a wrap end-to-end.

The exposure is unchanged from the original stub. If the wrap doesn't close under
OpenCode, every OpenCode ticket ends half-done and positional status silently breaks —
the board keeps showing finished work as open.

## What is already known (don't re-verify)

Checked on disk 2026-09-04, all green — start from the run, not from an audit:

- `.claude/skills/ticket-craft` and `pr-conventions` present, valid frontmatter.
- Session-start plugin at `~/.config/opencode/plugins/icm-session-start.js`.
  `plugins/` (plural) is fine — the shipped v1.18.25 binary carries the literal
  ``.opencode/plugin/` or `.opencode/plugins/``, so both directory names load.
- `opencode-auto-resume@1.1.12` pinned in the global `plugin` array.
- Epic stubs 1–4 all in `_done/`.

## Proposed change

Pick this stub up **in an OpenCode session** at the icm-board root (`~/Apps`, on
`main`) and let that session wrap it. In order:

1. Skill discovery — the session loads `ticket-craft` (and reads `pr-conventions`)
   through OpenCode's native `.claude/skills/` discovery, unprompted beyond the
   `## Prompt` below.
2. Harness roster — confirm the session-start context actually appeared in the session
   and that auto-resume is live. Note either absence; don't block on it.
3. The wrap itself — `git mv` this stub to the epic's `_done/`, one ticket-only commit,
   push to `main`. The push-to-`main` ask is the deliberate human gate.
4. Board truth — after the push the stub reads done positionally.

Any failure becomes a triage stub against the layer that broke (skill discovery → this
repo; plugin behaviour → the machine config); fix nothing inline beyond a one-line
machine-config correction, the smoke-test discipline.

**If the session running this is not OpenCode, stop and say so** — that is the whole
point of the ticket, and wrapping it from another harness only costs a re-cut.

## Acceptance criteria (rough)

- [ ] ticket-craft loaded by OpenCode via `.claude/skills/` without hand-holding
- [ ] The wrap executed by OpenCode end-to-end: mv → ticket-only commit → approved push
- [ ] Session-start context and auto-resume both observed present in-session, or their
      absence recorded
- [ ] Failures (if any) parked as triage stubs, not patched inline

## Prompt

You are an OpenCode session at the icm-board repo root (`~/Apps`) on Jamie's local
machine. First confirm you really are OpenCode — if you are any other harness, stop and
say so rather than continuing, because this ticket exists to prove OpenCode
specifically.

Read `.icm/intake/opencode-executor/wrap-parity-proof-native.md` — this very stub — and
execute it: verify you can load the estate's ticket-craft skill, then perform the wrap
ritual on this stub itself (`git mv` it to `.icm/intake/opencode-executor/_done/`, make
one ticket-only commit, push to `main` — the push will ask; that approval is Jamie's
gate). Report whether the ICM session-start context appeared at the top of this session
and whether auto-resume is active, and park a triage stub for anything that failed
rather than fixing it inline.
