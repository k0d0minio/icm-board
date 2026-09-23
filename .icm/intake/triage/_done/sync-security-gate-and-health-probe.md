# Stub: Sync security-check.sh and health-check.sh into the pipeline repos

- lane: chore
- found-by: security-gate session · 2026-09-23
- priority: P2

## Problem

`_system/template/icm-pipeline/scripts/health-check.sh` (Release step 9a, one bounded read of
production — D30) plus the contract, `env-check.sh` and `lib/project.sh` edits that carry it
land in the template only, beside D29's batch (`security-check.sh`, the three seeded skills,
`db-branch.sh`, `run-pack.sh`, `list-skills.sh`) and D27's `retrospective.sh`. Every pipeline
repo reports them as missing (and its contracts as drift) until `icm-sync.sh --apply <repo>`
runs, and `health-check.sh` reads a `health_endpoint` from the project-owned
`.icm/project.json` that no repo has filled yet — `/setup` asks for it. The D22 additions
were verified on sustentus only and never rolled out either — one sync carries all of it.

## Proposed change

Per repo, human-invoked, on the repo's own `main` (estate fan-out): `icm-sync.sh --dry-run`
then `--apply`, set `health_endpoint` (top-level, or per project under `deploy.projects[]`)
in the repo's `.icm/project.json`, run its `env-check.sh` and `setup.sh --report`, commit.
remi-ai and sustentus first; the rest as `/icm-check` lists them.

Progress — 2026-09-23: **remi-ai done** (template `e5c30ae`, 62 T files, `report.sh` seeded,
`notify.sh` removed, Slack mapped by name for announce + alert, deploy block for the six
`remi21` projects, health endpoints on the two custom domains, committed straight to its
`main`). Its `/setup` reads `GAPS 1` — the missed close-out of run `patient-home-today`, a fault
of that Release, not of the sync. **berceo done** (k0d0minio/berceo#15 → #17, endpoint `www.berceo.be`) and **agorasim done** (k0d0minio/agorasim#112 → #113, endpoint `agorasim.pt`) in their own PRs; all three re-synced 2026-09-23 with the D33 template-change guard. **sustentus done** (sustentus/sustentus#1139, merged 2026-09-23; the stamp refreshed to icm-board main `452fc4d` and the five baseline files seeded in sustentus/sustentus#1140 — template `03a20eb`, the D34 branch: 74 T files, `report.sh` seeded and wired into its own `release.yaml` for announce + alert on Slack, the deploy block for the eight `sustentus` Vercel projects, its 92 MongoDB migrations in the epoch form, the canonical router and `/setup`; the token NAME, the production URLs and the health endpoint left to `/setup` there). **vinecliff done** (k0d0minio/vinecliff#17, merged 2026-09-23 — template `b618802`, 74 T files, from the retired intake shape: deploy block for `vinecliff` on kodominio, endpoint `vinecliff.jamienisbet.com`, Neon `broad-lake-67509282` with run branches, previews still on production's database, parked with three other findings as vinecliff triage stubs). **jamienisbet done** (`a1c2272` on its main, endpoints on its three sites). **serviflow** carries both on its adoption branch — they land with k0d0minio/serviflow#91. **Closed 2026-09-23:** every adopted repo (it carries `.icm/MANIFEST`) has the gate and the probe; the other twenty have never been synced and, on Jamie's word, are not flagged for either — `icm-check.sh` stops reporting the pipeline for an unadopted repo (k0d0minio/icm-board#59). An empty `health_endpoint` is fine (sustentus's is left to its `/setup`).

## Prompt

In the icm-board repo (`~/Apps`), roll the security gate and health probe out to the
pipeline repos. Read `.icm/intake/triage/sync-security-gate-and-health-probe.md` and
`_system/contracts/PIPELINE.md` § Scripts for context. For each pipeline repo under
`projects/` (remi-ai first, then sustentus, then the ones `/icm-check` lists as carrying the
router): `_system/scripts/icm-sync.sh --dry-run projects/<repo>`, read the file list, then
`--apply`; ask Jamie for the repo's health endpoint URL(s) and write them into that repo's
`.icm/project.json` (`health_endpoint`, or per project in `deploy.projects[]`); run the
repo's `.icm/scripts/env-check.sh` and `setup.sh --report`; commit straight to the repo's
`main` with a message naming the sync. Never run the repo's build, lint or tests. Move this
stub to triage's `_done/` in a ticket-only commit to icm-board's main when the last repo is
done.
