# sell — from a name to a signed deal

*Layer 1 for this workspace. Grammar:
[`_system/contracts/WORKSPACES.md`](../../_system/contracts/WORKSPACES.md). Runs once per
deal; a deal is one folder in [`../deals/`](../deals/), advanced stage by stage by Jamie
via `/client <name>` — nothing advances itself.*

The workspace walks the open half of the client ladder
([CLIENTS.md](../../_system/contracts/CLIENTS.md)): `new` and `talking`. Neon (via the
admin dashboard) stays authoritative for the rung; the deal folder holds the words and
documents around it.

## Stages

| Stage | Job | Ends with |
|---|---|---|
| [`stages/01_intake/`](stages/01_intake/CONTEXT.md) | Qualify, and open (or decline) the deal | first reply sent · rung `talking` |
| [`stages/02_discovery/`](stages/02_discovery/CONTEXT.md) | Learn enough to scope honestly | discovery notes Jamie has edited |
| [`stages/03_quote/`](stages/03_quote/CONTEXT.md) | Reach a number from the rate card | scope + number Jamie has approved |
| [`stages/04_proposal/`](stages/04_proposal/CONTEXT.md) | The document the lead receives | `04-proposal.pdf` sent by Jamie |

A deal may exit at any stage: rung `lost` in the dashboard, `DEAL.md` says why, the
folder stays. A deal that is **won** leaves this workspace — the next stage is
[`../start/`](../start/CONTEXT.md) `05_onboarding`.

## References (Layer 3)

| File | Holds |
|---|---|
| [references/qualification.md](references/qualification.md) | The yes/no/not-yet criteria for taking a deal on |
| [references/target-profile.md](references/target-profile.md) | Who outbound goes looking for |
| [references/outreach.md](references/outreach.md) | The outbound playbook + message shapes |
| [references/discovery-interview.md](references/discovery-interview.md) | The interview script |
| [references/discovery-questions.md](references/discovery-questions.md) | The question bank — stable IDs, `[BLOCKER]`/`[LAWYER]` tags |
| [references/proposal-template.md](references/proposal-template.md) | The proposal's shape (markdown → PDF) |

Shared Layer 3: [`_system/knowledge/`](../../_system/knowledge/) (services · pricing ·
voice · terms · stack) and [CLIENTS.md](../../_system/contracts/CLIENTS.md).

## Inbound and outbound, one front door

An inbound lead (portfolio form, referral — a Neon row already exists) and an outbound
prospect (chosen from [target-profile](references/target-profile.md)) both enter at
`01_intake`. The only difference: outbound's first artifact is the outreach message and
the Neon row is created by hand when they answer.
