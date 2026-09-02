# Stub: Session-start plugin — OpenCode sessions stop starting blind

- feature-slug: session-start-plugin
- epic: opencode-executor
- priority: P1
- size: M
- depends-on: none
- sequence: 2 of 5
- sources: harness-parity ruling (Jamie, interrogation 2026-09-02: global plugin, not
  per-repo instructions) · Claude counterpart:
  `_system/template/claude/hooks/session-start.sh` · pattern precedent:
  `~/.config/opencode/plugins/notify.js`

## Problem

A Claude session in any estate repo gets SessionStart context — ICM detection, board
state, today's picks. An OpenCode session starts blind: it discovers `.icm/` only if
the prompt tells it to look. For a ticket executor that difference is real capability
lost — the Claude harness knows where the work lives before the first tool call.

## Proposed change

A hand-rolled global plugin in `~/.config/opencode/plugins/` (sibling to `notify.js`),
machine work only — nothing committed except this stub's move.

- On session start in a project whose tree carries `.icm/`, surface the same context
  the Claude hook prints: ICM detected, intake/contract pointers, and — when the
  project is the icm-board — today's picks from `.icm/today.md` and open counts.
  Prefer shelling out to the existing hook script (the shared-scripts pattern the
  report recommends) over reimplementing its logic in JS.
- **Verify the injection mechanism against the shipped runtime, not the SDK types** —
  notify.js documents that the bundled `@opencode-ai/sdk` types are stale (they
  declare events the runtime never emits and omit ones it does). Find what a v1.18.x
  plugin can actually contribute as session context and use that; if the runtime
  offers no clean injection point, degrade to the least-bad honest option and record
  the limitation in the plugin header.
- Read-only by design: the plugin reads `.icm/` and today.md, never writes, never
  prompts the model to act, never advances anything — context surfacing is not
  orchestration.
- Non-ICM projects must be completely unaffected, and failures must degrade silently
  (the `.nothrow().quiet()` discipline notify.js uses).

## Acceptance criteria (rough)

- [ ] OpenCode session in an `.icm/` repo shows intake/board context at start
- [ ] Session in a non-ICM directory is untouched; no errors in either case
- [ ] Plugin header documents the runtime-verified mechanism, like notify.js does
- [ ] No writes, no injected instructions to act — context only

## Prompt

Run this on Jamie's machine only (it creates a file in the uncommitted
`~/.config/opencode/plugins/`). Read
`.icm/intake/opencode-executor/session-start-plugin.md` in the icm-board repo
(`~/Apps`) for full context, plus `~/.config/opencode/plugins/notify.js` for the house
plugin pattern and `_system/template/claude/hooks/session-start.sh` for what the
Claude harness surfaces. Write a global OpenCode plugin that, at session start in a
repo carrying `.icm/`, surfaces that repo's intake context (and the estate board state
when the repo is icm-board), verifying the injection mechanism against the running
v1.18.x binary rather than the stale SDK types. Read-only, silent on failure,
inert outside ICM repos. Nothing is committed except moving this stub to the epic's
`_done/` in a ticket-only commit.
