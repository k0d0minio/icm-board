# start — from "yes" to a running project

*Layer 1 for this workspace. Grammar:
[`_system/contracts/WORKSPACES.md`](../../_system/contracts/WORKSPACES.md). Runs once per
won deal, continuing the same folder in [`../deals/`](../deals/) that
[`sell/`](../sell/CONTEXT.md) opened — stages 05–07 of one story.*

The workspace walks the `client` rung's obligations: CLIENTS.md calls it "walk
ConvertFlow until the conversion gaps clear" — delivery repo, deal terms, Stripe
customer. These three stages are that walk, plus the handover into the delivery machine.

## Stages

| Stage | Job | Ends with |
|---|---|---|
| [`stages/05_onboarding/`](stages/05_onboarding/CONTEXT.md) | Collect what delivery needs — answers, access, confirmed terms | onboarding record complete · deposit invoiced |
| [`stages/06_repo/`](stages/06_repo/CONTEXT.md) | The delivery repo exists and carries the baseline | repo created via dashboard · prefix registered |
| [`stages/07_kickoff/`](stages/07_kickoff/CONTEXT.md) | Hand over to the delivery machine | `/project` first run done · first tickets cut |

When `07_kickoff` closes, this workspace is done with the client forever — everything
after lives in [`deliver/`](../deliver/CONTEXT.md) and the client's own repo.

## References (Layer 3)

| File | Holds |
|---|---|
| [references/onboarding-checklist.md](references/onboarding-checklist.md) | What is collected, confirmed and invoiced before work starts |
| [references/kickoff-checklist.md](references/kickoff-checklist.md) | The conversion gaps + handover steps, in order |

Shared Layer 3: [`_system/knowledge/`](../../_system/knowledge/) (terms · stack) ·
[CLIENTS.md](../../_system/contracts/CLIENTS.md) (the flags: `work_started_at`,
`github_repo`, `stripe_customer_id`) · [TICKETS.md](../../_system/contracts/TICKETS.md)
(what kickoff's findings become).
