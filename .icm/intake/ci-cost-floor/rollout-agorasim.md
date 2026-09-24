# Stub: agorasim takes the cost floor — one advisory job, no build, no chores

- feature-slug: rollout-agorasim
- epic: ci-cost-floor
- priority: P0
- size: S
- depends-on: template-contract
- sequence: 3 of 7
- sources: D43 · `.icm/docs/2026-09-24-github-actions-audit.md` (agorasim section)

## Problem

The personal pool: `Gates` 129 runs, `Pipeline` 105, `CI` 137 — each `Gates`/`Pipeline` run a
billed minute for seconds of work, each `CI` run a `next build` Vercel had already done, and a
second full run on every push to `main`.

## Proposed change

One PR on `claude/ci-cost-floor`: `ci.yml` → job `Quality (advisory)` (lint · typecheck · test;
no build), ready heads only, `paths-ignore`, no `push`; `gates.yaml` and `pipeline.yaml`
removed; `.icm/project.json` `required_checks: []`; `_shared/project-rules.md` → The factory
rewritten; the T files synced. No ruleset exists (private on GitHub Free) — nothing to change.

## Acceptance

- [ ] A draft push starts no run; the ready flip starts `Quality (advisory)` only.
- [ ] A merge to `main` starts `Release`/`DB migrate` on their own triggers and nothing else.

## Prompt

Read `.icm/intake/ci-cost-floor/rollout-agorasim.md` and `.icm/_shared/ci.md` → the cost floor.
Open the PR described.
