# ICM-013 · Report where deal folders and Neon disagree

| | |
|---|---|
| Status | ready |
| Type | chore |
| Priority | P2 |
| Size | S |

## Problem

Every `DEAL.md` carries a `Ladder` and a `Value` row. `WORKSPACES.md` sanctions this — the
folder mirrors the rung *for legibility* — but a mirror nobody checks is just a second
claim. `workspaces/deals/alix-hahusseau/DEAL.md` says `talking` on the authority of a
sweep run on 2026-08-26, and until [ICM-012](ICM-012-neon-at-the-gate.md) lands there is
nothing that can tell whether that is still true.

Under ICM-012 the folders will usually be right, because the same tick writes both. This
ticket covers the rest: hand edits, failed writes, rows changed in the dashboard, and the
backlog of folders adopted by the ICM-011 sweep that were never confirmed against Neon.

## Build

A seventh script in `_system/scripts/`, in the same read-only shape as the other six:
for every folder in `workspaces/deals/`, compare its `Ladder`, `Value` and `Shape` rows
against the Neon row, and print the disagreements.

**It reports and never repairs** — the house rule for conformance
([CLAUDE.md](../../CLAUDE.md)) and the reason all six existing scripts touch no database
and POST nowhere. Neon wins by definition, so a disagreement is a folder to regenerate,
but the regeneration is a human's call and a separate action.

Also flag a folder with no Neon row at all, and a `talking` row with no folder — both are
real states, and both mean a `/client` run is owed.

Wire into `/day`'s reconcile so it surfaces without being remembered.

## Acceptance

- [ ] Reports rung, value and shape mismatches per deal folder
- [ ] Flags folders with no row, and open rows with no folder
- [ ] Writes nothing — to Neon or to the folders
- [ ] Exits non-zero on drift so `/day` can react, and cleanly when there is none
- [ ] Runs without a token by skipping with a clear message, not by failing the day

## Prompt

Add a read-only drift check between `workspaces/deals/*/DEAL.md` and the Neon client
rows, and surface it in `/day`'s reconcile step.

Read `.icm/intake/ICM-013-deal-folder-drift-check.md`, then `_system/contracts/WORKSPACES.md`
for what the folder mirror is *for*. It depends on the read half of `ICM-012`.

This script reports and never repairs — Neon is authoritative, so drift is a folder to
regenerate, and that is a human's call. Match the shape of the six existing scripts in
`_system/scripts/`.

Open a PR on a `claude/` branch. Do not run local checks — CI is the source of truth.
