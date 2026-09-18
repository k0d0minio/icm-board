# AGENTS.md — Layer 0: Repository Identity & Routing

> This is the **first file any agent session reads.** It says what this repo is and where
> to go for a given task. Layer 1 is [`CONTEXT.md`](CONTEXT.md); detail lives in each
> folder's own README or CONTEXT. Keep this short.
>
> `AGENTS.md` is the vendor-neutral filename; [`CLAUDE.md`](CLAUDE.md) is a one-line
> `@AGENTS.md` import so Claude Code loads the same Layer 0.

## What this repo is

**`icm-board`** — the second brain of Jamie Nisbet's business. A software engineer / AI
consultant based in Mafra, Portugal, running ~22 client repos plus his own web estate.

This repo holds **no application code and ships no product.** It holds the whole business
as an ICM system ([`_system/contracts/WORKSPACES.md`](_system/contracts/WORKSPACES.md)):
the processes that sell, start and deliver the work; the knowledge those processes cite;
the contracts every repo is measured against; the scripts that measure them; and the
canonical Claude assets seeded across the estate.

- **[`workspaces/`](CONTEXT.md)** — the three processes: `sell/` (lead → signed deal),
  `start/` (deal → running project), `deliver/` (the estate engineering machine).
  `workspaces/deals/` is Layer 4: one folder per client relationship.
- **[`_system/`](_system/README.md)** — the control layer: `contracts/` (the specs),
  `knowledge/` (rate card, services, voice, terms, stack), `scripts/`, `template/` (the
  baseline + canonical asset library), `setup/` (the questionnaire), `hooks/`, `AUDIT.md`.
- **[`.claude/`](.claude/)** — four thin commands (`/client`, `/project`, `/day`,
  `/icm-check`) that route into stage contracts, and two agents. *The stage contracts are
  the process* — the commands only route.
- **[`.icm/`](.icm/)** — this repo's own register and backlog (epics + stubs per
  [`TICKETS.md`](_system/contracts/TICKETS.md)). It is held to the same baseline it
  enforces.
- **`projects/`** — every repo in the estate, one folder each. Separate git repos,
  **gitignored here**, present only on Jamie's machine — deliberately not a link.

### Never build an orchestrator

The rule survives the return of the business processes (decision D3,
[`.icm/project.md`](.icm/project.md)): **the folders are the orchestration.** A workspace
is stage contracts plus human gates — nothing runs itself, nothing advances a deal or a
pipeline, no outbound action ever leaves a session. This repo *describes and checks*;
Jamie drives. If a change starts to look like a framework executing work, that is the
signal to stop.

## Routing — "if the task is… → go to…"

Full table: [`CONTEXT.md`](CONTEXT.md). The short version:

| The task | Go to |
|---|---|
| A lead, a quote, a proposal, an onboarding — anything about one relationship | **`/client <name>`** → [`workspaces/sell/`](workspaces/sell/CONTEXT.md) · [`workspaces/start/`](workspaces/start/CONTEXT.md) |
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
  cloud sessions need it) — but never a credential, token, or identity document. Business
  *state* stays in Neon/Stripe; the folders hold words and documents.
- **Tickets live next to the logic they describe.** A ticket about this repo's machinery
  is cut here; a dashboard ticket is cut in `jamienisbet`. Planning is epics and stubs in
  `.icm/intake/` — never a loose `TODO.md`. Ticket-only commits go straight to `main`;
  everything else through a PR on a `claude/` branch.
- **This repo is held to its own baseline**, and to its own workspace grammar. A rule it
  exempts itself from is a rule it should delete.
- **Conformance reports, it does not repair.** `--fix` seeds only what is missing and
  never overwrites; drift from canonical assets is reported, never auto-synced. The one
  exception is explicit and human-invoked: a pipeline repo's **template-owned** files
  (`_system/template/icm-pipeline/MANIFEST`) are brought up to the template by
  `icm-sync.sh --apply <repo>` — dry-run by default, nothing outside the manifest, no
  deletions (D20).
- **CI is the source of truth.** Never run `build`/`lint`/`typecheck` locally; push and
  read the checks.
- **Sustentus is exempt** from the estate baseline — its `.icm/` is authoritative. Gates
  everywhere are human checkboxes: read, never tick.
- **No secrets in git, ever.** Env vars only; flag any plaintext credential found.
