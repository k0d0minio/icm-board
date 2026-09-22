# sell — from a name to a signed agreement

*Layer 1 for this workspace. Grammar:
[`_system/contracts/WORKSPACES.md`](../../_system/contracts/WORKSPACES.md). Runs once per
**engagement**: a client is one folder in [`../deals/`](../deals/), an engagement one
folder inside it, advanced stage by stage by Jamie via `/client <name>` — nothing advances
itself. Rewritten 2026-09-22 (decisions D24–D26); unproven until the first deal walks it.*

**Where it runs:** from any session that has icm-board in view — the knowledge layer is
here — cloud or local. No stage in this workspace needs the client repo on disk.

**The rung is read, never written.** Neon (via the admin dashboard) holds where the
relationship stands; a stage that needs the rung reads it from the dashboard and writes
nothing down about it. The deal folder holds the words and the documents
(one home per fact, D24).

## Stages

| Stage | Job | Ends with |
|---|---|---|
| [`stages/01_intake/`](stages/01_intake/CONTEXT.md) | Qualify; draft the reply that asks for the call | Jamie sends; rung set |
| [`stages/02_look/`](stages/02_look/CONTEXT.md) | The free look, after the first call | `02-look.md` edited and sent |
| [`stages/03_quote/`](stages/03_quote/CONTEXT.md) | Scope · tiers · shapes · numbers | scope, tiers and numbers approved |
| [`stages/04_proposal/`](stages/04_proposal/CONTEXT.md) | The document | `04-proposal.docx` in Drive, sent |
| [`stages/05_agreement/`](stages/05_agreement/CONTEXT.md) | The paper | signed via Google eSignature; the repo created |

Stage is positional: the highest `NN-` artefact in the live engagement folder is where
the deal stands; the next stage is the one after it. A deal may exit at any stage: rung
`lost` in the dashboard, the engagement row's `ended`/`outcome` filled in `DEAL.md`, the
folder stays. A signed engagement leaves this workspace — the next stage is
[`../start/`](../start/CONTEXT.md) `06_onboarding`.

## References (Layer 3)

| File | Holds |
|---|---|
| [references/qualification.md](references/qualification.md) | The take/decline/not-yet criteria; the intake form answers are the first evidence |
| [references/target-profile.md](references/target-profile.md) | Who we want more of, in three registers |
| [references/outreach.md](references/outreach.md) | The outbound playbook + message shapes |
| [references/call-crib.md](references/call-crib.md) | The first call: 20–30 minutes, four beats, no number in the room |
| [references/look-template.md](references/look-template.md) | The free look's four sections and the sort vocabulary |
| [references/discovery-questions.md](references/discovery-questions.md) | The 52-question bank — the diagnostic's instrument and the crib's source |
| [references/discovery-interview.md](references/discovery-interview.md) | The diagnostic's full interview arc |
| [references/diagnostic-report-template.md](references/diagnostic-report-template.md) | The paid diagnostic's report shape |
| [references/proposal-template.md](references/proposal-template.md) | The proposal's shape (markdown → DOCX) |
| [references/agreement-template.en.md](references/agreement-template.en.md) · [.fr](references/agreement-template.fr.md) · [.pt](references/agreement-template.pt.md) | The agreement's shape, one per language |
| [references/forms/](references/forms/) | The questionnaires the dashboard's Forms card sends: `intake-diagnostic`, `onboarding`, `content-and-brand` |

Shared Layer 3: [`_system/knowledge/`](../../_system/knowledge/) (positioning · services ·
pricing · voice · terms · stack) and [CLIENTS.md](../../_system/contracts/CLIENTS.md).

## Inbound and outbound, one front door

An inbound lead (the portfolio's `/start` form, the contact form, a referral — a Neon row
already exists) and an outbound prospect (chosen from
[target-profile](references/target-profile.md)) both enter at `01_intake`. The only
difference: outbound's first artefact is the outreach message, and the Neon row is created
by hand when they answer. A returning client gets a new engagement folder, never a new
client folder ([`deals/README.md`](../deals/README.md)).
