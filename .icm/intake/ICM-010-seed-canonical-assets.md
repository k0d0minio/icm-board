# ICM-010 · Seed the canonical Claude assets across the estate

| | |
|---|---|
| Status | ready |
| Type | process |
| Priority | P1 |
| Size | M |
| Depends on | the PR that added `_system/template/claude/` hooks + skills |
| Sources | decision D7, `.icm/project.md` · `_system/template/README.md` |

## Problem

The canonical asset library (session-start + wrap-reminder hooks, ticket-craft +
pr-conventions skills) exists in `_system/template/claude/` and `icm-check.sh` knows how
to seed and drift-check it — but no estate repo carries the assets yet, and the new
script paths have never run against the real estate. Existing repos also have a
`settings.json` that predates the hook wiring, so seeded hooks will be inert until each
repo's settings are updated by hand (never overwritten by the script, by design).

## Acceptance

- [ ] `_system/scripts/icm-check.sh` run on Jamie's machine: report read, then `--fix`
- [ ] Every non-exempt repo carries the four canonical assets; hooks are executable
- [ ] Per repo, Jamie decided: wire the hooks into `settings.json`, or leave inert
      (decision noted in the run summary — no silent skips)
- [ ] Drift report is clean or every drift line is a recorded Jamie decision
- [ ] Seeded files committed per repo by Jamie's call (the script leaves them uncommitted)

> Amended 2026-08-28 (ICM-004 close, Jamie's machine): the **root repo's** share of this
> ticket is now scoped, because #7 made `icm-board` a discovered repo and `icm-check.sh
> --fix` seeded it for the first time. Three files, all byte-identical to
> `_system/template/`, currently **untracked** in the root working tree:
>
> - `.claude/skills/ticket-craft/SKILL.md` and `.claude/skills/pr-conventions/SKILL.md` —
>   passive. Skills are auto-discovered, so these are already live and need no wiring.
> - `.claude/hooks/session-start.sh` — **inert, and the real decision.** `settings.json`
>   points `SessionStart` at `_system/hooks/session-start.sh`, which prints the
>   *estate-wide* board via `tickets-board.sh --today`. The canonical hook prints a
>   *repo's own* board off `.icm/intake/`. Wiring both would print icm-board's own
>   today-tickets twice per session — they overlap rather than compose.
>
> `.claude/hooks/wrap-reminder.sh` is **not** part of this: the root already carries it
> and ICM-017 wired it as a `Stop` hook in #9. So the root needs a ruling on one hook,
> not four assets — this ticket's acceptance box 3, for one repo.
>
> Jamie's call on 2026-08-28 was to leave all three untracked and take them in this
> ticket's per-repo pass rather than ICM-004's. Note for whoever runs it: the estate
> currently reports 23/23 conformant, exit 0 — but only because those three untracked
> files exist. Removing them puts the root back to a gap and the run back to exit 1.

## Prompt

Run the canonical-asset seeding across the estate from the Apps root on Jamie's
machine. Read .icm/intake/ICM-010-seed-canonical-assets.md for context, then follow
workspaces/deliver/stages/conformance/CONTEXT.md (the /icm-check ritual): check, --fix,
review per repo. Batch the wire-the-hooks decisions for Jamie repo by repo. Leave all
seeded files uncommitted for his review, per the ritual.
