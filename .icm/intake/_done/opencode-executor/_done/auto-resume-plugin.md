# Stub: Pin opencode-auto-resume — kill the mid-ticket stall

- feature-slug: auto-resume-plugin
- epic: opencode-executor
- priority: P1
- size: S
- depends-on: none
- sequence: 1 of 5
- sources: parity report §2h + §4 (`.icm/docs/2026-09-02-opencode-parity-report.md`) ·
  Jamie's adoption call, interrogation 2026-09-02

## Problem

OpenCode halts mid-ticket for documented reasons — output-token cap
(`finish_reason: "length"`), stops after compaction, idle-with-open-todos, dead
subagents — and nothing recovers: the global `notify.js` plugin only *alerts* on
`session.idle`/`permission.asked`. Until a stall auto-recovers, OpenCode cannot run a
stub end-to-end unattended. The report names `opencode-auto-resume` (Mte90) as the
highest-impact single fix.

## Proposed change

Machine work on Jamie's box — the global config is uncommitted; nothing lands in git
except this stub's move.

1. Fetch the current release of `opencode-auto-resume` and **review the source** at
   that exact version — plugins execute at startup with access to
   `~/.local/share/opencode/auth.json`, so the trust bar is the DCP review
   (2026-08-30): read what it does, note anything that phones home or touches auth.
2. Add it to the `plugin` array in `~/.config/opencode/opencode.json` **pinned to the
   exact version reviewed** (the DCP entry `@tarquinen/opencode-dcp@3.1.15` is the
   pattern; never `@latest`).
3. Update the comment block above `plugin` recording the adoption (Jamie,
   2026-09-02). The standing "one-in-one-out" line means *considered deliberately,
   pinned from the start* — Jamie approved this addition knowing the roster; DCP and
   notify.js both stay.
4. Observe one live session recover from a stall (an output-length stop or an
   idle-with-open-todos is enough). If the plugin misbehaves, remove it and park a
   triage stub with the evidence instead of debugging inline.

## Acceptance criteria (rough)

- [ ] Source reviewed at the pinned version; a line or two of notes in the config comment
- [ ] `plugin` array carries the exact-version pin; opencode starts clean with it
- [ ] One observed stall auto-recovered in a live session

## Prompt

Run this on Jamie's machine only (it edits the uncommitted `~/.config/opencode/`).
Read `.icm/intake/opencode-executor/auto-resume-plugin.md` in the icm-board repo
(`~/Apps`) for full context. Review the source of the `opencode-auto-resume` plugin at
its current release, then add it to the `plugin` array in
`~/.config/opencode/opencode.json` pinned to that exact version, updating the comment
block to record the adoption (Jamie, 2026-09-02) and your review notes. Do not touch
the model, mcp, or permission blocks. Verify opencode starts cleanly and, if
practical, that a stalled session auto-resumes. Nothing is committed except moving
this stub to the epic's `_done/` in a ticket-only commit.
