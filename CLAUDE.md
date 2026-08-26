# CLAUDE.md — Layer 0: Repository Identity & Routing

> This is the **first file any Claude session reads.** It says what this repo is and where
> to go for a given task. Keep it short; detail lives in each folder's own `README.md`.

## What this repo is

**`icm-board`** — the orchestrator of Jamie Nisbet's repo estate. A software engineer / AI
consultant based in Mafra, Portugal, running ~22 client repos plus his own web estate.

This repo holds **no application code and ships no product.** It holds the contracts every
repo is measured against, the scripts that measure them, the three commands that do the
work, and the workflows that keep the measurement honest. Its one job: every other repo in
the estate stays aligned and well structured.

- **[`_system/`](_system/)** — the control layer. `contracts/` (the specs), `scripts/`
  (the four executables), `template/` (what `--fix` seeds), `hooks/`, `AUDIT.md`.
  **[Start there.](_system/README.md)**
- **[`.claude/`](.claude/)** — three commands, two agents, the session hook. *The commands
  are the process* — there is deliberately no second narrative describing them.
- **[`.icm/`](.icm/)** — this repo's own register and backlog (`ICM-NNN-slug.md`). It is
  held to the same baseline it enforces.
- **[`projects/`](projects/)** — every repo in the estate, one folder each. Separate git
  repos, **gitignored here**, present only on this machine.

### Never build an orchestrator

The repo is called `icm-board` and this rule still holds. **The folders are the
orchestration.** This repo *checks* structure and *reports* drift; it never drives a
pipeline, runs a build, or does a client's work. If a change here starts to look like a
framework for executing work rather than a contract describing it, that is the signal to
stop. See [`_system/README.md`](_system/README.md) § House doctrine.

## Routing — "if the task is… → go to…"

| The task | Go to |
|---|---|
| Adopt a repo · work out what to build · cut a sprint's tickets | **`/project <repo>`** — idempotent, re-run it freely ([`.claude/commands/`](.claude/commands/)) |
| Pick today's ≤3 · reconcile the board · end a session | **`/day [wrap]`** |
| Does every repo carry the baseline | **`/icm-check`** + [`_system/scripts/icm-check.sh`](_system/scripts/icm-check.sh) |
| What a project is *for* — intent, business logic, features, decisions | that repo's `.icm/project.md` ([`_system/contracts/PROJECT.md`](_system/contracts/PROJECT.md)) |
| Ticket standard (all repos' `.icm/intake/`) | [`_system/contracts/TICKETS.md`](_system/contracts/TICKETS.md) |
| How a repo gets analysed (the seven lenses) | [`_system/contracts/LENSES.md`](_system/contracts/LENSES.md) |
| What a lead's status means — the client lifecycle and its flags | [`_system/contracts/CLIENTS.md`](_system/contracts/CLIENTS.md) |
| Estate doctrine, contracts, the three commands | [`_system/README.md`](_system/README.md) |
| Estate audit — security, broken config, open decisions | [`_system/AUDIT.md`](_system/AUDIT.md) |
| Estate board / drift / pull everything, from a script | [`tickets-board.sh`](_system/scripts/tickets-board.sh) · [`ticket-hygiene.sh`](_system/scripts/ticket-hygiene.sh) · [`pull-all.sh`](_system/scripts/pull-all.sh) |
| Is the estate conformant *without* the repos on disk | [`estate-conformance.sh`](_system/scripts/estate-conformance.sh) + [`.github/workflows/estate-conformance.yml`](.github/workflows/estate-conformance.yml) |
| Plan or track engineering work on **this** repo | tickets in [`.icm/intake/`](.icm/intake/) (`ICM-NNN-slug.md`) |
| Engineering work in **any other** repo | that repo's own `.icm/intake/` under `projects/<repo>` — each repo owns its pipeline semantics |
| The websites, the dashboard, the brand, `biz.*` data | `projects/jamienisbet` — its own repo (`k0d0minio/jamienisbet`), its own `CLAUDE.md`, its own CI |

## Standing rules (do not break these)

- **`projects/` is never tracked here.** The `/projects/` line in `.gitignore` is the whole
  mechanism and has **no exceptions** — never add a negation. Client repos are never created
  by hand either: the admin dashboard creates them (`createClientRepo`), `/project` adopts them.
- **Tickets live next to the logic they describe.** A ticket about `_system/scripts/` is an
  `ICM-*` here; a ticket about the dashboard is a `JN-*` in `jamienisbet`. Same for CI.
- **Planning is tickets.** Any plan, backlog, or task list becomes markdown tickets in
  `.icm/intake/` — never a loose `TODO.md`/`BACKLOG.md`. Day = `Status: today` (≤3
  estate-wide), week = Priority rows. Ticket-only commits go straight to `main`; everything
  else through a PR on a `claude/` branch.
- **This repo is held to its own baseline.** It carries `.icm/project.md`, `.icm/intake/`
  and a Layer-0 `CLAUDE.md` like every repo it checks. A rule it exempts itself from is a
  rule it should delete.
- **Conformance reports, it does not repair.** `--fix` seeds only what is missing and never
  overwrites; the scheduled workflow reports and never writes.
- **CI is the source of truth.** Never run `build`/`lint`/`typecheck` locally; push and read
  the checks.
- **Sustentus is exempt** from the estate baseline — its `.icm/` is authoritative (own
  pipeline semantics, not the ticket spec). Gates everywhere are human checkboxes: read,
  never tick.
- **No secrets in git, ever.** Env vars only; flag any plaintext credential found.
