# Stub: Measure it — output tokens per stage, before and after the doctrine

- feature-slug: measure-output
- epic: terse-sessions
- priority: P2
- size: S
- depends-on: wire-stop-reports
- sequence: 3 of 3
- sources: the breakdown (answer 6) · `_system/template/icm-pipeline/scripts/usage-snapshot.sh`
  (`out=` is cumulative per session; a stage's own is `end − start` on the same `session=`) ·
  archived runs' `usage.md` under each pipeline repo's `.icm/runs/_archive/` (path per
  `close-out.sh`)

## Problem

The epic is justified on readability; tokens are the secondary claim. Without a number the
token claim stays a guess, and `usage.md` already holds the data on every archived run.

## Proposed change

- **Baseline (any time, needs nothing):** read every archived run's `usage.md` across the
  pipeline repos (`projects/`, local machine), pair `start`/`end` lines per stage on the same
  `session=`, and report median `out=` and `out/turns` per stage and lane, plus the sample size.
  One-off reading — no new script; if a reusable reader proves worth it, park a triage stub.
- **After:** once stub 2 is synced to a repo and at least ~5 runs have closed out on it, the
  same numbers for those runs, side by side.
- Write both to `.icm/docs/<date>-terse-sessions-measure.md` and a log row in
  `.icm/project.md`. Say plainly what the numbers can't separate: `out=` includes thinking
  tokens, so they are noisy — read them as a trend, and say so if the sample is too small to
  mean anything.

## Acceptance criteria (rough)

- [ ] baseline table with sample sizes, from archived runs only
- [ ] after table from ≥5 post-sync runs, or the stub stays open with `- blocked: waiting for runs`
- [ ] the doc says what the numbers can and can't show

## Prompt

In icm-board (`~/Apps`, local machine — the pipeline repos under `projects/` are needed),
carry out stub 3 of the `terse-sessions` epic: read `.icm/intake/terse-sessions/breakdown.md`
and this stub (`measure-output.md`). From the archived runs' `usage.md` files across the
pipeline repos, compute output tokens per stage and lane (paired `start`/`end` on one session)
before the output doctrine, then — once enough runs have closed out after the sync — after it.
Write the comparison to `.icm/docs/` and a log row in `.icm/project.md`, with sample sizes and
the caveat that `out=` includes thinking. Read-only on every client repo; no new script.
Commit straight to `main` as a `Plan:` commit.
