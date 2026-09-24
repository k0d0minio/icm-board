# Stub: remi-ai takes the cost floor — advisory Quality, the chores out of CI, the ruleset re-pointed

- feature-slug: rollout-remi-ai
- epic: ci-cost-floor
- priority: P1
- size: S
- depends-on: template-contract
- sequence: 5 of 7
- sources: D43 · `.icm/docs/2026-09-24-github-actions-audit.md` (remi-ai section)

## Problem

Public, so no minutes — but on the template and carrying the old shape: `Gates` 148 runs,
`Pipeline` 112, `Quality` on every draft push and on `main`, and a ruleset that requires
`Format, lint, typecheck`.

## Proposed change

One PR on `claude/ci-cost-floor`: `quality.yaml` → job `Quality (advisory)`, ready heads only,
`paths-ignore`, no `push`, the migration-order step kept; `gates.yaml` and `pipeline.yaml`
removed; `.icm/project.json` `required_checks: []`; `_shared/project-rules.md` → The factory
rewritten; the T files synced.

## Operator

1. Ruleset on `main`: replace the required check `Format, lint, typecheck` with the six deploy
   statuses (or none) **before** merging the PR.

## Acceptance

- [ ] A draft push starts no run; the ready flip starts `Quality (advisory)` only.

## Prompt

Read `.icm/intake/ci-cost-floor/rollout-remi-ai.md` and `.icm/_shared/ci.md` → the cost floor.
Open the PR described; the ruleset is the operator's.
