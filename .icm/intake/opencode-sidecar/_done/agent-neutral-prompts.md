# Stub: Make the stub-prompt contract agent-neutral

- feature-slug: agent-neutral-prompts
- epic: opencode-sidecar
- priority: P2
- size: S
- depends-on: none
- sequence: 3 of 6
- sources: research session 2026-08-29 · grep for "Claude session" across the contract,
  intake micro-copies and both ticket-craft skill copies (the phrase wraps across lines
  in TICKETS.md — grep loosely)

## Problem

The tickets contract specifies that a stub's `## Prompt` "must stand alone when pasted
into a fresh Claude session at the repo root", and the wording repeats in the intake
micro-copies and the ticket-craft skill. With a second harness running stubs, the
contract should name no agent — prompts written under it stay portable to whatever
picks them up.

## Proposed change

Change the wording to "a fresh agent session at the repo root" (or equivalent) in:
`_system/contracts/TICKETS.md` · `.icm/intake/README.md` ·
`_system/template/icm/intake/README.md` · `.claude/skills/ticket-craft/SKILL.md` ·
`_system/template/claude/skills/ticket-craft/SKILL.md`. Keep the repo skill copy and
the template copy identical — conformance reports drift. Leave `.icm/project.md`
(history) and `_system/setup/questionnaire.md` (Claude-specific onboarding by design)
untouched.

## Acceptance criteria (rough)

- [ ] No live contract, micro-copy or skill says stub prompts target Claude specifically
- [ ] Repo and template copies of ticket-craft are byte-identical
- [ ] CI green

## Out of scope (this feature)

- Rewording existing stubs' prompts — the contract governs new cuts; old prompts work
  as they are.

## Prompt

Make the stub-prompt contract agent-neutral. Read
.icm/intake/opencode-sidecar/agent-neutral-prompts.md for the file list. Reword "fresh
Claude session" to "fresh agent session" in the tickets contract, both intake README
micro-copies, and both ticket-craft skill copies (keep repo and template copies
identical); leave history and the setup questionnaire alone. Open a PR on a claude/
branch; do not run local checks — CI is the source of truth.
