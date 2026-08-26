# ICM-004 · Estate housekeeping — stale references and conformance gaps

| | |
|---|---|
| Status | ready |
| Type | chore |
| Priority | P2 |
| Size | S |

## Problem

The audit names the estate's failure mode: "aspirational docs are richer than the running
system." This was `JN-030`. The split itself closed two of its five items — the stale
`TICKETS-SPEC.md` citations in the dashboard, and the retired pointers in
`jamienisbet`'s `.icm/docs/decisions.md`, both fixed in that repo's split commit. What is
left:

1. `_system/template/README.md` cross-references "README.md § Decisions #3" — that section
   moved to `AUDIT.md` on 2026-08-14.
2. `_system/scripts/icm-check.sh` discovers repos with `-mindepth 2`, so **this** repo —
   the one holding the baseline — is exempt from its own conformance check. Include the
   root. The same blind spot applies to `tickets-board.sh` and `pull-all.sh`, which handle
   the root as a special case rather than a discovered repo.
3. `projects/the-library` has no `.icm`/`.claude` baseline — one `icm-check.sh --fix` away;
   run it and confirm the suggested prefix.

Note that `_system/contracts/` is now the canonical home of the specs; anything still
citing `_system/TICKETS-SPEC.md` is stale by definition.

## Acceptance

- [ ] Zero references to retired paths/commands remain (grep for `TICKETS-SPEC`,
      `icm-template`, `/onboard`, `PROCESS.md`)
- [ ] `icm-check.sh` checks this repo too
- [ ] `the-library` passes `icm-check.sh`
- [ ] CI green

## Prompt

Do the estate housekeeping pass in the `icm-board` repo. Read
`.icm/intake/ICM-004-estate-housekeeping.md` for the itemized list: fix the retired pointer
in `_system/template/README.md`, make `_system/scripts/icm-check.sh` include the root repo
in its own conformance check, and seed `projects/the-library` with `icm-check.sh --fix`
(that client repo exists on this machine only). Script changes go through a PR on a
`claude/` branch; do not run local checks — CI is the source of truth.
