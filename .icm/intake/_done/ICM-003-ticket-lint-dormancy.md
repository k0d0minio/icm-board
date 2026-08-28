# ICM-003 · Ticket lint + dormancy marker in ticket-hygiene

| | |
|---|---|
| Status | in-progress |
| Type | automation |
| Priority | P2 |
| Size | S |

## Problem

Two signal problems in `_system/scripts/ticket-hygiene.sh`:

1. **It validates none of the contract.** Nothing checks the spec's most load-bearing
   rule — that every ticket has a standalone `## Prompt` (the entire pick-up contract) —
   nor a `Priority` row, a well-formed H1, duplicate/reused numbers across `intake/` +
   `_done/`, or `today` flags older than a day.
2. **Known-good noise drowns real findings.** 15 of the current 17 findings are
   `off-ticket` flags on build-once-hand-off client sites the audit already settled as
   fine ("Done — don't re-litigate"). There is no way to mark a repo dormant.

## Build

- Add the five lint checks above to ticket-hygiene.sh (report-only, as ever — "fixing is
  judgment work, /day applies fixes").
- Add a dormancy marker — recommend an empty `.icm/dormant` file in a repo — that
  silences `off-ticket` findings for that repo (lint checks still run). Document the
  marker in `_system/contracts/TICKETS.md`, and drop it into the settled hand-off repos
  as part of this ticket.

## Acceptance

- [ ] A ticket missing `## Prompt` or `Priority`, a malformed H1, a reused number, and a
      stale `today` flag are each reported
- [ ] Dormant repos produce no off-ticket noise; the marker is documented in TICKETS.md
- [ ] Hygiene output on the current estate is mostly signal (spot-check)

## Prompt

Add ticket lint and a dormancy marker to the Apps estate hygiene script. Read
.icm/intake/ICM-003-ticket-lint-dormancy.md for full context. Extend
_system/scripts/ticket-hygiene.sh (report-only) with the five contract lint checks, honor
an empty .icm/dormant marker file by suppressing off-ticket findings for that repo,
document the marker in _system/contracts/TICKETS.md, and add the marker to the
build-once-hand-off client repos listed as settled in _system/AUDIT.md. Client repos
live in projects/ on this machine only. Estate script + contract changes go through a PR
on a claude/ branch; the dormant markers are per-client-repo commits. Do not run local
checks — CI is the source of truth.

## Remaining

The script + contract half is done (PR on `claude/ticket-lint-dormancy-ylwrak`). The
markers themselves are per-client-repo commits and `projects/` is gitignored and absent
from cloud containers, so they have to be made on Jamie's machine:

```bash
cd ~/Apps
# candidates: a repo with no open tickets, that isn't a control-layer or Gen-1/2/3 repo
for r in berceo kau-american-bbq vinecliff boystomenretreat collabimmo \
         casey-hebbel cafe-jardim messy-play; do
  mkdir -p "projects/$r/.icm" && touch "projects/$r/.icm/dormant"
  git -C "projects/$r" add .icm/dormant
  git -C "projects/$r" commit -m "Mark repo dormant: build-once-hand-off, no board to be off (ICM-003)"
  git -C "projects/$r" push
done
_system/scripts/ticket-hygiene.sh      # spot-check: off-ticket noise should be gone
```

Confirm the list against what's actually in `projects/` first — the audit says "~15
client sites" without naming them, and the list above is the prefix map in
`icm-check.sh` minus the control layer (icm-board, jamienisbet), the Gen-3 pipelines
(sustentus, remi-ai), the Gen-2 workspaces (agorasim, barzinho), the undecided Gen-1
repos (courseday, tenderdesk — audit question 9) and dungeons-dragons (open P1,
DND-015). Then `git mv` this ticket to `_done/`.
