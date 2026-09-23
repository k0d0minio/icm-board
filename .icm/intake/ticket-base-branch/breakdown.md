# Breakdown: Ticket state has one home per repo — the ticket base branch, reached only through a PR

- epic-slug: ticket-base-branch
- sources: Jamie's report 2026-09-23 (a finished stub still shows open on a UAT repo because its
  `_done/` move never reached `main`) · Jamie's rulings 2026-09-23 — every client repo's `.icm/`
  ticket change goes through a PR; icm-board keeps its direct `Plan:`/`Wrap:`/`Deal:` commits
  (no UAT branch, nothing to drift); the knowledge lane stays on `main`; the session that opens a ticket
  PR merges it immediately, without waiting for Vercel or any check (auto-merge rejected: not on
  the free plan for private repos) · investigation 2026-09-23 of the template, icm-board's board
  scripts and the jamienisbet dashboard (below)

## What I understood

On a repo that declares `uat` (D31), a ticket is **born on one branch and dies on another**:

- **Birth on `main`.** Scope pushes the intake cut straight to `main`
  (`_system/template/icm-pipeline/stages/01_scope/CONTEXT.md` step 7; `_shared/github.md` PR
  regime 1). So do `/day`, `/project` and the template-change guard (`_shared/template-change.md`
  step 3) — "ticket-only commits go straight to `main`" (`pr-conventions`, both copies).
- **Death on `uat`.** `close-out.sh` `git mv`s the stub to `_done/` inside the run's PR, and on a
  UAT repo that PR merges into `uat`. `main` sees the move only when the batch is promoted.
- **Every reader looks at `main`.** The dashboard reads each repo's *default branch*
  (`git/trees/HEAD`, never a named ref, no knowledge of `uat` —
  `websites/admin-dashboard/lib/tickets.ts:705`); icm-board's `tickets-board.sh` and
  `ticket-hygiene.sh` read the `projects/` working trees, which sit on `main`;
  `client-status.sh` reads the queue from `origin/main`.

Result: a finished stub reads as open until promotion, can be picked into `today.md`, and can be
run twice.

**The decision (next free D-number — D37 when this was cut).** Each client repo's ticket state has
**one home: its ticket base branch** — `uat.branch` where `.icm/project.json` declares one, else
`main`. That is exactly what `lib/project.sh → pipeline_base_branch` already answers, so it is
reused, not duplicated (one home per fact, D24). Every writer reaches it **through a PR**; every
reader reads it. `main` on a UAT repo carries a lagging copy that only promotions update, and
nothing reads it for tickets.

- **The ticket PR** — the shape every writer uses: branch `claude/tickets-<topic>-<YYYYMMDD>`;
  title `Plan: …` / `Wrap: …` / `Scope: <slug> — intake cut`; label `type:tickets`; body carries
  `- announce: none` and `- audience: internal` (so `release.yaml` can never announce it to the
  client as `pr-<n>`); path guard `.icm/intake/**` plus, for Scope, `.icm/runs/<slug>/**` —
  anything else is not a ticket PR.
- **Landing it** — "merging is publishing" replaces "pushing is publishing". The session that
  opened the ticket PR **merges it immediately** (squash), without waiting for Vercel or any other
  check (Jamie, 2026-09-23): the diff is ticket markdown only, so there is nothing for a check to
  catch. The safety is the **path guard, verified before the merge**: `git diff --name-only
  origin/<base>...HEAD` lists only `.icm/intake/**` (and, for Scope, `.icm/runs/<slug>/**`) —
  anything else and it is not a ticket PR, so the session stops and does not merge. Where a
  ruleset requires checks (berceo's merge gate requires `Vercel`), the merge goes through the
  admin bypass (`gh pr merge --squash --admin`), which is why that bypass must stay. GitHub
  auto-merge is not used. A ticket PR is the one PR an agent merges; code, lane and promotion PRs
  stay the operator's.
- **Scope's front becomes a ticket PR** into the base branch — the reversal of PR regime 1. The
  stub exists (for `new`) once it merges. The scope is reviewed before `new`, as today.
- **Exceptions that stay on `main`:** hotfix (production is wrong now) and the knowledge lane
  (Jamie, 2026-09-23). Their close-outs land on `main`, so on a UAT repo the board shows their
  stubs open until `promote-uat.sh sync` — which becomes a **required** follow-up for both, not
  only the hotfix.
- **icm-board is exempt** and keeps direct commits to `main` (`Plan:`/`Wrap:`/`Deal:`, `today.md`).

**Out of scope:** estate plumbing fan-outs straight to `main` (Jamie's 2026-09-07 ruling) — they
carry no ticket state. Sustentus stays exempt from the baseline; its T files follow on Jamie's word
(D20).

**Costs found in the investigation that the stubs must answer:**
- A ticket PR's push can still start a Vercel preview, a Neon `preview/<branch>` branch (D32) or a
  Mongo `preview_<branch>` database (D35), and a merge into `uat` rebuilds the client's address
  for a markdown change. The merge does not wait for any of it, so this is cost and noise, not a
  blocker: an ignore step that skips `.icm/`-only diffs is worth adding, not required.
- An open ticket PR conflicts with a run's close-out moving the same stub. Merging immediately
  keeps that window to seconds; a PR that no longer merges cleanly is rebased on its base and
  retried once, then reported.
- `projects/` is one shared tree with a sweeper: `/day` must cut ticket branches in a worktree, or
  switch the checkout back to `main` before ending.

The dashboard's half is a jamienisbet ticket (tickets live next to their logic):
`jamienisbet` → `.icm/intake/ticket-base-branch/dashboard-reads-ticket-base.md`.

## Build order

1. ticket-base-contract — D37 recorded; contracts, stage docs and canonical skills say "ticket base branch, through a PR" — depends-on: none
2. template-ticket-scripts — the template's scripts and workflows read and guard the ticket base branch — depends-on: ticket-base-contract
3. board-scripts-ticket-base — icm-board's board, hygiene and `/day` read and write each repo's ticket base branch — depends-on: ticket-base-contract
4. ticket-base-rollout — sync the estate, the operator's per-repo acts, prove it on berceo — depends-on: template-ticket-scripts, board-scripts-ticket-base
