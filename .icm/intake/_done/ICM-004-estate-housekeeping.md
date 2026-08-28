# ICM-004 · Estate housekeeping — stale references and conformance gaps

| | |
|---|---|
| Status | ready |
| Type | chore |
| Priority | P2 |
| Size | S |

> Amended 2026-08-27 (estate ticket audit): the stale "README.md § Decisions #3" pointer
> in `_system/template/README.md` is already fixed — a grep for `TICKETS-SPEC` /
> `icm-template` / `/onboard` / `PROCESS.md` finds nothing left outside historical notes
> in `AUDIT.md`. Two items remain.

> Amended 2026-08-27 (cloud session): **item 1 is done** — `icm-check.sh` now prepends
> the root repo to its discovery list, the same way `pull-all.sh` and `tickets-board.sh`
> already do. **Item 2 stays open and can only close on Jamie's machine**: `projects/` is
> gitignored and simply absent in a cloud container, so `projects/the-library` cannot be
> seeded from a session like this one.
>
> Widening the check has a consequence worth knowing before the next `/icm-check`:
> `icm-board` itself now reports as a gap. It carries none of the four canonical
> `.claude/` assets, and its session-start hook lives at `_system/hooks/session-start.sh`
> — the estate-wide board — rather than `.claude/hooks/session-start.sh`, which prints a
> repo's own board. That is a deliberate divergence to rule on, not rot, and it is
> ICM-010's per-repo call now that the root is one of the repos.

## Problem

The audit names the estate's failure mode: "aspirational docs are richer than the running
system." This was `JN-030`. The split itself closed two of its five items — the stale
`TICKETS-SPEC.md` citations in the dashboard, and the retired pointers in
`jamienisbet`'s `.icm/docs/decisions.md`, both fixed in that repo's split commit. What is
left:

1. `_system/scripts/icm-check.sh` discovers repos with `-mindepth 2`, so **this** repo —
   the one holding the baseline — is exempt from its own conformance check. Include the
   root. The same blind spot applies to `tickets-board.sh` and `pull-all.sh`, which handle
   the root as a special case rather than a discovered repo.
2. `projects/the-library` has no `.icm`/`.claude` baseline — one `icm-check.sh --fix` away;
   run it and confirm the suggested prefix.

## Acceptance

- [x] `icm-check.sh` checks this repo too
- [ ] `the-library` passes `icm-check.sh`
- [ ] CI green

## Prompt

Do the estate housekeeping pass in the `icm-board` repo. Read
`.icm/intake/ICM-004-estate-housekeeping.md` for the itemized list: make
`_system/scripts/icm-check.sh` include the root repo
in its own conformance check, and seed `projects/the-library` with `icm-check.sh --fix`
(that client repo exists on this machine only). Script changes go through a PR on a
`claude/` branch; do not run local checks — CI is the source of truth.
