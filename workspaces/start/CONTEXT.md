# start — from a signed agreement to a running project

*Layer 1 for this workspace. Grammar:
[`_system/contracts/WORKSPACES.md`](../../_system/contracts/WORKSPACES.md). Runs once per
signed engagement, continuing the same engagement folder in [`../deals/`](../deals/) that
[`sell/`](../sell/CONTEXT.md) opened — stages 06–07 of one story. Rewritten 2026-09-22
(D24–D26); unproven until the first deal walks it.*

The workspace walks the `active` rung's obligations: CLIENTS.md calls it "walk
ConvertFlow until the conversion gaps clear" — delivery repo, deal terms, Stripe
customer. Two stages: the collecting, and the handover into the delivery machine.
`06_repo` was retired on 2026-09-22 — the repo is created at signature (sell `05`'s gate)
and `07_kickoff` adopts it.

## Stages

| Stage | Job | Needs | Ends with |
|---|---|---|---|
| [`stages/06_onboarding/`](stages/06_onboarding/CONTEXT.md) | Collect what delivery needs — answers, access, the deposit | icm-board in view | every checklist row *received* · deposit paid |
| [`stages/07_kickoff/`](stages/07_kickoff/CONTEXT.md) | Hand over to the delivery machine | **the client repo on disk** (`projects/<repo>`) | `/project` first run done · the snapshots in `.icm/docs/` · flags cleared |

When `07_kickoff` closes, this workspace is done with the engagement — everything after
lives in [`deliver/`](../deliver/CONTEXT.md) and the client's own repo, until that repo's
**handover lane** writes `08-handover.md` back into the engagement folder at the end of
the build.

## References (Layer 3)

| File | Holds |
|---|---|
| [references/onboarding-checklist.md](references/onboarding-checklist.md) | What is collected, confirmed and invoiced before the clock starts |
| [references/kickoff-checklist.md](references/kickoff-checklist.md) | The conversion gaps + the handover steps, in order |
| [`sell/references/forms/`](../sell/references/forms/) | The two onboarding questionnaires the dashboard sends: `onboarding`, `content-and-brand` |

Shared Layer 3: [`_system/knowledge/`](../../_system/knowledge/) (terms · stack) ·
[CLIENTS.md](../../_system/contracts/CLIENTS.md) (the flags: `work_started_at`,
`github_repo`, `stripe_customer_id`, `support_minor`) ·
[TICKETS.md](../../_system/contracts/TICKETS.md) (what kickoff's findings become) ·
[PIPELINE.md](../../_system/contracts/PIPELINE.md) (what `/setup` fills in the repo).
