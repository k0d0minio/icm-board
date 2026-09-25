# Measuring it — output tokens per stage and lane, before the output doctrine

> Superseded 2026-09-25 by `.icm/docs/2026-09-25-terse-sessions-measure.md`, which carries
> this baseline (recomputed, larger sample) side by side with the after-table and closes the
> stub. Kept as-is for history.

*Stub 3 of `terse-sessions` (`.icm/intake/terse-sessions/measure-output.md`). Read-only: no
script added, no client repo written. Source data is each archived run's `usage.md`
(`usage-snapshot.sh`), under every pipeline repo's `.icm/runs/_done/`.*

## Method

Each `usage.md` line is one snapshot, cumulative for the session at that instant. A stage's or
lane's own spend is `end.out − start.out` for the same `stage` + `session=` pair within one
file, matched in file order (a stage resumed twice in one run, e.g. `build` in
`launcher-dropdown`, produces two separate pairs). `out=` includes thinking tokens — Claude
Code does not separate them in the transcript — so it is a noisy proxy for prose length, not a
clean one. `turns` is likewise cumulative and meant to divide it into "output per human turn",
but on these runs (all `harness=claude-cloud`, one pipeline stage run start-to-finish as a
single dispatched turn) the delta is 0 for 29 of the 30 pairs — there is usually no second human
turn inside a stage — so `out/turns` is reported for one pair only and is not a usable
denominator for this dataset. Read every number below as a trend across a small sample, not a
precise measurement.

## Baseline — before the doctrine (any repo, any time)

Every pipeline repo under `projects/` was scanned for archived runs
(`.icm/runs/_done/*/usage.md`). Three repos have any: **agorasim** (3 runs), **jamienisbet**
(11 runs), **remi-ai** (3 runs) — 17 runs, 30 stage/lane pairs. None of the three had synced
`_shared/output.md` as of 2026-09-24 (checked directly: no `.icm/_shared/output.md` in any of
them), so this whole sample predates the doctrine — a clean baseline.

| Stage/lane | n | median out | mean out | min | max |
|---|---|---|---|---|---|
| bug (lane) | 4 | 13,311 | 17,070 | 7,613 | 34,044 |
| build | 7 | 26,231 | 40,786 | 17,043 | 102,927 |
| chore (lane) | 7 | 24,828 | 25,040 | 4,376 | 48,797 |
| define | 6 | 7,586 | 9,516 | 5,578 | 15,919 |
| release | 6 | 10,951 | 18,527 | 8,159 | 51,376 |

No archived `scope`, `tweak`, `hotfix` or `handover` runs exist yet — nothing to report for
those. (Two *live*, unarchived `scope` stages exist — berceo's `plateforme-v1` and remi-ai's
`september-source*` — excluded here because they are not archived runs; their `out=` was
41,636 and 49,610 respectively, for reference only.)

## After — blocked, waiting for runs

Only one repo has synced the doctrine so far: **berceo**, PR k0d0minio/berceo#26, from
icm-board `f424b49` — which carries stub 1 (`_shared/output.md` created) but **predates stub 2**
(#74, the loosening: chat-only scope, gates moved to the PR body, numbered `Operator:`, 2–5
summary bullets). Berceo's live `output.md` is still the bare stub-1 wording; a re-sync is
needed before its runs would measure the doctrine actually in the template today.

Berceo has one live run (`plateforme-v1`) and zero archived (`_done`) runs since the sync — 0
usable samples. Per the stub's acceptance criteria, this half stays open:

- blocked: waiting for runs — need ≥5 archived runs closed out on a repo synced to the current
  (post-#74) `_shared/output.md` before an after-table means anything.

## What these numbers can and can't show

- **Can:** give a rough order of magnitude per stage/lane today, and a baseline to diff the
  first post-sync batch against.
- **Can't:** separate prose from thinking tokens (`out=` is both, undifferentiated); say
  anything about *readability*, which is the doctrine's actual goal — token count is the
  secondary claim (breakdown, answer 6); support any per-stage claim at n<5 (`define` and
  `release` are the only stages at n=6, everything else is smaller); use `out/turns` as
  currently defined, since human-turn deltas are ~0 on cloud-dispatched stage runs.
- **Next step:** once berceo (or another repo) re-syncs past #74 and accumulates 5+ archived
  runs, repeat this read and place the two tables side by side.
