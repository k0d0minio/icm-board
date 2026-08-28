# Stub: Report where deal folders and Neon disagree

- feature-slug: deal-folder-drift-check
- epic: business-state
- priority: P2
- size: S
- depends-on: neon-at-the-gate
- sequence: 2 of 3
- sources: recut from ICM-013 (original purged, D14)

## Problem

Every `DEAL.md` carries `Ladder` and `Value` rows as a sanctioned mirror of Neon — but a
mirror nobody checks is just a second claim. Once `neon-at-the-gate` lands the folders
will usually be right; this covers the rest: hand edits, failed writes, dashboard-side
changes, and the ICM-011 sweep's never-confirmed backlog.

## Proposed change

A read-only script in `_system/scripts/`, house shape: for every folder in
`workspaces/deals/`, compare `Ladder`/`Value`/`Shape` against the Neon row and print
disagreements. Also flag a folder with no Neon row, and a `talking` row with no folder.
Reports and never repairs — Neon wins by definition; regeneration is a human's call.
Wire into `/day`'s reconcile step.

## Acceptance criteria (rough)

- [ ] Reports rung, value and shape mismatches per deal folder
- [ ] Flags folders with no row, and open rows with no folder
- [ ] Writes nothing — to Neon or to the folders
- [ ] Exits non-zero on drift, cleanly when none; skips with a clear message when no token
- [ ] Surfaced by `/day` reconcile without being remembered

## Out of scope (this feature)

- Regenerating folders — a separate, human-initiated act.

## Prompt

Add a read-only drift check between workspaces/deals/*/DEAL.md and the Neon client
rows, and surface it in /day's reconcile step. Read
.icm/intake/business-state/deal-folder-drift-check.md, then
_system/contracts/WORKSPACES.md for what the folder mirror is for. It depends on the
read half of neon-at-the-gate. Match the shape of the existing scripts in
_system/scripts/. Open a PR on a claude/ branch; do not run local checks — CI is the
source of truth.
