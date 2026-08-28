# Stub: Seed the widened baseline across the estate

- feature-slug: seed-estate-baseline
- epic: estate-migration
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 1
- sources: pipeline rework 2026-08-28 · absorbs ICM-010 and ICM-017's remainder (originals purged, D14 — their per-repo history is summarised below)

## Problem

The rework widened the baseline every repo is measured against: `.icm/CONTEXT.md`,
`intake/triage/`, rewritten canonical hooks and skills. Until the seeding pass runs,
every repo reports gaps. Carried history (the purged tickets' facts): the canonical
assets were never seeded estate-wide; on 2026-08-28 Jamie wired the old
`wrap-reminder.sh` Stop hook into the **nine active repos** — agorasim, barzinho,
berceo, casey-hebbel, dungeons-dragons, jamienisbet, kau-american-bbq, remi-ai,
vinecliff — which now carry a stale copy (drift, correctly reported, deliberately not
auto-synced); the twelve dormant repos were left unwired on purpose. The old per-repo
decision is still owed: wire the hooks into each repo's `settings.json`, or leave them
inert, decided per repo, never silently.

## Proposed change

Run the `/icm-check` ritual (check → `--fix` → per-repo review → report) across the
estate on Jamie's machine. Batch for his ruling, repo by repo: hook wiring (or inert),
refresh of the stale hook/skill copies in the nine previously wired repos, and any
deliberate divergences worth registering. Seeded files stay uncommitted for his review,
per the ritual. Standing rule: a dormant repo takes the current hooks in the same commit
that drops its dormant marker — the drift report is the reminder.

## Acceptance criteria (rough)

- [ ] Every non-exempt repo carries the widened baseline; hooks executable
- [ ] Per repo, Jamie ruled: wire / refresh / leave inert — no silent skips
- [ ] Drift report clean, or every drift line a recorded Jamie decision
- [ ] Seeded files committed per repo by Jamie's call

## Out of scope (this feature)

- Cutting fresh backlogs — a gated /project run, per repo, on demand.
- Overwriting anything — `--fix` seeds what is missing, only.

## Prompt

Seed the 2026-08-28 widened baseline across the Apps estate. Read
.icm/intake/estate-migration/seed-estate-baseline.md for full context (it carries the
per-repo history: which nine repos are wired with the stale hook, which twelve dormant
repos are deliberately unwired), then follow
workspaces/deliver/stages/conformance/CONTEXT.md (the /icm-check ritual): check, --fix,
per-repo review, report. Batch the wire-or-inert and refresh-or-keep rulings for Jamie
repo by repo. Leave seeded files uncommitted for his review. Client repos live under
projects/ on Jamie's machine only.
