# CONTEXT.md — Layer 1: where do I go?

*Task routing for the whole repo. Layer 0 ([`AGENTS.md`](AGENTS.md)) says where you are;
this file says where to go; each stage's `CONTEXT.md` says what to do. Grammar:
[`_system/contracts/WORKSPACES.md`](_system/contracts/WORKSPACES.md). Load down only as
far as the task needs.*

## By what Jamie wants to do

| "I want to…" | Enter | Which is |
|---|---|---|
| Deal with a new lead / prospect | `/client <name>` | [`sell/01_intake`](workspaces/sell/stages/01_intake/CONTEXT.md) |
| Write the free look after the first call | `/client <name>` | [`sell/02_look`](workspaces/sell/stages/02_look/CONTEXT.md) |
| Put a number on a deal — tiers, shape | `/client <name>` | [`sell/03_quote`](workspaces/sell/stages/03_quote/CONTEXT.md) |
| Write / revise the proposal, render it, place it in Drive | `/client <name>` | [`sell/04_proposal`](workspaces/sell/stages/04_proposal/CONTEXT.md) |
| Write the agreement for eSignature | `/client <name>` | [`sell/05_agreement`](workspaces/sell/stages/05_agreement/CONTEXT.md) |
| Onboard a signed client | `/client <name>` | [`start/06_onboarding`](workspaces/start/stages/06_onboarding/CONTEXT.md) |
| Kick the project off — the repo, the snapshots, `/setup`, `/project` | `/client <name>` | [`start/07_kickoff`](workspaces/start/stages/07_kickoff/CONTEXT.md) |
| Adopt / analyse / ticket a repo | `/project <repo>` | [`deliver/project`](workspaces/deliver/stages/project/CONTEXT.md) |
| Plan the day · wrap the session | `/day [wrap]` | [`deliver/day`](workspaces/deliver/stages/day/CONTEXT.md) |
| Check the estate's structure | `/icm-check` | [`deliver/conformance`](workspaces/deliver/stages/conformance/CONTEXT.md) |
| Change the pipeline template — including a **template change request** a client repo's session handed back | a PR on a `claude/` branch touching `_system/template/`, then `icm-sync.sh --apply` per repo | [`PIPELINE.md` § File-level ownership](_system/contracts/PIPELINE.md) · [`template-change.md`](_system/template/icm-pipeline/_shared/template-change.md) |

Where a deal already exists, `/client` reads its `DEAL.md`, takes the stage from the
highest `NN-` artefact in the live engagement, and lands on the right row itself — the
table is for orientation, not dispatch. Sell runs from any session with icm-board in view;
`07_kickoff` needs the client repo on disk.

## By what a session needs to know

| Question | Layer 3 answer |
|---|---|
| What do we sell, to whom, in which words, at what price, on what terms | [`_system/knowledge/`](_system/knowledge/README.md) |
| How is a workspace/stage/deal structured | [`WORKSPACES.md`](_system/contracts/WORKSPACES.md) · [`deals/README.md`](workspaces/deals/README.md) |
| Ticket format, estate-wide | [`TICKETS.md`](_system/contracts/TICKETS.md) |
| The per-repo pipeline — spine, lanes, gates, the agency layer | [`PIPELINE.md`](_system/contracts/PIPELINE.md) |
| What a project register holds | [`PROJECT.md`](_system/contracts/PROJECT.md) |
| The seven analysis lenses | [`LENSES.md`](_system/contracts/LENSES.md) |
| The client ladder and its flags | [`CLIENTS.md`](_system/contracts/CLIENTS.md) |
| What's broken / undecided estate-wide | [`_system/AUDIT.md`](_system/AUDIT.md) |
| What `--fix` seeds; the canonical assets | [`_system/template/README.md`](_system/template/README.md) |

## Shared resources

- **Scripts** ([`_system/README.md`](_system/README.md) § scripts) — each prints one
  `RESULT:` line; config from the environment, never `.env`.
- **Agents** — `project-lens` and `ticket-scout`, spawned by deliver's stages only.
- **Setup** — [`_system/setup/questionnaire.md`](_system/setup/questionnaire.md) fills
  the knowledge layer; until it runs, knowledge files carry honest
  `— not yet established` gaps (Q22–Q24 are open). Never invent their content mid-task.
- **Deal commits** — `Deal: <client> — <what>` straight to `main`, like `Plan:`/`Wrap:`;
  every other change through a PR on a `claude/` branch.
