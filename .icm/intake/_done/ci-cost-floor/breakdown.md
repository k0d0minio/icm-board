# Breakdown: CI is a cost floor — the deploy is the verdict, one advisory job, chores in-session (D43)

- epic-slug: ci-cost-floor
- sources: Jamie 2026-09-24 — "an issue I'm hitting every now and then is the github action
  minutes running out for the month … vercel already builds the project, so I don't need to
  check if build works in github right? … replace it with calling the scripts within an agent
  session itself, or as an operator instruction at the end of a ticket … a streamlined
  definition of what goes into CI and what doesn't"; two rounds of questions the same session,
  eight answers (D43's row) · the audit `.icm/docs/2026-09-24-github-actions-audit.md`
  (2026-08-25 → 09-24, per-job, every estate repo) · GitHub billing: per job, rounded up to the
  minute, private repositories only; k0d0minio and sustentus are both on Free (2,000 min/month
  each); agorasim and jamienisbet are private on GitHub Free (no rulesets), sustentus private
  in an org (ruleset requires `Quality Project`), remi-ai/berceo public (remi-ai's ruleset
  requires `Format, lint, typecheck`, berceo's requires `Vercel`)

## What I understood

Two pools run dry: Jamie's personal one (agorasim + jamienisbet) and sustentus's org pool. Every
other repo is public and bills nothing — so the shape is chosen for consistency, and the
savings land on three repos. The minutes were not going where it looked. A `next build` in CI
duplicates Vercel; a push to `main` re-runs what the PR just proved; but the bulk on the private
repos was **tiny jobs billed at a full minute each**: the `Gates` and `Pipeline` chore jobs on
every PR edit and every `.icm/` push, the four-job CI matrix on jamienisbet, and on sustentus a
`status`-triggered smoke workflow that starts a run for every one of ~16 commit statuses a push
produces (guard jobs skip — those are free — but every resolve that ran was a minute).

D43 sets one shape for every repo (`_shared/ci.md` → the cost floor): the deploy status is the
verdict and the only thing a ruleset requires; one advisory quality job (lint · typecheck · unit
tests, one job, ready heads only, path-filtered, never on `main`, no build); the pipeline's chores
run in-session (`project-labels.sh`, `validate-*.sh`; gates read from the PR body); a browser
walk in CI only where a client pays; what stays is what needs a secret, a runner or a clock.

## Decisions

Recorded as D43 in `.icm/project.md`. The ones the stubs lean on:

- `required_checks` is empty by default; `smoke_check` is absent unless a client pays.
- The advisory job is **project-owned** (`quality.yaml`, seeded once) — the commands are the
  repo's; the shape (advisory name, ready-only, path filters, no push, no build) is the contract.
- `Pipeline`, `Gates` and the reference `labels.yaml` are retired — `git rm`, never left idle.
- The doctrine "never run the full sweep locally" stands; the changed-files scripts are feedback.
- Rulesets are the operator's: where one names the old check, it is changed to the deploy status
  **before** the PR that renames the job merges, or the merge hangs on a check that never reports.

## Build order

1. `template-contract` — `_shared/ci.md`, the Build/Release contracts, `github.md` → Labels,
   the project-rules stub, `setup.sh`, the two skills, `PIPELINE.md`; `labels.yaml` deleted,
   the reference `quality.yaml` added; D43. **Done in the PR that cut this epic.**
2. `rollout-sustentus` — the biggest org-pool spend: `quality.yaml` advisory + ready-only + no
   push, `pipeline.yaml` and `preview-smoke.yaml` removed, `db-migrate.yaml` ready-only,
   `db-audit.yaml` nightly only, `smoke_check` out of `project.json`, the walk as an operator
   act. Ruleset: `Quality Project` → `Vercel – web`.
3. `rollout-agorasim` — the personal pool: `ci.yml` advisory + ready-only + no build + no
   push; `gates.yaml` + `pipeline.yaml` removed. No ruleset to change.
4. `rollout-jamienisbet` — the personal pool's largest line: the build matrix (three jobs a
   run, Vercel builds all three) dropped, one advisory job, no push. No ruleset to change.
5. `rollout-remi-ai` — public (no minutes) but on the template: `quality.yaml` advisory +
   ready-only + no push; `gates.yaml` + `pipeline.yaml` removed. Ruleset: `Format, lint,
   typecheck` → the deploy statuses.
6. `rollout-berceo` — public, already Vercel-gated: `ci.yml` advisory + ready-only + no push.
7. `estate-sync-d43` — the template files of 1 reach every pipeline repo (`icm-sync.sh --apply`,
   sustentus on Jamie's word); the other public repos with a CI workflow (cafe-jardim,
   collabimmo, courseday, dungeons-dragons, escondidinho) take the shape when next touched —
   they cost nothing today.
