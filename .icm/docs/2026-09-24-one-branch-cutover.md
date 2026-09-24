# One branch, two targets — the cutover of berceo and agorasim (D39, D41)

The record of `one-branch-two-targets/cutover-agorasim-berceo`: the SHAs, the choices, what Vercel
refused or did differently from the plan, and what is proven. The checklist itself lives in the
stub; this is what happened when it ran.

## berceo — 2026-09-24

### Before

| | |
|---|---|
| `origin/main` | `b7baccef` — what production served (`dpl_6fdLgp…`) |
| `origin/uat` | `35971814`, 5 ahead of `main`, 0 behind |
| Batch | `socle-design-system` (#21), `comptes-neon-auth` (#22), `vitrine-publique` (#25) — unsigned |
| Releases | none |
| Neon | project `tiny-cell-08223046`: `main` (production), `preview/uat` |

### Steps

| Step | Who | Result |
|---|---|---|
| 0 Freeze | session | `promote-uat.sh status` clean, no open PR |
| 1 Auto-assign off | Jamie | read back `autoAssignCustomDomains: false` |
| 2 Custom environment `uat` | Jamie | `env_nMM6sr5qRp8yMDCgBwU6YXX2JUf1`; `uat.berceo.be` attached (`gitBranch: null`) |
| 3 UAT database | Jamie | first as a Neon branch `uat` with hand-set strings — **failed**, see below; then `uat-berceo` (`dawn-scene-70949411`) per D41 |
| 4 Branch tracking `main` on `uat` | Jamie | **accepted** (`branchMatcher: equals main`) — no `uat-deploy.yaml` |
| 5 Sync PR | session | k0d0minio/berceo#26 → `5916543`: Staged production build, UAT build, `Migrate production` skipped by the gate |
| 6a Baseline | session (Jamie's choice: at the sync merge) | `release/2026-09-24-promote-5916543`: stage → migrate (`0000` onto a never-migrated production) → promote (HTTP 201, `dpl_5gKNQ…` Current) → deploy-status READY; announce none |
| 6b `main takes uat` | session | k0d0minio/berceo#27 → `cab674d`; conflicts: `batch.json` deleted, `project-rules.md` merged |
| 7 Branch `uat` gone | Jamie | removed from both rulesets and from the remote; `preview/uat` deleted |
| 8 Read-back | session | `promote.sh status`: batch = the 3 stubs since the baseline; `client-status.sh`: 3 on UAT; stubs in `plateforme-v1/_done`; production Current `5916543`, `cab674d` Staged |
| 9 First real promotion | Jamie | **open** — the founders' sign-off; `uat.berceo.be` does not resolve until the Berceo team adds the CNAME (triage `uat-address-dns` in berceo) |

### Proven live (fixture-only before)

- `POST /v10/projects/{id}/promote/{deploymentId}` from `release.yaml` and the poll on
  `targets.production.id` (`GET /v9/projects/{id}` carries it).
- `deploy-status.sh --uat`'s match: the v6 deployment list exposes `customEnvironment.slug`
  (`target` is `null` for a custom-environment deployment).
- The `db-migrate.yml` gate: push on a UAT repo → `Migrate production` skipped; `workflow_call`
  from `release.yaml` → migrates.
- A `release` workflow runs from the file at the tagged commit — so a baseline at a pre-sync SHA
  would never run it. The stub now puts the baseline at the sync merge.

### The UAT database (D41)

The checklist's first shape — Neon branch `uat` in production's project, its strings set by hand
on the custom environment, the integration not connected to `uat` — sent every UAT build to
**production**:

- The production database, connected to Preview with preview branching, ran its Preview
  Deployment Action on each UAT deployment (the deployment's `integrations` phase took 2–3 s,
  like a PR preview's; a production build's takes 0 s) and overrode the environment's
  variables. Its URLs appeared on production's Neon Auth trusted origins; the Neon branch `uat`
  was never connected to (0 s active).
- `0001_comptes` reached production at 13:42, ahead of the batch's promotion. Left in place:
  additive, forward-only, the holding page reads no database, zero rows in `users`,
  `user_consents` and `neon_auth.user`. The promotion's migrate step will find nothing to do.

The configurations, in the order they ran live with Jamie:

| Configuration | UAT build bound to |
|---|---|
| Production database on Production + Preview; hand-set strings on `uat` | production (Preview Deployment Action fallback) |
| Production database also ticked on `uat` | production (the database's Preview secret, written into `uat`, hand-set values replaced) |
| Second database `uat-berceo` on `uat`; production database still on Preview | production (the fallback again, overriding `uat-berceo`'s variables) |
| **`uat-berceo` on `uat` + Preview + Development with preview branching; production database on Production only** | **`uat-berceo`** — UAT build `dpl_Bj7r…` migrated it; `integrations` 0 s |

The last is D41. Probe k0d0minio/berceo#28 (an empty commit, closed unmerged) got
`preview/claude/preview-db-probe` inside `uat-berceo`; production's `main` did not move and its
trusted origins stayed `www.berceo.be`, `www.berceo.eu`. The orphaned preview branch was
deleted by hand — `neon-cleanup.yaml` still reads production's project id from `project.json`
(stub `uat-database-resource`). Neon Auth on `uat-berceo` set to production's settings by Jamie.
The Neon branch `uat` in production's project was deleted.

### Left on berceo

- Step 9, the first real promotion.
- `project.json` / `project-rules.md` still describe the named-branch database — changed by the
  sync after `uat-database-resource`, not by hand.
- `uat.berceo.be` CNAME (Berceo team).

## agorasim — 2026-09-24

### Before

| | |
|---|---|
| `origin/main` | `638cd3f` — 1 ahead of `uat` (#126, a knowledge merge `uat` never received) |
| `origin/uat` | `461292b`, 13 ahead of `main` |
| Batch | `admin-quote-builder` (#120), `quote-page-and-deposit-link` (#122), `experiencias-heading-meta` (#123), `day-before-reminder` (#124), `retire-stale-dependency-advisories` (#125), `stale-web-docs-refs` (#127) — unsigned; `batch.json` named only 4 |
| Releases | none — the 2026-09-23 promotion (#118) was a merged PR, never tagged |
| Production | `dpl_DTHUdmt2…`; `agorasim.pt` itself not yet on Vercel (apex at the old host) |
| Neon | production `nameless-sea-98952497` (Postgres 17): `main`, `preview/uat`, `run/quote-page-and-deposit-link` |
| Vercel | custom environment `uat` already created, empty; `uat.agorasim.pt` bound to git branch `uat`; `project.json` named `uat.agorasim.jamienisbet.com` (not on the project) |

### Steps

| Step | Who | Result |
|---|---|---|
| 0 Freeze | session | `promote-uat.sh status`: nothing approved, no promote PR |
| 1 Auto-assign off | Jamie | read back `autoAssignCustomDomains: false` |
| 2 Custom environment `uat` | Jamie | `env_gHlPCyZHI3HCgQWGXkCjdxoY3XcE`; **`uat.agorasim.pt`** attached (`gitBranch: null`) — Jamie's choice; resolves only once a CNAME exists at amenworld |
| 3 UAT database (D41) | Jamie | `uat-agorasim` = `lingering-frog-97017403` on `uat` + Preview, preview branching, active-before-deploy; production's `agorasim` on Production only, no action. Postgres **18** vs production's 17 — kept on Jamie's word (no in-place major upgrade in Neon). No Neon Auth in the app — 3d skipped |
| 3e `uat` variables | Jamie | set by hand; read-back caught two errors, both fixed: `BOOKING_NOTIFICATIONS_EMAILS` (the app reads `BOOKING_NOTIFICATION_EMAILS`) and a Stripe endpoint at `/webhook` (route: `/api/stripe/webhook`). Blob store ticked on `uat` |
| 4 Branch tracking `main` on `uat` | Jamie | **accepted** — no `uat-deploy.yaml` |
| 5 Sync PR | session | k0d0minio/agorasim#128 (icm-board `ca57a11`) → `87aab3e`: Staged `dpl_8Fg4…`, UAT `dpl_HpLv…` migrated `uat-agorasim` (27), `Migrate production` skipped. Actions secret `VERCEL_TOKEN_KODOMINIO` added first |
| 6a Baseline | session drafted, Jamie published | `release/2026-09-24-promote-87aab3e` (announce none): stage (Staged) → migrate (27 applied — no-op) → promote (HTTP 201, `dpl_8Fg4…` Current) → deploy-status READY |
| 5b Two Neon projects | session | k0d0minio/agorasim#129 (icm-board `be13188`, stub 5's per-repo half) → `ebd327d`: `nonprod_project_id`, `uat_branch` dropped |
| 6b `main takes uat` | session | k0d0minio/agorasim#130 → `2e105da`; conflicts: `batch.json` deleted, `project-rules.md` merged |
| 7 Branch `uat` gone | session, on Jamie's word | remote and local deleted (was `461292b`; everything it carried is in `main`); Neon `preview/uat` — Jamie's |
| 8 Read-back | session | below |
| 9 First real promotion | Jamie | **open** — Diogo & Rita's sign-off |
| 10 jamienisbet | — | nothing to drop: the dashboard stub was built (#150) and the board moved back to `main` (#155) |

### Proven live

- **The database, first time right.** Every UAT build's `integrations` phase 0 s; `uat-agorasim` at
  29 migrations (the batch's `0027`–`0028` applied at build), production at 27 and no new branch
  in its project; production's migrator skipped on every push.
- **Previews in the UAT database.** #128–#131 each got `preview/<branch>` inside `uat-agorasim`.
- **Automatic cleanup** (Jamie's ask: "we need a mechanism that deletes automatically"): after #129,
  `neon-cleanup` reads `lingering-frog-97017403` and deleted the previews of #129 and #130
  (merged) and #131 (closed unmerged) — the Actions `NEON_API_KEY` reaches both projects. #128's,
  from before, was deleted by hand.
- **A promotion** — the baseline — through `release.yaml` on a second repo.
- `promote.sh status` after #130: the 6 stubs since the baseline, no draft; all six in `_done` on `main`.

### Found on the way

- **Vercel cancels an empty commit** ("the commit didn't affect this project" —
  `enableAffectedProjectsDeployments`). A commit touching only `.icm/` or `.github/` still builds
  (#129, #131's second commit). `release.yaml` promotes the production deployment of the exact SHA,
  so a skipped `main` commit cannot be promoted — it fails at `stage`, production untouched.
  Unproven: the first direct ticket commit to `main` gets a production deployment.
- `client-status.sh` pairs a spun-out stub with its archived run by slug; where a run took a
  different slug from its stub (`experiencias-heading-and-meta` → `experiencias-heading-meta`, the
  weather-move and a11y fixes) the stub reads *in progress* forever — pre-existing, not the cutover.
- A fresh UAT database has no `admin_users`: the owner is seeded by hand.

### Left on agorasim

- Step 9, the first real promotion — and with it the **announce** path (`report.sh announce --tag`),
  unrun on either repo.
- The `uat.agorasim.pt` CNAME (`uat` → `cname.vercel-dns.com`) at amenworld.
- The UAT owner account (`pnpm db:seed-owner` against `uat-agorasim`).
- Neon `preview/uat` in production's project (Jamie); `run/quote-page-and-deposit-link` there
  expires 2026-10-01 on its own.
