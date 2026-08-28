# Stub: Seed the widened baseline across the estate

- feature-slug: seed-estate-baseline
- epic: estate-migration
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 5
- sources: pipeline rework 2026-08-28 · absorbs ICM-010 (intake/_done/ICM-010-seed-canonical-assets.md) and ICM-017's remainder (intake/_done/ICM-017-wire-stop-hook-closure.md)

## Problem

The rework widened the baseline every repo is measured against: `.icm/CONTEXT.md`,
`intake/triage/`, rewritten canonical hooks and skills. Until the seeding pass runs,
every repo reports gaps, and the nine repos wired for the old `wrap-reminder.sh` now
carry a stale copy (drift — correctly reported, deliberately not auto-synced). The old
per-repo decisions ICM-010 carried are still owed: wire the hooks into each repo's
`settings.json`, or leave them inert, decided per repo, never silently.

## Proposed change

Run the `/icm-check` ritual (check → `--fix` → per-repo review → report) across the
estate on Jamie's machine. Batch for his ruling, repo by repo: hook wiring (or inert),
refresh of the stale `wrap-reminder.sh`/`ticket-craft` copies in the nine previously
wired repos, and any deliberate divergences worth registering. Seeded files stay
uncommitted for his review, per the ritual. Standing rule carried from ICM-017: a
dormant repo takes the current hooks in the same commit that drops its dormant marker —
no machinery needed, the drift report is the reminder.

## Acceptance criteria (rough)

- [ ] Every non-exempt repo carries the widened baseline; hooks executable
- [ ] Per repo, Jamie ruled: wire / refresh / leave inert — no silent skips
- [ ] Drift report clean, or every drift line a recorded Jamie decision
- [ ] Seeded files committed per repo by Jamie's call

## Out of scope (this feature)

- Re-cutting any repo's tickets — stubs 2–5 of this epic.
- Overwriting anything — `--fix` seeds what is missing, only.

## Prompt

Seed the 2026-08-28 widened baseline across the Apps estate. Read
.icm/intake/estate-migration/seed-estate-baseline.md, then follow
workspaces/deliver/stages/conformance/CONTEXT.md (the /icm-check ritual): check, --fix,
per-repo review, report. Batch the wire-or-inert and refresh-or-keep rulings for Jamie
repo by repo; the archived tickets .icm/intake/_done/ICM-010-seed-canonical-assets.md
and ICM-017-wire-stop-hook-closure.md carry the per-repo history. Leave seeded files
uncommitted for his review. Client repos live under projects/ on Jamie's machine only.
