# Stub: Cut agorasim and berceo over to one branch — the operator's ordered checklist, the session's PRs, the first real promotion

- feature-slug: cutover-agorasim-berceo
- epic: one-branch-two-targets
- priority: P1
- size: M
- depends-on: template-two-targets, board-reads-main
- sequence: 3 of 4
- sources: D39 · live reads 2026-09-24 — agorasim: `uat` 9 ahead of `main` (#127, #120, #117,
  #116, #114 and four `uat takes main` merges), `main` 1 ahead (#126 knowledge); `batch.json`
  stubs `admin-quote-builder`, `stale-web-docs-refs`, unapproved; Vercel `uat.agorasim.pt`
  bound to git branch `uat` (project.json says `uat.agorasim.jamienisbet.com` — they disagree);
  Neon `preview/uat` (vercel-created, child of `main`); no GitHub rulesets (Free, private);
  `db-migrate.yml` on `push: main` · berceo: `uat` 4 ahead (#22 Neon Auth accounts, #21 design
  system, a `Plan:` on `uat`, one sync merge), `main` 0 ahead; `batch.json` stubs
  `socle-design-system`, `comptes-neon-auth`, unapproved, no promotions yet; Vercel
  `uat.berceo.be` bound to git branch `uat`; Neon `preview/uat`; rulesets *pipeline branches:
  history* (`main`,`uat`; no deletion, no force-push) and *merge gate* (`main`,`uat`; PR +
  checks; RepositoryRole bypass always); `db-migrate.yml` on `push: main` · both: kodominio is
  Pro, custom-environment limit 1, none used; SSO protection `all_except_custom_domains`

## Problem

Both repos carry an unsigned batch on `uat`, ahead of `main`. Merging `uat` into `main` under
today's settings would auto-promote the batch to production *and* run its migrations against the
production database on the push. The cutover has one safe order, and half its steps are the
operator's Vercel, Neon and GitHub acts, which no script performs (D31, D32, D39 §9).

## Proposed change

**berceo first** (public, rulesets, smaller batch, no promotion history), then agorasim. Per repo,
in this order; **[Jamie]** = the operator's act from this checklist, **[session]** = an agent's.

0. **[session] Freeze.** `promote-uat.sh status` clean (no approval pending, no open promote PR);
   record `origin/main`, `origin/uat` and the batch's stubs in the rollout note. From here no
   run merges into `uat`.
1. **[Jamie] Vercel → project → Settings → Environments → Production → Branch Tracking →
   Auto-assign Custom Production Domains: OFF.** Confirm the next `main` build shows *Staged*.
   **Nothing is merged before this step.**
2. **[Jamie] Vercel → Settings → Environments → Create Environment `uat`.** No branch tracking
   yet. Import variables from Preview if that is where the UAT values live today. Attach the
   domain: move `uat.berceo.be` (agorasim: choose `uat.agorasim.pt` or
   `uat.agorasim.jamienisbet.com` — the declared `url` follows the choice) from git branch `uat`
   to the environment (Domains → the domain → Environment: `uat`).
3. **[Jamie] Neon console → project → create branch `uat`** from `main` (production), no expiry.
   Set its pooled and unpooled strings on the `uat` environment's variables (`DATABASE_URL`,
   `DATABASE_URL_UNPOOLED`) — values never in git, chat or a PR. Do **not** connect the Neon
   integration to `uat`. `preview/uat` goes with the git branch (step 7).
4. **[Jamie] Try Branch Tracking `main` on `uat`.** If Vercel refuses it on the production
   branch, the reference `uat-deploy.yaml` (stub 1) ships in step 5 and the Vercel token secret
   named by `project.json → deploy.token_env` must exist in Actions.
5. **[session] The sync PR into `main`.** `icm-sync.sh --apply` (T files: `promote.sh`,
   `promotion.md`, every script; the reference `release.yaml`, `db-migrate.yml` on the release
   event, `neon-cleanup.yaml`; `uat-deploy.yaml` if step 4 refused), canonical `.claude/` assets
   by hand, `project.json` → `uat: {target: "uat", url}`, `database.neon.uat_branch: "uat"`,
   `.icm/uat/batch.json` deleted, `project-rules.md` updated. **Jamie merges.** The merge builds
   a *Staged* production deployment (step 1 makes that safe) and a UAT deployment; `db-migrate`
   does not fire (release event only). Read `promote.sh status`.
6. **[session] Baseline release, then `main` takes `uat`.** First `gh release create` at the
   pre-merge `origin/main` SHA with `announce: none` — what production serves today; the workflow
   finds it Current and does nothing (this is the idempotency proof). agorasim: if
   `report.sh` already tagged the 2026-09-23 promotion, that Release is the baseline. Then a PR
   `chore: main takes uat — the batch of <n> stubs (D39 cutover)`: conflicts on `batch.json` →
   deleted; template files → `main`'s. **Jamie merges.** Now: a *Staged* build of the whole batch,
   the same on UAT, migrations applied to the `uat` Neon branch at build, production untouched.
7. **[Jamie] Delete git branch `uat`.** berceo: remove `refs/heads/uat` from both rulesets first
   (*history* forbids deletion). agorasim: no rulesets. Neon `preview/uat`: deleted by the
   integration with the branch, else by hand in the console.
8. **[session] Read back.** `promote.sh status` (batch = the merged stubs; a Staged deployment
   for HEAD; the UAT deployment READY), `client-status.sh` (*on UAT, awaiting your word* = the
   batch), `deploy-status.sh --uat --sha <merge>`, `db-env.sh status` (`uat` present, no
   `preview/uat`); the board shows the batch's stubs `_done` (they were done on `uat`, now on
   `main`); `today.md` unaffected; every checkout left on `main`.
9. **[Jamie] The first real promotion — the proof of D39.** When the client signs the batch off:
   `promote.sh approve --by "<who>"`, publish the draft on GitHub, read `release.yaml`: migrate →
   verify → promote → `deploy-status` → announce. Production serves the batch; `promote.sh status`
   shows an empty batch. Until this runs on berceo, D39 is fixture-proven only.
10. **[session] jamienisbet.** Drop the dashboard stub cut for D38 (the board reads the ticket
    base branch — k0d0minio/jamienisbet#148's context) with a `> Dropped: superseded by D39,
    <date>` line, committed straight to its `main`: the dashboard's `git/trees/HEAD` read is right
    again. Rollout note `.icm/docs/2026-09-24-one-branch-cutover.md`: SHAs, choices (the agorasim
    UAT domain), refusals (branch tracking), what was proven.

## Notes from stub 1 (template-two-targets, 2026-09-24)

- **Step 5 — `report.sh` is P, never synced.** The reference `release.yaml` calls
  `report.sh announce … --tag <the Release's tag>` so the published promotion Release is reused,
  not duplicated; a repo's older `report.sh` rejects `--tag` (`RESULT: SKIPPED (usage)` → a red
  announce step). Copy the template's `report.sh` over the repo's by hand in the sync PR (or add
  the `--tag` flag to a customised one).
- **Step 5 — `release.yaml`'s `migrate` job** calls `./.github/workflows/db-migrate.yml`; give the
  repo's migrator the reference shape (triggers + the `gate` job + job-level concurrency, its own
  steps kept). A repo without one deletes the job and drops it from `promote.needs`.
- **Step 6 — the baseline.** The workflow promotes only a Release whose body carries
  `- promote-sha: <40 hex>` equal to its tag's commit; any other published Release is a notice and
  a no-op. For the idempotency proof, draft the baseline with `promote.sh approve --by "<operator>"
  --sha <pre-merge origin/main> --announce none` and publish it: `stage` finds the deployment
  already Current and nothing is promoted. If a `release/` tag already sits at that SHA,
  `approve` refuses ("already released") — that tag is the baseline and there is nothing to run.
- **Step 8 — proofs still owed by the real run:** which field Vercel's v6 deployment list uses for
  a custom environment (`deploy-status.sh --uat` matches `customEnvironment.slug`, then the id
  from `GET /v9/projects/<p>/custom-environments`, then `target`); that `GET /v9/projects/<p>`
  carries `targets.production.id` (the Staged/Current test in `promote.sh status` and the
  workflow's poll); `vercel build --target=<slug>` in `uat-deploy.yaml` if branch tracking is
  refused.

## Acceptance criteria (rough)

- [ ] berceo: steps 1–8 done, `uat` deleted, `promote.sh status` clean, batch visible on UAT
- [ ] berceo: one real promotion through the published Release — migrate, promote, announce
- [ ] agorasim: steps 1–8 done; its UAT domain chosen and declared once
- [ ] Neither repo has `.icm/uat/`, `uat.branch`, a `preview/uat` Neon branch or a `uat` git branch
- [ ] The jamienisbet dashboard stub dropped; the rollout note written

## Prompt

In icm-board (`~/Apps`, local machine only — `projects/` is invisible to cloud sessions), carry out
stub 3 of the `one-branch-two-targets` epic: read the breakdown, this stub and decision D39 in
`.icm/project.md`. Walk the ordered checklist with Jamie, berceo first: **his** steps are Vercel,
Neon and GitHub settings — list each, wait for his word that it is done, read it back through the
API, never perform it. **Yours** are the sync PR, the baseline Release, the `main takes uat` PR
(he merges both) and the read-backs. Auto-assign must be off before anything merges. Commit each
client repo immediately (the `projects/` tree is shared with a sweeper) and leave every checkout
on `main`.
