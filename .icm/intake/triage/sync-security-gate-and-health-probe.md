# Stub: Sync security-check.sh and health-check.sh into the pipeline repos

- lane: chore
- found-by: security-gate session · 2026-09-23
- priority: P2

## Problem

Two new template-owned scripts — `_system/template/icm-pipeline/scripts/security-check.sh`
(Release stop class 2, measured) and `health-check.sh` (Release step 9a, one bounded read of
production) — plus the contract, `env-check.sh` and `lib/project.sh` edits that carry them
land in the template only. Every pipeline repo reports them as missing (and its contracts as
drift) until `icm-sync.sh --apply <repo>` runs, and `health-check.sh` reads a
`health_endpoint` from the project-owned `.icm/project.json` that no repo has filled yet.
The D22 additions (`select-model.sh`, `check-migrations.sh`, `process-raw.sh`) were verified
on sustentus only and never rolled out either — the same sync carries both.

## Proposed change

Per repo, human-invoked, on the repo's own `main` (estate fan-out): `icm-sync.sh --dry-run`
then `--apply`, set `health_endpoint` (top-level, or per project under `deploy.projects[]`)
in the repo's `.icm/project.json`, run its `env-check.sh` and `setup.sh --report`, commit.
remi-ai and sustentus first; the rest as `/icm-check` lists them.

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
