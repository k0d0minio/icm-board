# Stub: berceo takes the cost floor — advisory CI, ready heads only, no push

- feature-slug: rollout-berceo
- epic: ci-cost-floor
- priority: P1
- size: XS
- depends-on: template-contract
- sequence: 6 of 7
- sources: D43 · `.icm/docs/2026-09-24-github-actions-audit.md` (berceo section)

## Problem

Public, already Vercel-gated (the ruleset requires `Vercel` only) — the closest repo to the
floor. `CI` still runs on every draft push and on `main`.

## Proposed change

One PR on `claude/ci-cost-floor`: `ci.yml` → job `Quality (advisory)`, ready heads only,
`paths-ignore`, no `push`; `.icm/project.json` `required_checks: []`;
`_shared/project-rules.md` → The factory rewritten; the T files synced. Nothing to change on
the ruleset.

## Acceptance

- [ ] A draft push starts no run; the ready flip starts `Quality (advisory)` only.

## Prompt

Read `.icm/intake/ci-cost-floor/rollout-berceo.md` and `.icm/_shared/ci.md` → the cost floor.
Open the PR described.
