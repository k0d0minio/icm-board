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

## Prompt

Run the canonical-asset seeding across the estate from the Apps root on Jamie's
machine. Read .icm/intake/ICM-010-seed-canonical-assets.md for context, then follow
workspaces/deliver/stages/conformance/CONTEXT.md (the /icm-check ritual): check, --fix,
review per repo. Batch the wire-the-hooks decisions for Jamie repo by repo. Leave all
seeded files uncommitted for his review, per the ritual.
