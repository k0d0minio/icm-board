# Stub: The template speaks one branch and two targets — promote.sh, the release workflow, every script on main

- feature-slug: template-two-targets
- epic: one-branch-two-targets
- priority: P1
- size: XL
- depends-on: none
- sequence: 1 of 5
- sources: D39 (`.icm/project.md`) · the dependency map in D39's log row (file:line for every
  UAT read) · Vercel docs: *Promoting Deployments*, *Environments*, *Deploying from CLI* (`vercel
  deploy --target`, `vercel promote`), REST `POST /v10/projects/{id}/promote/{deploymentId}`,
  `GET /v9/projects/{id}/custom-environments` (`accountLimit.total`)

## Problem

The template implements D31/D32(2)/D38: a UAT *branch*, a batch file, a promotion PR and a
`sync`; every script, stage, lane and contract branches on `pipeline_base_branch`. D39 replaces
the branch with a deployment target and the promotion PR with a published Release. Nothing in the
template speaks to Vercel's promote API or reads a Release as the production pointer today.

## Proposed change

**Remove (clean cut, D39 §9).** `uat/CONTEXT.md`, `scripts/promote-uat.sh`, the `.icm/uat/`
folder and `batch.json` everywhere they are written (`close-out.sh` step 3b, `setup.sh`,
`promote-uat.sh`); `pipeline_base_branch`, `uat_branch`, `neon_uat_branch`'s
`preview/<uat.branch>` fallback and the `promote` lane in `lib/project.sh`; `uat.branch` and
`type:promote` from `project.json`, `labels.yaml`, `setup.sh`. MANIFEST: the two `T` lines go,
two come in (below).

**`lib/project.sh`.** `uat_declared` (target and url non-empty), `uat_target`, `uat_url`;
`neon_uat_branch` = `database.neon.uat_branch`, required when UAT is declared (`mongo_uat_database`
likewise from a declared name). Callers of `pipeline_base_branch` — `new-run.sh:112`,
`check-migrations.sh:115`, `db-branch.sh:256`, `client-status.sh:76` — read `main`. `new-run.sh`
drops the `origin/main` bring-in, the `batch.json` conflict rule and the "not cut from UAT"
warning.

**`scripts/promote.sh` (T)** — `init`: the operator's checklist, never performed (custom
environment `<target>` on the project; Auto-assign Custom Production Domains off; the domain
attached to the environment; the Neon `uat` branch created from production and its connection
strings set on the environment; branch tracking `main` or the deploy workflow; `contents: write`
and the Vercel token as Actions secrets); `status`: last published Release, the batch
(`git log <release>..origin/main` as stubs and PRs), the staged production deployment for
`origin/main` HEAD, the UAT deployment, any open draft; `approve --by <who> [--note] [--sha]`:
drafts a Release (`gh release create --draft`) at the SHA with the body template (who, when, the
note, `announce: client|internal|none`, the batch); refuses when a draft exists or the SHA is
not on `origin/main`; **never publishes, never promotes.** Tag scheme: decide once with
`report.sh`'s `release/<date>-<slug>` — the promotion Release *is* the release; `report.sh
announce` on a `release: published` run must edit or reuse that Release, not create a second
one (idempotent by tag today; keep that).

**`_shared/promotion.md` (T)** — the contract: the two targets, the batch, the sign-off, the
publish, what the workflow does, hotfix and dark merges (D39 §7), the operator's acts, the
proofs. Replaces `uat/CONTEXT.md`; `github.md` regime 4 and `ci.md`'s UAT paragraph point here.

**`release.yaml` (reference)** — triggers `pull_request: closed`, `release: published`,
`workflow_dispatch`. On a merge: announce only when UAT is undeclared (read `project.json` on
`main`); on a UAT repo record nothing (the run's Release step writes `announce: deferred to
promotion`). On `release: published`: (a) call the migration (the reference `db-migrate.yml`
becomes `workflow_call` + `workflow_dispatch`, `push: main` only for repos without UAT — one
reference with a job-level guard, or two variants; decide and document), (b) find the production
deployment for `release.target_commitish`'s SHA (`GET /v6/deployments?projectId&target=production&sha=<full>`),
promote it (`POST /v10/projects/{id}/promote/{deploymentId}`); Current already → no-op; Staged →
poll `promote status` until Current; missing → fail before anything else, (c)
`deploy-status.sh --sha` once, (d) `report.sh announce` unless the body says `announce: none`;
on failure `report.sh alert`. Concurrency group `promote`, never cancel-in-progress.

**Reference `uat-deploy.yaml`** (seeded once by `/setup`, only when branch tracking is refused):
on push to `main`, `vercel pull --environment=<target> && vercel build && vercel deploy --prebuilt
--target=<target>`, token from the repo's declared secret name.

**Scripts.** `deploy-status.sh --uat`: the custom environment's deployment for the SHA (filter
by the environment — prove which field the v6 list exposes); `client-status.sh`: *live* /
*on UAT, awaiting your word* / *in progress* / *queued* from `origin/main` and `gh release list`
(published, not draft, not prerelease); `db-env.sh`: `init` lists the named branch and its
variables on the environment, `status` shows it, `reset-uat` unchanged, MongoDB the same;
`setup.sh`: `uat.branch` present → FAIL "the branch model is retired (D39)"; `target`+`url` both
or neither; with a token, `GET custom-environments` → the slug exists and `accountLimit.total ≥ 1`,
else FAIL "UAT requires a Pro team"; `batch.json` present → FAIL (remove by hand);
`lib/neon.sh`/`lib/mongo.mjs` refuse the declared UAT name on every delete; `neon-cleanup.yaml`,
`mongodb-cleanup.yaml` drop the `head_ref == uat.branch` skip.

**Words.** `_shared/github.md` (regime 1: ticket commits straight to `main`, no `--admin`; regime
4: the Release), `_shared/ci.md`, `_shared/stage-preamble.md:64`, `_shared/template-change.md`,
`intake/CONTEXT.md`, `stages/01–04`, `lanes/*` (six), `skills/database-migration/SKILL.md`,
`skills/pipeline/SKILL.md` (`uat …` → `promote …`, no `sync`), `skills/setup/SKILL.md` (the UAT
question: target slug + address; run `promote.sh init`), template `README.md`, `icm/CONTEXT.md`,
`icm/intake/README.md`; `_system/contracts/PIPELINE.md` (§§ tree, D31/D38 rules, script table).
Template copies of `pr-conventions`, `ticket-craft`, `wrap-reminder.sh` are stub 2's (both
copies stay byte-identical).

**Prove on a scratch fixture** (bare origin + a throwaway GitHub repo for `gh release`):
`approve` drafts and refuses a second draft; `status` computes the batch from the last published
release; `client-status.sh` output for no-UAT is byte-identical to today's; `release.yaml`'s job
conditions evaluated from the text; `setup.sh` fails a `uat.branch` repo and a `batch.json` repo.
The Vercel promote itself is stub 3's proof.

## Acceptance criteria (rough)

- [ ] `grep -rn 'uat.branch\|pipeline_base_branch\|batch.json\|promote-uat\|type:promote' _system/template` is empty
- [ ] MANIFEST: `T _shared/promotion.md`, `T scripts/promote.sh`; the two old lines gone
- [ ] `release.yaml` promotes on `release: published`, migrates first, announces last; PR-merge announce only without UAT
- [ ] `setup.sh` refuses a branch, a `batch.json`, and a non-Pro team
- [ ] Fixture proofs above recorded in the PR; CI shellcheck green
- [ ] `PIPELINE.md` carries D39 once; every other file points there

## Prompt

In icm-board (`~/Apps`), carry out stub 1 of the `one-branch-two-targets` epic: read
`.icm/intake/one-branch-two-targets/breakdown.md`, this stub, and decision D39 in
`.icm/project.md`. Rework `_system/template/icm-pipeline/` and the reference workflows so the
pipeline has one long-lived branch (`main`), UAT as a Vercel custom environment declared by
`uat: {target, url}`, production as a staged deployment promoted by the release workflow when the
operator publishes the Release `promote.sh approve` drafted. Delete the branch model — do not
keep it behind a flag. Prove on a scratch fixture; never touch a client repo or any Vercel
setting. Ship as one PR on a `claude/` branch; CI is the verdict.
