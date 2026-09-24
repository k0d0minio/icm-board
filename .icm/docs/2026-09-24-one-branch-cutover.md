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

## agorasim

*(written by the agorasim session)*
