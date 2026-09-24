# Stub: jamienisbet takes the cost floor — the build matrix goes, one advisory job, no push

- feature-slug: rollout-jamienisbet
- epic: ci-cost-floor
- priority: P0
- size: S
- depends-on: template-contract
- sequence: 4 of 7
- sources: D43 · `.icm/docs/2026-09-24-github-actions-audit.md` (jamienisbet section)

## Problem

The personal pool's largest line: `CI` ran 320 times in a month with four jobs a run — typecheck
+ lint, then a `next build` of each of three sites Vercel builds anyway — on every draft push
and again on `main`.

## Proposed change

One PR on `claude/ci-cost-floor`: `ci.yml` → one job `Quality (advisory)` (typecheck · lint;
there are no unit tests by design), ready heads only, `paths-ignore`, no `push`; the build
matrix removed; `.icm/project.json` `required_checks: []`; `_shared/project-rules.md` → The
factory rewritten; the T files synced. `db-migrations.yml` unchanged (path-filtered validate on
PRs, production migrate on `main`). No ruleset exists — nothing to change.

## Acceptance

- [ ] A draft push starts no run; a ready push starts one job.
- [ ] A merge to `main` starts `DB migrations` only when `packages/services/**` changed.

## Prompt

Read `.icm/intake/ci-cost-floor/rollout-jamienisbet.md` and `.icm/_shared/ci.md` → the cost
floor. Open the PR described.
