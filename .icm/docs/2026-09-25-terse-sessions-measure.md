# Measuring it — output tokens per stage and lane, before and after the output doctrine

*Stub 3 of `terse-sessions` (`.icm/intake/terse-sessions/measure-output.md`), closing out.
Read-only: no script added, no client repo written. Source data is every archived run's
`usage.md` (`usage-snapshot.sh`), under each pipeline repo's `.icm/runs/_done/`. Supersedes
`.icm/docs/2026-09-24-terse-sessions-measure.md`, whose baseline half is reproduced and
extended below.*

## Method

Each `usage.md` line is one snapshot, cumulative for the session at that instant. A stage's or
lane's own spend is `end.out − start.out` for the same `stage` + `session=` pair within one
file, matched in file order. `out=` includes thinking tokens — Claude Code does not separate
them in the transcript — so it is a noisy proxy for prose length, not a clean one. `turns` is
likewise cumulative; on this dataset (`harness=claude-cloud`, one pipeline stage run
start-to-finish as a single dispatched turn) the delta is 0 for all but a handful of pairs, so
`out/turns` is not a usable denominator here — same finding as 2026-09-24, unchanged.

**Refinement since 2026-09-24:** the previous baseline classified a whole repo as "before" if
it had no `_shared/output.md` file at all on the day it was read. Every pipeline repo has now
synced the doctrine, so that heuristic no longer separates anything. This pass classifies each
*run* instead, by comparing its stage's own `start` timestamp against the exact commit
timestamp(s) that landed `_shared/output.md` in that run's repo:

| Repo | Doctrine landed (first, if pre-loosening) | Doctrine landed (current, post-#74) |
|---|---|---|
| agorasim | — | 2026-09-24T14:52:50Z |
| berceo | 2026-09-24T13:31:24Z (stub 1 only, k0d0minio/berceo#26) | 2026-09-24T16:07:06Z (k0d0minio/berceo#29) |
| jamienisbet | — | 2026-09-24T14:21:34Z |
| remi-ai | — | 2026-09-24T14:21:47Z |

A run starting before the earliest of these is "before"; a run starting at or after the
current (post-#74, loosened) commit is "after". berceo's window between its two syncs would be
a third, stub-1-only state — checked for runs and found empty, so nothing is excluded on that
account. serviflow, sustentus and vinecliff carry the doctrine too but have no `usage.md` files
in their archived runs at all (serviflow and vinecliff use a different close-out path;
sustentus has no archived runs yet) — they contribute nothing to either table.

This refinement also surfaces runs that were not visible on 2026-09-24: several agorasim and
berceo sessions from 2026-09-23–24 were only merged into `.icm/runs/_done/` afterwards by
batch merges (e.g. agorasim's k0d0minio/agorasim#130, "main takes uat"). Their *sessions* ran
before any doctrine existed, so they now correctly join the baseline — which is why the
baseline table below has more samples than 2026-09-24's, not because anything was recomputed
differently.

## Baseline — before any doctrine existed

28 runs across agorasim, berceo, jamienisbet and remi-ai, 57 stage/lane pairs.

| Stage/lane | n | median out | mean out | min | max |
|---|---|---|---|---|---|
| bug (lane) | 4 | 13,311 | 17,070 | 7,613 | 34,044 |
| build | 15 | 57,749 | 57,714 | 3,237 | 115,994 |
| chore (lane) | 9 | 19,845 | 22,036 | 4,376 | 48,797 |
| define | 14 | 16,102 | 14,276 | 5,578 | 28,558 |
| release | 14 | 19,717 | 24,086 | 8,159 | 51,376 |
| tweak (lane) | 1 | 5,276 | 5,276 | 5,276 | 5,276 |

No archived `scope`, `hotfix` or `handover` runs exist yet — nothing to report for those.

## After — post-#74 (the loosened doctrine actually live in the template today)

28 runs across agorasim (14), berceo (4), jamienisbet (10) — remi-ai has none post-sync yet —
52 stage/lane pairs. This clears the stub's ≥5-post-sync-runs bar by a wide margin.

| Stage/lane | n | median out | mean out | min | max |
|---|---|---|---|---|---|
| bug (lane) | 3 | 7,805 | 7,324 | 5,749 | 8,419 |
| build | 13 | 65,360 | 58,377 | 2,153 | 134,909 |
| chore (lane) | 5 | 19,025 | 16,900 | 1,948 | 28,847 |
| define | 11 | 15,370 | 17,284 | 9,464 | 28,806 |
| release | 11 | 30,874 | 31,198 | 10,749 | 56,476 |
| tweak (lane) | 9 | 7,085 | 7,126 | 1,846 | 22,213 |

Still nothing archived for `scope`, `hotfix` or `handover`.

## Side by side

| Stage/lane | before median | after median | delta |
|---|---|---|---|
| bug | 13,311 | 7,805 | −41% |
| build | 57,749 | 65,360 | +13% |
| chore | 19,845 | 19,025 | −4% |
| define | 16,102 | 15,370 | −5% |
| release | 19,717 | 30,874 | +57% |
| tweak | 5,276 (n=1) | 7,085 (n=9) | not comparable — n=1 baseline |

## What this does and doesn't show

- **No clean before/after token drop.** `define` and `chore` are flat, `bug` is down, `build`
  and `release` are *up* after the doctrine landed. The `release` jump is driven by two large
  berceo builds (`onboarding-professionnelle`, 134,909 out on `build`; 56,476 on `release`) —
  bigger features, not louder sign-offs. At this sample size, which stubs happened to run in
  each window explains more variance than the doctrine does.
- **This was expected, not a failure.** The breakdown (answer 6) was explicit that the token
  saving is measured, not promised — the doctrine's actual goal is chat readability for Jamie,
  which `out=` cannot see: it counts thinking tokens and file-writing tokens exactly the same
  as narration, and it cannot tell a terse stop report from a verbose one of the same length.
- **Sample sizes stay small.** Only `build`, `define` and `release` clear n≥10 in both tables;
  `bug` and `tweak` are single digits; `tweak`'s baseline is n=1, so its "after" number has
  nothing real to compare against.
- **`out/turns` still doesn't work** as a denominator on cloud-dispatched single-turn stage
  runs — unchanged from 2026-09-24.
- **Repo coverage is uneven.** Three of seven pipeline repos (serviflow, sustentus, vinecliff)
  contribute zero archived `usage.md` pairs to either table, for reasons unrelated to the
  doctrine (missing archives or a different close-out path) — this is not a doctrine effect,
  it's a data-availability gap worth noting if anyone extends this later.

## Closing the stub

Acceptance criteria met: a baseline table with sample sizes (from archived runs only), an
after table from ≥5 post-sync runs (28, well past the bar), and this section stating plainly
what the numbers can and can't show. The honest finding is that token count alone doesn't
demonstrate the doctrine worked or didn't — that was never the readable-chat goal's job to
prove, and no further script or measurement is proposed here.
