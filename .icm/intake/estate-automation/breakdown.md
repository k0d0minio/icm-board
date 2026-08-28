# Breakdown: Estate automation — the heartbeat and its semantics

- epic-slug: estate-automation
- sources: recut 2026-08-28 from ICM-015 · ICM-001 (intake/_done/) — the exit-code
  decision shapes what the daily digest's colour means, so it goes first

## What I understood

The estate has zero scheduled automation; the one automatic surface (the SessionStart
board) under-reports. A daily heartbeat should run the read-only estate scripts and
leave a digest a session can read. Before it exists, the standing question of what a red
conformance run *means* must be decided — otherwise the heartbeat inherits a
guaranteed-red morning (doubly so now: the pipeline rework widened the baseline, so
every repo has gaps until the seeding pass in the estate-migration epic runs).

## Build order

1. conformance-exit-code — decide what a red run means; make both scripts agree — depends-on: none
2. estate-heartbeat — daily timer, digest, session-start delta, /day run log — depends-on: conformance-exit-code

## Out of scope (whole epic)

- Anything that writes to a repo — the heartbeat reports; fixes stay judgment work in /day.
- Client email, outbound anything. ROUTINES.md (cut inside estate-heartbeat) registers
  what a routine may write: digest files only, never tickets.
