# CONTEXT.md — Layer 1: where do I go?

*Task routing for the whole repo. Layer 0 ([`CLAUDE.md`](CLAUDE.md)) says where you are;
this file says where to go; each stage's `CONTEXT.md` says what to do. Grammar:
[`_system/contracts/WORKSPACES.md`](_system/contracts/WORKSPACES.md). Load down only as
far as the task needs.*

## By what Jamie wants to do

| "I want to…" | Enter | Which is |
|---|---|---|
| Deal with a new lead / prospect | `/client <name>` | [`sell/01_intake`](workspaces/sell/stages/01_intake/CONTEXT.md) |
| Prep or digest a discovery conversation | `/client <name>` | [`sell/02_discovery`](workspaces/sell/stages/02_discovery/CONTEXT.md) |
| Put a number on a deal | `/client <name>` | [`sell/03_quote`](workspaces/sell/stages/03_quote/CONTEXT.md) |
| Write / revise the proposal | `/client <name>` | [`sell/04_proposal`](workspaces/sell/stages/04_proposal/CONTEXT.md) |
| Onboard a won client | `/client <name>` | [`start/05_onboarding`](workspaces/start/stages/05_onboarding/CONTEXT.md) |
| Set up their repo | `/client <name>` | [`start/06_repo`](workspaces/start/stages/06_repo/CONTEXT.md) |
| Kick the project off | `/client <name>` | [`start/07_kickoff`](workspaces/start/stages/07_kickoff/CONTEXT.md) |
| Adopt / analyse / ticket a repo | `/project <repo>` | [`deliver/project`](workspaces/deliver/stages/project/CONTEXT.md) |
| Plan the day · wrap the session | `/day [wrap]` | [`deliver/day`](workspaces/deliver/stages/day/CONTEXT.md) |
| Check the estate's structure | `/icm-check` | [`deliver/conformance`](workspaces/deliver/stages/conformance/CONTEXT.md) |

Where a deal already exists, `/client` reads its `DEAL.md` and lands on the right row
itself — the table is for orientation, not dispatch.

## By what a session needs to know

| Question | Layer 3 answer |
|---|---|
| What do we sell, at what price, on what terms | [`_system/knowledge/`](_system/knowledge/README.md) |
| How is a workspace/stage/deal structured | [`WORKSPACES.md`](_system/contracts/WORKSPACES.md) · [`deals/README.md`](workspaces/deals/README.md) |
| Ticket format, estate-wide | [`TICKETS.md`](_system/contracts/TICKETS.md) |
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
  `— not yet established` gaps. Never invent their content mid-task.
