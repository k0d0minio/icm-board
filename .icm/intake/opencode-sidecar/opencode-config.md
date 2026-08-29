# Stub: Commit repo-side opencode.json carrying the estate rails

- feature-slug: opencode-config
- epic: opencode-sidecar
- priority: P1
- size: S
- depends-on: none
- sequence: 2 of 6
- sources: research session 2026-08-29 — OpenCode reads AGENTS.md/CLAUDE.md and
  `.claude/skills/` natively; permissions are allow/ask/deny per tool with bash-pattern
  granularity (opencode.ai/docs)

## Problem

An OpenCode session in this repo inherits none of the rails Claude Code gets from
`.claude/settings.json` and the hooks: nothing stops it running local checks (forbidden
— CI is the source of truth) or acting outside the repo. The instructions say so, but a
cheaper model under a second harness deserves enforcement, not just prose.

## Proposed change

Commit a root `opencode.json` with a permission block: deny the local-check command
patterns (`build`, `lint`, `typecheck`, `test`, `tsc`, `next build`, `dev`, `format`),
ask on `git push`, allow the rest — gentle, mirroring the estate's hook philosophy;
the instruction files stay the real contract. Verify against current OpenCode docs
which config filename/schema is live before writing. Once Jamie has installed OpenCode,
confirm in a live session that it picks up AGENTS.md (or CLAUDE.md fallback) and the
`.claude/skills/` copies of pr-conventions and ticket-craft — note what it loaded in
the PR description.

## Acceptance criteria (rough)

- [ ] `opencode.json` at the root, valid against the current schema, deny rules present
- [ ] Inert for every other tool (no filename collisions, nothing loads it but OpenCode)
- [ ] Live-session pickup of instructions + skills confirmed (waits on Jamie's install)
- [ ] CI green

## Out of scope (this feature)

- Provider, auth, and model configuration — Jamie's own machine-level setup
  (`~/.config/opencode/`), by his own word.
- Porting the `.claude/commands/` (the four routing commands stay Claude-side; the
  second harness only ever runs stub prompts).

## Prompt

Commit a repo-side opencode.json for this repo. Read
.icm/intake/opencode-sidecar/opencode-config.md for full context. Check the current
OpenCode docs for the live config schema, write a permission block denying local-check
command patterns and asking on git push, and keep it minimal — instructions stay the
contract. If OpenCode is installed on this machine, verify instruction/skill pickup in
a live session and record what loaded in the PR description. Open a PR on a claude/
branch; do not run local checks — CI is the source of truth.
