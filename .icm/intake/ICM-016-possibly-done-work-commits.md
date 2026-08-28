# ICM-016 · Teach possibly-done to tell work from ticket admin

| | |
|---|---|
| Status | ready |
| Type | automation |
| Priority | P2 |
| Size | S |

## Problem

`possibly-done` in `_system/scripts/ticket-hygiene.sh` greps the last 300 commit
subjects for an open ticket's ID and reports a match. Every ticket names itself in its
own birth commit (`Cut ICM-012/013/014 …`), and every audit names the tickets it
touched (`Ticket audit: fold ICM-002 into ICM-001`), so the check fires on the estate's
*good* discipline rather than on drift.

Measured on the estate, 2026-08-28: **17 findings, 17 false positives.** Not one
referencing commit did the work. Meanwhile two tickets whose work genuinely had merged —
`JN-030` (`feat(ui): motion & feedback primitives`, and it was sitting on today's board)
and `JN-035` (`feat(admin): mobile feel pass`) — were indistinguishable from the noise.
A check that cannot separate the two is worse than no check: it trains the reader to
skip the whole section, which is how the board drifted out of sync in the first place.

The distinction is already written down for the human.
[`day/CONTEXT.md`](../../workspaces/deliver/stages/day/CONTEXT.md) § Reconcile says:
"find the actual work commit — the commit that created the ticket doesn't count, nor
does an estate-sweep commit." The script has simply never encoded it.

## Build

- Count a referencing commit as evidence only when it changed something **outside
  `.icm/`**. A commit touching only `.icm/` is ticket administration by definition.
- Report the evidence commit (short SHA + subject) in the finding, so the reconcile step
  in `/day` is a one-line judgment instead of a manual `git log` per ticket.
- Keep the existing 300-commit window and stay report-only — the script never fixes.

Measured effect of the rule: 17 findings → 3, of which `JN-030` and `JN-035` are true
positives and `AGORA-005` is an honest residual (a *rescue* ticket for work stranded in
an unmerged PR, so files moved while the work is genuinely not done). No heuristic
resolves that one; a human must, which is what report-only is for.

## Acceptance

- [ ] A ticket referenced only by `Cut …` / `Ticket audit: …` commits is not reported
- [ ] A ticket whose work merged is reported, naming the commit that did it
- [ ] `ticket-hygiene.sh` remains report-only and its exit codes are unchanged

## Prompt

Sharpen the `possibly-done` check in `_system/scripts/ticket-hygiene.sh` in the icm-board
repo. Today it greps commit subjects for an open ticket's ID, which matches the ticket's
own birth commit and every audit commit — 17 of 17 findings on the estate are false
positives. Change it to count a referencing commit as evidence only if that commit
changed at least one file outside `.icm/`, and include the short SHA and subject of that
commit in the finding text. Keep the 300-commit window, keep the script report-only, and
do not change its exit codes. Update the script's header comment block to describe the
new rule. Estate script changes go through a PR on a `claude/` branch. Do not run local
checks — CI is the source of truth.
