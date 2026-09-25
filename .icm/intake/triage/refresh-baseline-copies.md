# Stub: Refresh the stale baseline copies across the estate

- lane: chore
- found-by: baseline-copies-drift-unreported (D45) · 2026-09-25
- priority: P2

## Problem

Since D45, `icm-check.sh` reports `baseline drift` when a repo's `.icm/CONTEXT.md` or
`.icm/intake/README.md` differs from `_system/template/icm/`. On 2026-09-25 that produced
52 warnings: 27 of 28 intake copies and 25 of 28 maps. Only lourenco-botelho matches on
both, and casey-hebbel and jamienisbet match on the map only.

Most of these copies are stale, not deliberate:

- **Stale: retired `PREFIX-NNN` numbering in the intake copy, and `- profile:` in the map.**
  barzinho, boystomenretreat, cafe-jardim, collabimmo, dungeons-dragons, firedough,
  garmani, grafitala, kau-american-bbq, le-pavillon-vert, little-grass-shack, messy-play,
  miriamfridman, simnao, the-library (15 intake copies still teach `PREFIX-NNN`, or name
  it only as legacy in the case of dungeons-dragons). casey-hebbel's intake copy still
  teaches `CASEY-NNN`. courseday, escondidinho and pierpont each carry a short, older
  intake copy (6-line diff), and all 19 unadopted maps still carry `- profile:`.
- **Stale by a few lines**, where the D39 wording about the board reading `main` is
  missing: berceo, vinecliff, serviflow, sustentus, and icm-board's own intake copy. The
  maps of berceo and vinecliff are also stale.
- **Likely deliberate, needing Jamie's call per repo:**
  - remi-ai's intake README (197 lines, holds the backlog)
  - agorasim's intake README (40 lines)
  - jamienisbet's intake README (83 lines)
  - the full workspace maps in agorasim, remi-ai and sustentus (about 290 lines each)
  - serviflow's map
  - icm-board's own map

## Proposed change

For each stale repo, copy both files from `_system/template/icm/` and commit them
straight to `main` as ticket-adjacent `.icm/` wording, following the estate's fan-out
convention. For each deliberate divergence, Jamie picks one of two paths:

1. Fold the extra content somewhere the repo owns, such as `.icm/project.md` or
   `_shared/project-rules.md`, then refresh the copy from the template.
2. Accept the warning as registered divergence.

Changing sustentus goes through a PR there, because its `main` is ruleset-guarded.

## Prompt

In icm-board, run `_system/scripts/icm-check.sh` and collect its `baseline drift` lines.
Read `.icm/intake/triage/refresh-baseline-copies.md` for the classification made on
2026-09-25. For every repo whose copy is plainly stale, refresh `.icm/CONTEXT.md` and
`.icm/intake/README.md` from `_system/template/icm/`. Stale here means retired
`PREFIX-NNN` numbering, a `- profile:` line, or missing D39 wording. Before refreshing,
confirm with Jamie whether each change goes straight to that repo's `main` or through a
PR (sustentus is always a PR).

For every repo whose copy looks deliberate, show Jamie the diff and ask whether to fold
the content elsewhere and refresh, or keep the divergence. Never edit a copy without that
answer. Finish when the `icm-check.sh` rerun shows only the divergences Jamie kept.
