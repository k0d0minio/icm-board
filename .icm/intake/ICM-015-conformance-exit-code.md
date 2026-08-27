# ICM-015 · Decide what a red conformance run should mean

| | |
|---|---|
| Status | ready |
| Type | chore |
| Priority | P2 |
| Size | S |
| Sources | first real `estate-conformance.yml` run, 2026-08-27 · ICM-005 · ICM-010 |

## Problem

The first token-backed run of `estate-conformance.yml` worked — it read all 32 `k0d0minio`
repos and reported real per-repo findings. It also exited 1, because the last line of
`_system/scripts/estate-conformance.sh` is `(( n_gap == 0 ))`: any gap anywhere is a
failure. `icm-check.sh` ends the same way (`(( gaps == 0 ))`), so this is one convention
across both halves of the check, not a quirk of the CI copy.

Today 22 of 22 adopted repos have gaps — all four canonical assets missing from every one
of them, which is ICM-010's job and nobody else's. So the 07:00 daily run is a guaranteed
red every morning until ICM-010 lands across the estate. A scheduled report that is always
red teaches you to stop reading it, and by then it can no longer tell you about the thing
that actually broke.

There is a real argument on the other side: red is the nag that gets ICM-010 done, and a
green run with gaps in the summary is a run nobody opens either. That is the decision this
ticket is for — it should be made deliberately, not inherited from a one-line exit status.

## Build

Pick one and make both scripts agree:

1. **Gaps are green, unreachable is red** (recommended). Exit 0 with the summary listing
   gaps; keep exit 2 for "no token / no repos", which is the case where the report is
   lying rather than reporting. Matches the repo's own rule that conformance *reports, it
   does not repair* — a gap is the report's content, not the report failing.
2. **Red only on regression.** Green while findings match a committed baseline; red when a
   repo newly falls out of conformance. Catches drift, but adds a baseline file to keep
   honest — more machinery than this repo usually wants.
3. **Keep it as is** and accept a red daily run until ICM-010 closes, having decided that
   on purpose rather than by default.

Whichever wins, say so in a comment at the exit line of both scripts, so the next reader
finds the reasoning rather than re-opening this.

## Acceptance

- [ ] The decision is recorded in `.icm/project.md` (a decision row, as with D3/D7)
- [ ] `estate-conformance.sh` and `icm-check.sh` use the same convention
- [ ] The exit line in each script carries a comment saying why
- [ ] A scheduled run in the chosen steady state has been seen and is the colour intended

## Prompt

Decide what a red estate-conformance run should mean, then make the scripts agree. Read
`.icm/intake/ICM-015-conformance-exit-code.md` for the full context and the three options.

Short version: `_system/scripts/estate-conformance.sh` ends with `(( n_gap == 0 ))` and
`_system/scripts/icm-check.sh` ends with `(( gaps == 0 ))`, so any gap in any repo is a
non-zero exit. With every adopted repo currently missing the canonical Claude assets
(ICM-010), the daily 07:00 workflow is red every morning and will stay that way until that
ticket lands — which is how a scheduled report becomes noise nobody reads.

This is a judgement call, so put the options to Jamie rather than picking for him; the
ticket recommends option 1 (gaps exit 0, unreachable stays exit 2) and says why. Once he
picks, change both scripts, comment the exit line in each with the reasoning, and record
the decision in `.icm/project.md`. Open a PR on a `claude/` branch; do not run checks
locally — CI is the source of truth.
