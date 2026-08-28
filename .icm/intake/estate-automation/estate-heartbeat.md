# Stub: Estate heartbeat — daily timer, digest, session-start delta

- feature-slug: estate-heartbeat
- epic: estate-automation
- priority: P1
- size: M
- depends-on: conformance-exit-code
- sequence: 2 of 2
- sources: recut from ICM-001 (intake/_done/ICM-001-estate-heartbeat.md; ICM-002's /day run log folded in 2026-08-27) · audit open decision #8

## Problem

Zero scheduled automation exists estate-wide. The estate scripts walk the gitignored
`projects/` on disk, so any routine must run on Jamie's machine — cloud sessions see
half the estate. The one automatic surface, the SessionStart hook, prints only the Today
picks: a morning with an empty today.md, 3 blocked stubs and 17 hygiene findings reports
"nothing to do".

## Proposed change

1. `_system/scripts/heartbeat.sh` — runs pull-all → ticket-hygiene → icm-check →
   tickets-board --today and writes a digest **outside the repo**
   (`~/.claude/estate/heartbeat-latest.md`; precedent: pull-all logs to
   `~/.claude/pull-all.log`). Read-only on every repo; proposes, never fixes.
2. A systemd **user timer** (survives reboots) invoking it daily; unit files are
   machine-level, documented in ROUTINES.md, shown to Jamie rather than enabled silently.
3. Upgrade `_system/hooks/session-start.sh` to print the digest delta: today picks,
   hygiene finding count, conformance gaps, digest age.
4. Create `_system/contracts/ROUTINES.md` — the registry of every scheduled thing (what
   runs, where, cadence, what it may write: digest files only; never tickets, never
   client email). Register the heartbeat as its first row.
5. Give `/day` a run log the digest can read: each run appends one line
   (`date · mode · picked/banked counts · note`) to `.icm/docs/day-log.md`; the digest
   reports the age of the last line as "board not reconciled in N days".

## Acceptance criteria (rough)

- [ ] A daily digest reaches the next session without Jamie initiating anything
- [ ] Read-only: no repo is modified; fixes stay judgment work in /day
- [ ] Survives reboots (systemd user timer, not a long-running process)
- [ ] `_system/contracts/ROUTINES.md` exists and registers the heartbeat
- [ ] Every /day run appends exactly one line to `.icm/docs/day-log.md`

## Out of scope (this feature)

- Anything cloud-scheduled — the estate is only whole on this machine.

## Prompt

Build the estate heartbeat for the Apps estate. Read
.icm/intake/estate-automation/estate-heartbeat.md and the archived original
.icm/intake/_done/ICM-001-estate-heartbeat.md for full context. It must run on Jamie's
machine — client repos in projects/ are gitignored and local-only. Never build an
orchestrator: the timer calls the scripts exactly as a human would, and everything stays
read-only — report, never fix. Repo files go through a PR on a claude/ branch; do not
run local checks — CI is the source of truth. Show Jamie the systemd unit files and the
enable commands rather than enabling them silently.
