# Stub: icm-board's board, hygiene and /day read and write each repo's ticket base branch

- feature-slug: board-scripts-ticket-base
- epic: ticket-base-branch
- priority: P1
- size: M
- depends-on: ticket-base-contract
- sequence: 3 of 4
- sources: breakdown · `_system/scripts/tickets-board.sh` and `ticket-hygiene.sh` (read the
  `projects/` working trees and the checked-out branch's log) · `workspaces/deliver/stages/day/CONTEXT.md`
  step 5 (commits `.icm/` on `main` per repo) · memory: the shared `projects/` tree and its
  `icm update` sweeper

## Problem

`/day` is the estate's main ticket writer and reader, and it does both on whatever `projects/<repo>`
has checked out — `main`. On a UAT repo it shows finished stubs as open, `possibly-done` never
finds the run's merge (it is on `uat`), and step 5 writes to the branch nothing reads any more.

## Proposed change

- `tickets-board.sh` and `ticket-hygiene.sh`: for each repo, resolve the ticket base branch from
  `.icm/project.json` → `uat.branch` (read from `origin/main`), and read intake and log from
  `origin/<base>` with `git ls-tree` / `git show` / `git log origin/<base>` instead of the disk.
  Fall back to the working tree only where the ref is missing, and say so. icm-board itself is read
  as today.
- `/day` step 5: per changed client repo, one ticket PR into its base branch (the shape in
  `pr-conventions`), cut in a throwaway worktree off `origin/<base>` — never on the shared
  checkout — then land it as D37 says. icm-board's own `today.md` and stubs keep the direct commit.
- The day gate is unchanged: Jamie sees each repo's ticket diff before anything is committed.
- `/project`'s push rule follows the same route.

## Acceptance criteria (rough)

- [ ] On berceo (or a fixture with `uat`), a stub `_done` on `origin/uat` and open on `main` is not
      on the board
- [ ] `ticket-hygiene.sh possibly-done` finds a run merged into `uat`
- [ ] A `/day wrap` on a client repo opens a `type:tickets` PR and leaves `projects/<repo>` on
      `main`, clean
- [ ] `self-check.sh` green in CI

## Prompt

In icm-board (`~/Apps`, the local machine — `projects/` is invisible to cloud sessions), carry out
stub 3 of the `ticket-base-branch` epic: read `.icm/intake/ticket-base-branch/breakdown.md` and
`board-scripts-ticket-base.md`, and the D37 entry in `.icm/project.md`. Make
`_system/scripts/tickets-board.sh` and `ticket-hygiene.sh` read each client repo's ticket base
branch from git refs rather than the shared working tree, and rewrite `/day` step 5 so client-repo
ticket changes go out as a `type:tickets` PR from a throwaway worktree, while icm-board keeps its
direct commits. `projects/` is shared with other sessions and a sweeper — never leave a client
checkout off `main`. Never run checks locally; ship as a PR on a `claude/` branch and read CI.
