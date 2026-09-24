# Breakdown: One branch, two deployment targets — the UAT branch retired (D39)

- epic-slug: one-branch-two-targets
- sources: Jamie 2026-09-24 — "the whole issue with the uat setup is that it leaves a lot of room
  for discrepancies … tickets tracked over 2 branches, the drift in branches is felt, … different
  configurations per project"; the eight answers of the same session (D39's row) · the
  dependency map of the UAT branch across the template, contracts and board scripts (2026-09-24,
  in the D39 log row) · Vercel docs read 2026-09-24: *Promoting Deployments* (staged production,
  Auto-assign toggle, Staged/Promoted/Current), *Environments* (custom environments, Pro, one per
  project, `--target`), *System environment variables* (`VERCEL_TARGET_ENV`), *Marketplace
  storage* (a native resource scoped to a custom environment), *Promote preview to production*
  (a promoted preview rebuilds) · live reads 2026-09-24: kodominio and sustentus custom-environment
  limit 1 with none used; agorasim `uat` 9 ahead / `main` 1 ahead; berceo `uat` 4 ahead; UAT
  domains bound to git branch `uat`; Neon `preview/uat` on both; `db-migrate.yml` on `push: main`
  on both; berceo rulesets on `main`+`uat`, agorasim none

## What I understood

D31 made UAT a long-lived git branch that every run's PR targets, promoted to `main` by a batch
PR and pulled back by `promote-uat.sh sync`. The branch is therefore permanently *ahead* of
`main`, and everything since has been paying for that gap:

- **Tickets die on `uat` and are read on `main`** (D38's problem). D38 moved the reader — but
  left `main` with a lagging copy, kept hotfix and knowledge on `main`, and made `sync`
  "required" after both. A day later agorasim's `main` carried a knowledge merge (#126) `uat`
  had never received.
- **Two shapes in the estate.** `pipeline_base_branch` (`lib/project.sh:358-360`) is the switch
  every script and contract branches on; two more places (`_system/scripts/lib/ticket-base.sh`,
  `wrap-reminder.sh`) re-derive it. Two repos declare UAT, four do not, and the scripts behave
  differently on each.
- **Nothing the client needs requires a second branch.** D31's real asks — one fixed address, the
  whole batch integrated, sign-off before production, one announcement per batch — are all
  properties of *deployment targets*, not of branches.

**The decision (D39, `.icm/project.md`):** `main` is the only long-lived branch. UAT is a Vercel
**custom environment** deployed from `main` on every merge, with its own variables (a named Neon
branch) and domain. Production stops following `main`: Auto-assign Custom Production Domains is
off, so every merge builds a **Staged** production deployment, promoted only when the client
signs off. The client's word is a **GitHub Release** drafted by `promote.sh approve` and
**published by the operator**; the release workflow migrates production, promotes the staged
deployment of that SHA and announces. The batch is `git log <last release>..main`. Ticket state
goes straight to `main` everywhere, as icm-board always did. Clean cut: `uat.branch`,
`promote-uat.sh`, `uat/CONTEXT.md` and `batch.json` go.

What must be true for the cutover to be safe, in this order: the Auto-assign toggle is **off
before** `uat` is merged into `main` (or the unsigned batch ships to production), and the
production migrator is **on the release event before** that merge (or the batch's migrations run
against production on the push).

## Build order

1. `template-two-targets` — the pipeline template: `promote.sh`, `_shared/promotion.md`,
   `release.yaml` on `release: published`, the reference `db-migrate.yml` moved to that event,
   every script and contract reading `main`, `setup.sh`/`/setup` refusing a branch and checking
   Pro. Fixture-proven.
2. `board-reads-main` — icm-board's own scripts, hook and canonical skills (both copies), the
   `/day` and `/project` contracts, `TICKETS.md`. Independent of 1; can run in parallel.
3. `cutover-agorasim-berceo` — the ordered operator checklist and the session's PRs, berceo
   first. The first real promotion on berceo is the proof of the whole route.
4. `estate-sync-d39` — the four other pipeline repos take the template; nothing else changes for
   them. Sustentus on Jamie's word.
5. `uat-database-resource` — added 2026-09-24 from berceo's cutover (D41): the UAT database is a
   second Marketplace database, not a branch of production's; the template learns a production
   and a non-production Neon project. Independent of agorasim's cutover, which runs by hand
   meanwhile.

Not in this epic: serviflow (Railway; set aside by Jamie, 2026-09-24); offering UAT to repos that
do not declare it today (a `/setup` conversation per repo, later).
