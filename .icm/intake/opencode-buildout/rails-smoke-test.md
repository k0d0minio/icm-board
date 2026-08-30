# Stub: Smoke test — the rails hold in a real estate repo

- feature-slug: rails-smoke-test
- epic: opencode-buildout
- priority: P1
- size: XS
- depends-on: global-core-config, template-opencode-rails
- sequence: 5 of 5
- sources: report artifact §Phase 5 + §What happens next
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

Every rail so far is config on paper. Nothing has proven that an OpenCode session
inside an estate repo actually refuses local checks, prompts on push, loads the
right rules, and stays quiet on formatting.

## Change

In one non-client repo (jamienisbet is the natural pick), run `opencode` and
check, in order:

1. Layer 0 loaded — the agent knows the repo's AGENTS.md identity when asked.
2. `npm test` (or equivalent) → denied by the permission chain.
3. `git push` → prompts (ask), not silent.
4. An edit to any file → no formatter rewrites it.
5. `/share` → disabled.
6. `.env` read → denied (OpenCode default).

Record any failure as a triage stub against whichever layer broke (template →
here; global config → fix in place). Done when all six pass; move this stub to
`_done/` in a ticket-only commit.

## Prompt

Read `.icm/intake/opencode-buildout/rails-smoke-test.md` in this repo and run the
six checks it lists inside an OpenCode session in projects/jamienisbet. Report
pass/fail per check; cut triage stubs for failures rather than fixing inline
unless the fix is a one-line config correction on Jamie's machine.
