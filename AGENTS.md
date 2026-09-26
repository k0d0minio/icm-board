# AGENTS.md — Layer 0: Repository Identity & Routing

> This is the **first file any agent session reads.** It says what this repo is and where
> to go for a given task. Layer 1 is [`CONTEXT.md`](CONTEXT.md); detail lives in each
> folder's own README or CONTEXT. Keep this short.
>
> `AGENTS.md` is the vendor-neutral filename; [`CLAUDE.md`](CLAUDE.md) is a one-line
> `@AGENTS.md` import so Claude Code loads the same Layer 0.

## What this repo is

**`icm-board`** — the second brain of Jamie Nisbet's business: a software engineer / AI
consultant running ~22 client repos plus his own web estate. This repo holds **no
application code and ships no product.** It holds the whole business as an ICM system
([`_system/contracts/WORKSPACES.md`](_system/contracts/WORKSPACES.md)): the processes
that sell, start and deliver the work; the knowledge those processes cite; the contracts
every repo is measured against; the scripts that measure them; and the canonical Claude
assets seeded across the estate. What's where: [`CONTEXT.md`](CONTEXT.md) maps
`workspaces/`, [`_system/README.md`](_system/README.md) is the control layer, and
[`.icm/`](.icm/) is this repo's own register and backlog. **`projects/`** holds every
repo in the estate, one folder each — separate git repos, **gitignored here**, present
only on Jamie's machine.

### Never build an orchestrator

The folders are the orchestration (decision D3, [`.icm/project.md`](.icm/project.md)):
nothing runs itself, nothing advances a deal or a pipeline, no outbound action ever
leaves a session. This repo *describes and checks*; Jamie drives. Full doctrine:
[`_system/README.md`](_system/README.md) § House doctrine.

## Routing — "if the task is… → go to…"

Full table: [`CONTEXT.md`](CONTEXT.md). The short version:

| The task | Go to |
|---|---|
| A lead, a free look, a quote, a proposal, an agreement, an onboarding, a kickoff — anything about one relationship | **`/client <name>`** → [`workspaces/sell/`](workspaces/sell/CONTEXT.md) · [`workspaces/start/`](workspaces/start/CONTEXT.md) |
| Adopt a repo · work out what to build · cut a sprint's tickets | **`/project <repo>`** |
| Pick today's ≤10 · reconcile the board · end a session | **`/day [wrap]`** |
| Does every repo carry the baseline + canonical assets | **`/icm-check`** |
| What the business sells, charges, sounds like, promises | [`_system/knowledge/`](_system/knowledge/README.md) |
| The specs — tickets, register, lenses, clients, workspace grammar | [`_system/contracts/`](_system/README.md) |
| Estate audit — security, broken config, open decisions | [`_system/AUDIT.md`](_system/AUDIT.md) |
| Plan or track engineering work on **this** repo | tickets in [`.icm/intake/`](.icm/intake/) |
| The websites, the dashboard, the brand, `biz.*` data | `projects/jamienisbet` — its own repo, `CLAUDE.md`, CI |

## Standing rules (do not break these)

- **`projects/` is never tracked here.** The `/projects/` line in `.gitignore` has **no
  exceptions** — never add a negation. Client repos are created by the admin dashboard
  (`createClientRepo`), never by hand; `/client` stage 06 and `/project` adopt them.
- **Deals are tracked; secrets are not.** `workspaces/deals/` is committed (private repo,
  cloud sessions need it) — but never a credential, token, or identity document. One home
  per fact (D24): business *state* stays in Neon/Stripe, the folders hold words and
  documents. **Deal commits go straight to `main` with a `Deal:` prefix** — words, not
  code, the same standing as `Plan:`/`Wrap:`.
- **Tickets live next to the logic they describe.** A ticket about this repo's machinery
  is cut here; a dashboard ticket is cut in `jamienisbet`. Planning is epics and stubs in
  `.icm/intake/` — never a loose `TODO.md`.
- **This repo is held to its own baseline**, and to its own workspace grammar. A rule it
  exempts itself from is a rule it should delete.

For the rest of the house rules — CI as the source of truth, no repo exempt (D44),
ticket commits straight to `main` (D39), conformance reported never repaired, no secrets
in git — see [`_system/README.md`](_system/README.md) § House doctrine.
