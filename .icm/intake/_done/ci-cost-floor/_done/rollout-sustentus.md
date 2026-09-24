# Stub: sustentus takes the cost floor — advisory Quality, the chores and the smoke walk out of CI

- feature-slug: rollout-sustentus
- epic: ci-cost-floor
- priority: P0
- size: M
- depends-on: template-contract
- sequence: 2 of 7
- sources: D43 · `.icm/docs/2026-09-24-github-actions-audit.md` (sustentus section) · the
  repo's `.github/workflows/` as of 2026-09-24

## Problem

The org pool's spend: `Preview smoke` started 277 runs in a month (one per commit status, ~16 a
push; the guard jobs that skipped were free, every resolve that ran was a minute, and a walk is
up to 100), `Quality Project` ran on every draft push and on `main`, `Database migrations` and
`Database audit` ran per PR, `Pipeline` ran on every `.icm/` push.

## Proposed change

One PR on `claude/ci-cost-floor`:

- `quality.yaml` → job `Quality (advisory)`, `ready_for_review`/`synchronize`/`reopened` with
  the draft guard, `paths-ignore` `.icm/**` + markdown + `.github/**`, no `push`, the one turbo
  pass (format · lint · typecheck · test) — the paths-filter and verdict-carry machinery goes
  with the requirement that needed it.
- `pipeline.yaml`, `preview-smoke.yaml`, `.github/scripts/preview-smoke.mjs`,
  `.github/scripts/smoke-evidence.mjs` removed. `apps/e2e` stays: the walk is the operator's.
- `db-migrate.yaml`: the preview job on `ready_for_review`/`synchronize`/`reopened` only.
- `db-audit.yaml`: nightly + dispatch; the per-PR trigger goes.
- `.icm/project.json`: `required_checks: []`, `smoke_check` removed.
- `.icm/_shared/project-rules.md` → The factory rewritten; the T files synced to the template.

## Operator

1. Ruleset on `main`: replace the required check `Quality Project` with the status
   `Vercel – web` (or none) **before** merging the PR — a required check that never reports
   hangs the merge.
2. The smoke walk at Ready-to-merge: `E2E_BASE_URL=<the web preview URL ci-status.sh printed>
   pnpm e2e` (Clerk values from the `preview` environment in the shell).

## Acceptance

- [ ] A draft push starts no run; the ready flip starts `Quality (advisory)` and the migrate job.
- [ ] A merge to `main` starts `Database migrations` (production) and `Release` only.
- [ ] `ci-status.sh` on a ready PR settles on `Vercel – web` with the advisory job listed.

## Prompt

Read `.icm/intake/ci-cost-floor/rollout-sustentus.md` and `.icm/_shared/ci.md` → the cost floor.
Open the PR described; do not touch the ruleset — list it under Operator in the stop report.
