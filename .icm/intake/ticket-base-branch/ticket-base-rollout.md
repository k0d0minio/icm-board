# Stub: Roll D38 out — sync the estate, the operator's per-repo acts, prove it on berceo

- feature-slug: ticket-base-rollout
- epic: ticket-base-branch
- priority: P1
- size: L
- depends-on: template-ticket-scripts, board-scripts-ticket-base
- sequence: 4 of 4
- blocked: agorasim — its Neon project is at the 10-branch cap, so #121's preview cannot provision; Jamie prunes the seven stale `preview/claude/*` branches (2026-09-23)
- sources: breakdown · `gh api repos/k0d0minio/{berceo,agorasim}` 2026-09-23 — berceo public,
  agorasim private (free plan, no branch protection), default branch `main` · memory: berceo
  rulesets (merge gate requires `Vercel`, admin bypass)

## Problem

Stubs 1–3 change the template and icm-board; no client repo changes until it is synced, and the
repo settings the new route touches (the label, rulesets) are the operator's.
The dashboard still reads the default branch until the jamienisbet stub lands.

## Proposed change

1. **Prove first, on berceo** (a UAT repo): sync its T files (`icm-sync.sh --apply`); refresh
   `pr-conventions`, `ticket-craft` and `wrap-reminder.sh` by hand in the same PR (D7 forbids a
   script syncing them, not a reviewed PR); Jamie creates `type:tickets`. Then one real
   ticket PR end to end: path guard verified, merged at once through the merge gate's admin bypass
   (`--admin`), visible on the board from `uat`.
2. **agorasim** (the other UAT repo): the same; no branch protection there, so a plain squash
   merge.
3. **The rest of the estate**: pipeline repos by `icm-sync.sh --apply`, one PR each; canonical
   skills by hand; `type:tickets` label in each repo. Intake-only repos get the two skills.
4. **Rulesets**: the admin bypass on any branch whose ruleset requires checks **stays** — the
   immediate ticket merge goes through it, and `sync` still pushes `uat`. What goes is the direct
   `Plan:`/`Wrap:`/Scope push to a client `main`.
5. **Optional, cost only**: an `.icm/`-only ignore step where ticket PR previews or preview
   databases prove noisy.
6. **One-off check** on berceo and agorasim: every stub open on `main` but `_done` on `uat` is
   explained by the lag, not by a real gap; `promote-uat.sh status` clean.

## Acceptance criteria (rough)

- [ ] berceo: a ticket PR merged at once (no check wait) and shows on the board from `uat`
- [ ] agorasim: same
- [ ] `icm-check.sh` shows no `pr-conventions` / `ticket-craft` drift across the estate
- [ ] The dashboard stub in jamienisbet merged (the board reads the ticket base branch)
- [ ] A dated rollout note in `.icm/docs/` — repos changed, skipped and why

## Progress

- 2026-09-23: berceo, jamienisbet, remi-ai, sustentus, vinecliff synced to `de444cd` and merged (berceo#23, jamienisbet#149, remi-ai#121, sustentus#1153, vinecliff#19); berceo `uat` takes `main` by hand (conflicts: #21 carried its own sync); `type:tickets` created in all six; berceo proof done — berceo#24 merged at once into `uat` with `--admin`, on the board from `uat`. agorasim#121 open, blocked on the Neon cap (its cleanup workflow never ran — fixed in icm-board#69). Dashboard stub in jamienisbet not started. Full note: `.icm/docs/2026-09-23-ticket-base-rollout.md`.

## Prompt

In icm-board (`~/Apps`, local machine only — `projects/` is invisible to cloud sessions), carry out
stub 4 of the `ticket-base-branch` epic: read `.icm/intake/ticket-base-branch/breakdown.md`,
`ticket-base-rollout.md`, and the D38 entry in `.icm/project.md`. Prove the new ticket route on
berceo first (sync, skills by hand, one real `type:tickets` PR merged at once and visible on the
board), then agorasim, then the
rest of the estate one PR per repo. The repo settings — labels, rulesets, Vercel — are
Jamie's acts: list them and ask, never change them yourself. Sustentus only on Jamie's word. Commit
each client repo immediately (the `projects/` tree is shared with a sweeper) and leave every
checkout on `main`.
