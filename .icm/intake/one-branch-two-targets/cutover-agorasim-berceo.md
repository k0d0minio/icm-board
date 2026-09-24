# Stub: Cut agorasim and berceo over to one branch — the operator's ordered checklist, the session's PRs, the first real promotion

- feature-slug: cutover-agorasim-berceo
- epic: one-branch-two-targets
- priority: P1
- size: M
- depends-on: template-two-targets, board-reads-main
- sequence: 3 of 5
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
2. **[Jamie] Vercel → Settings → Environments → Create Environment `uat`.** Attach the domain:
   move the UAT domain (agorasim: choose `uat.agorasim.pt` or `uat.agorasim.jamienisbet.com` —
   the declared `url` follows the choice) from git branch `uat` to the environment (Domains →
   the domain → Environment: `uat`). **Set no database variable by hand** — step 3 does it.
3. **[Jamie] The UAT database is a second Marketplace database, never a branch of production's
   (D41 — proven on berceo 2026-09-24; the named-branch shape of the first draft sent every UAT
   build to production).** In order:
   a. **Vercel → Storage → Create Database → Neon**, named `uat-<repo>`, same region.
   b. **Its connection → project → environments: `uat` + Preview (+ Development)**, no prefix;
      Advanced options → Deployments configuration: **Preview on**, *Resource must be active
      before deployment* on.
   c. **Production's database → its connection → Production only**; Preview branching **off**.
      Any production database still connected to Preview hijacks UAT (Vercel's Preview
      Deployment Action fallback), and a production database connected to `uat` hands UAT its
      Preview secret — production's string.
   d. **Neon Auth on the new database** (only where the app uses it) = production's: verification
      by link and required, the OAuth providers production has (Google off on berceo), the same
      SMTP sender, trusted origins = the UAT domain(s), the `send.magic_link` webhook at
      `<uat url>/api/webhooks/neon-auth`.
   e. Every other variable the app needs on `uat` (`.env.example` → `[preview]`) set on the `uat`
      environment by hand — secrets, never database strings.
4. **[Jamie] Try Branch Tracking `main` on `uat`.** If Vercel refuses it on the production
   branch, the reference `uat-deploy.yaml` (stub 1) ships in step 5 and the Vercel token secret
   named by `project.json → deploy.token_env` must exist in Actions.
5. **[session] The sync PR into `main`.** `icm-sync.sh --apply` (T files: `promote.sh`,
   `promotion.md`, every script; the reference `release.yaml`, `db-migrate.yml` on the release
   event, `neon-cleanup.yaml`; `uat-deploy.yaml` if step 4 refused), canonical `.claude/` assets
   by hand, `project.json` → `uat: {target: "uat", url}` (`database.neon.uat_branch` stays as the
   template requires until `uat-database-resource` reshapes the block — berceo carries `"uat"`),
   `.icm/uat/batch.json` deleted, `project-rules.md` updated. **Jamie merges.** The merge builds
   a *Staged* production deployment (step 1 makes that safe) and a UAT deployment; `db-migrate`
   does not fire (release event only). Read `promote.sh status`.
6. **[session] Baseline release, then `main` takes `uat`.** The baseline goes at the **sync PR's
   merge SHA**, not the pre-merge one: GitHub runs a `release` workflow from the file at the
   tagged commit, and the pre-merge commit has no `release.yaml` — so the Release would record a
   floor and prove nothing. `promote.sh approve --by "<operator>" --sha <sync merge> --announce
   none`, published: a real promotion of template-only changes (stage → migrate → promote →
   deploy-status), the whole route proven before the batch (berceo: Jamie's choice, 2026-09-24). agorasim: if
   `report.sh` already tagged the 2026-09-23 promotion, that Release is the baseline. Then a PR
   `chore: main takes uat — the batch of <n> stubs (D39 cutover)`: conflicts on `batch.json` →
   deleted; template files → `main`'s. **Jamie merges.** Now: a *Staged* build of the whole batch,
   the same on UAT, migrations applied to the UAT database at build, production untouched —
   **verify it** (step 8), never assume it.
7. **[Jamie] Delete git branch `uat`.** berceo: remove `refs/heads/uat` from both rulesets first
   (*history* forbids deletion). agorasim: no rulesets. Neon `preview/uat` in production's
   project: deleted by the integration with the branch, else by hand in the console.
8. **[session] Read back.** `promote.sh status` (batch = the merged stubs; a Staged deployment
   for HEAD; the UAT deployment READY), `client-status.sh` (*on UAT, awaiting your word* = the
   batch), `deploy-status.sh --uat --sha <merge>`, `db-env.sh status` (`uat` present, no
   `preview/uat`); the board shows the batch's stubs `_done` (they were done on `uat`, now on
   `main`); `today.md` unaffected; every checkout left on `main`. **The database proof, by the
   Neon API:** the UAT database's `main` carries the app's tables; production's `main` shows no
   activity since the baseline and no UAT address among its Auth trusted origins; each UAT
   deployment's `integrations` phase is ~0 s (a Preview Deployment Action on it means the
   fallback fired). **The preview proof:** a throwaway draft PR (an empty commit) gets
   `preview/<branch>` inside the UAT database's project; close it unmerged and delete the
   orphaned preview branch by hand (`neon-cleanup.yaml` still looks in production's project
   until `uat-database-resource`).
9. **[Jamie] The first real promotion — the proof of D39.** When the client signs the batch off:
   `promote.sh approve --by "<who>"`, publish the draft on GitHub, read `release.yaml`: migrate →
   verify → promote → `deploy-status` → announce. Production serves the batch; `promote.sh status`
   shows an empty batch. Until this runs on berceo, D39 is fixture-proven only.
10. **[session] jamienisbet.** Drop the dashboard stub cut for D38 (the board reads the ticket
    base branch — k0d0minio/jamienisbet#148's context) with a `> Dropped: superseded by D39,
    <date>` line, committed straight to its `main`: the dashboard's `git/trees/HEAD` read is right
    again. Rollout note `.icm/docs/2026-09-24-one-branch-cutover.md`: SHAs, choices (the agorasim
    UAT domain), refusals (branch tracking), what was proven.

## berceo — steps 0–8 done (2026-09-24)

- Freeze: `origin/main` `b7baccef` (= production), `origin/uat` `35971814` (5 ahead), batch
  `socle-design-system`, `comptes-neon-auth`, `vitrine-publique`.
- Vercel: Auto-assign off (`autoAssignCustomDomains: false`); custom environment `uat`
  (`env_nMM6sr5qRp8yMDCgBwU6YXX2JUf1`), branch tracking `main` **accepted** — no
  `uat-deploy.yaml`; `uat.berceo.be` attached to it. Actions secret `VERCEL_TOKEN_KODOMINIO` added.
- k0d0minio/berceo#26 (sync to icm-board f424b49) merged `5916543`: Staged production build, UAT
  build, `Migrate production` **skipped** by the gate.
- Baseline `release/2026-09-24-promote-5916543` (announce none), published: stage → migrate
  (`0000` onto production — never migrated before) → promote (201; `dpl_5gKNQ…` Current) →
  deploy-status READY. **Proven:** the promote call, `targets.production.id`, `customEnvironment.slug`
  on the v6 list, the gate on push and on `workflow_call`.
- k0d0minio/berceo#27 (`main takes uat`) merged `cab674d`; `uat` deleted from both rulesets and
  from the remote; `preview/uat` gone.
- **The database finding (D41).** The first shape — a named Neon branch `uat` with hand-set
  strings on the environment — sent every UAT build to **production**: the production
  database's Preview Deployment Action overrode the environment's variables and bound the
  deployments to Neon `main` (added their URLs to production's Auth trusted origins), and
  `0001_comptes` reached production at 13:42, ahead of the batch's promotion. Harmless there
  (additive; the holding page reads no database; zero rows everywhere) and left in place
  (forward-only); the promotion's migrate will find nothing to do. Ticking `uat` on the
  production database handed UAT production's string instead. The fix, proven: step 3 above —
  `uat-berceo` (`dawn-scene-70949411`) on `uat` + Preview with preview branching, production's
  `berceo` (`tiny-cell-08223046`) on Production only. UAT build `dpl_Bj7r…` migrated
  `uat-berceo`; probe k0d0minio/berceo#28 got `preview/claude/preview-db-probe` inside
  `uat-berceo` (deleted by hand after); production untouched. The Neon branch `uat` in
  production's project was deleted.
- Left: step 9 (founders' sign-off — also blocked on the `uat.berceo.be` CNAME, which the
  Berceo team owns; triage stub `uat-address-dns` in berceo); berceo's `project.json` still names
  production's project for previews and runs until `uat-database-resource`.

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
the **agorasim** half of stub 3 of the `one-branch-two-targets` epic: read the breakdown, this
stub (berceo's section is the worked example — follow the checklist as amended there), and
decisions D39 and D41 in `.icm/project.md`. Walk the ordered checklist with Jamie: **his** steps
are Vercel, Neon and GitHub settings — list each, wait for his word that it is done, read it back
through the API, never perform it. **Yours** are the sync PR, the baseline Release, the
`main takes uat` PR (he merges both), the read-backs and the probe PR. Auto-assign must be off
and the two-database Storage setup read back before anything merges. Commit each client repo
immediately (the `projects/` tree is shared with a sweeper) and leave every checkout on `main`.
Then step 10 and the rollout note's agorasim section.
