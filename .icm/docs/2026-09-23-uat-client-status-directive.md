# Agent Directive — UAT Batch Preview Environment & Async Client Status Generator (2026-09-23)

*Saved verbatim from the session that implemented it (icm-board, branch
`claude/icm-uat-client-status-e6599f`), with Jamie's framing above the directive as he gave it.
Decision of record: D31 in [`../project.md`](../project.md). The implementation was the template's
`uat/CONTEXT.md`, [`scripts/client-status.sh`](../../_system/template/icm-pipeline/scripts/client-status.sh)
and `scripts/promote-uat.sh` — the first and last retired by D39, replaced by
[`_shared/promotion.md`](../../_system/template/icm-pipeline/_shared/promotion.md) and
[`scripts/promote.sh`](../../_system/template/icm-pipeline/scripts/promote.sh); the contract
[`PIPELINE.md`](../../_system/contracts/PIPELINE.md) carries the rule.*

## Jamie's framing (the constraints that shaped the implementation)

> This feature needs to be set up as optional for the icm pipeline template, only if I
> specifically configure within the /setup command should I be able to get the features and
> functionalities of the UAT environment, this environment needs to be consistent not generated
> per batch, we need a consistent UAT environment in order to allow clients to have a constantly
> available UAT environment for testing. otherwise, the client report should be available at all
> times everywhere in the icm template.

Read as three rules: **optional, and only `/setup` switches it on** (a `uat` block in
`project.json`; nothing seeded filled); **one persistent environment** (a long-lived branch and
one fixed address, never a branch, environment or URL per batch); **the client report is
template-owned and everywhere**, independent of UAT.

Two deviations from the directive's letter, both to honour standing rules: `uat_branch` and
`preview_url` are not duplicated into `batch.json` — `project.json → uat` is their one home (D24)
and `batch.json` holds state; and `promote-uat.sh` opens the promotion PR and **stops** rather than
"triggering the production merge" — no script in the pipeline merges, the operator does, from
GitHub (D11, the agency brief's decision 4). The client is notified through the repo's own
reporting hook when the promotion lands (`sync`, or the release workflow), never by a new channel.

## The directive, as received

```
# Agent Directive: UAT Batch Preview Environment & Async Client Status Generator

## Objective
Implement a UAT batching workflow for client sign-offs and an automated async status generator script. Individual ticket stubs land in a UAT preview environment; clients sign off on the UAT batch as a whole before promotion to production in Stage 04.

---

## 1. Automated Async Client Status Generator (`.icm/scripts/client-status.sh`)
Create `.icm/scripts/client-status.sh` to compile non-technical client progress summaries:
- **Scan Sources**: Inspect `.icm/intake/`, `.icm/runs/`, `.icm/uat/`, and `.icm/runs/_done/`.
- **Output Artifact**: Write `.icm/output/client-status-latest.md` with:
  1. **Delivered to Production**: Recently archived runs in `_done/`.
  2. **Ready in UAT Preview**: Stubs merged into the `uat` branch with live UAT preview URL.
  3. **Currently Building**: Active stubs in `.icm/runs/`.
  4. **Queued Backlog**: Prioritised stubs in `.icm/intake/`.

---

## 2. UAT Batch Sign-Off Workflow & Promotion Gate
1. **UAT Staging Directory**:
   - Add `.icm/uat/batch.json` to track stubs currently deployed to the UAT preview environment:
     {
       "uat_branch": "uat",
       "preview_url": "https://uat.example.com",
       "stubs": ["stub-1-slug", "stub-2-slug"],
       "client_approved": false
     }
2. **Stage 04 Gate Adjustment (`stages/04_release/CONTEXT.md`)**:
   - Ticket stubs target `uat` first upon build completion.
   - Stage 04 blocks final production merge (`main`) until `.icm/uat/batch.json` has `"client_approved": true` recorded via operator sign-off (`AskUserQuestion` or script flag).
   - Add `.icm/scripts/promote-uat.sh` to trigger the production merge and notify the client upon batch approval
```
