# `_system` — the control layer

**Start here** (after [`../AGENTS.md`](../AGENTS.md) and [`../CONTEXT.md`](../CONTEXT.md)).
The contracts, knowledge and scripts behind the three workspaces and the estate — every
repo under `projects/`. Lean rules, not a factory: the workspaces under
[`../workspaces/`](../CONTEXT.md) are stage contracts plus human gates, never a pipeline
driver (decision D3, [`../.icm/project.md`](../.icm/project.md), superseding the
2026-08-12 factory retirement — what was retired stays retired; what returned is
contracts).

```
_system/
  README.md      ← you are here: what's where, and the house rules
  AUDIT.md       ← what's currently broken or undecided across the estate
  contracts/     ← the specs the workspaces and scripts read
  knowledge/     ← what the business knows: services, pricing, voice, terms, stack
  setup/         ← the questionnaire that fills knowledge/
  scripts/       ← the seven executables
  template/      ← the baseline + canonical Claude assets icm-check.sh --fix seeds
  hooks/         ← session hooks for this repo (estate board on SessionStart)
  reference/     ← background reading (the ICM paper)
```

Two workflows in [`../.github/workflows/`](../.github/workflows/) run the checks that
should not wait for a session: `self-check` on every push, `estate-conformance` daily.

## Four commands, three workspaces

Commands live in [`../.claude/commands/`](../.claude/commands/) and are **thin routers**
— each opens its stage's `CONTEXT.md` and follows it. **The stage contracts are the
process**; there is deliberately no second narrative describing them.

| Command | Routes into | When |
|---|---|---|
| **`/client <name>`** | [`workspaces/sell/`](../workspaces/sell/CONTEXT.md) · [`workspaces/start/`](../workspaces/start/CONTEXT.md) | A lead, a quote, a proposal, an onboarding — any one relationship, any stage. Idempotent. |
| **`/project <repo>`** | [`workspaces/deliver/stages/project/`](../workspaces/deliver/stages/project/CONTEXT.md) | Adopting · before a sprint · whenever direction may have moved. Idempotent. |
| **`/day [wrap]`** | [`workspaces/deliver/stages/day/`](../workspaces/deliver/stages/day/CONTEXT.md) | Evening: pick tomorrow's ≤10. Session end: bank what shipped, cut what's left. |
| **`/icm-check`** | [`workspaces/deliver/stages/conformance/`](../workspaces/deliver/stages/conformance/CONTEXT.md) | Does every repo carry the baseline + canonical assets. |

Two agents back deliver, in [`../.claude/agents/`](../.claude/agents/): `project-lens`
(one analysis lens per invocation) and `ticket-scout` (work in flight that no ticket
knows about).

## `contracts/` — the specs

| Doc | Owns |
|---|---|
| [contracts/WORKSPACES.md](contracts/WORKSPACES.md) | The workspace grammar — five layers, stage contracts, deal folders, the rules. |
| [contracts/TICKETS.md](contracts/TICKETS.md) | The intake layer — epics, stubs, triage, positional status, what the dashboard parses. |
| [contracts/PIPELINE.md](contracts/PIPELINE.md) | The per-repo pipeline — profiles, the run spine, gates, the scripts contract. |
| [contracts/PROJECT.md](contracts/PROJECT.md) | `.icm/project.md` — a project's intent, business logic, features, constraints, decisions. |
| [contracts/LENSES.md](contracts/LENSES.md) | The seven analysis lenses deliver/project fans over a repo. |
| [contracts/CLIENTS.md](contracts/CLIENTS.md) | The client lifecycle — `new → talking → client` (+ `lost`) — which sell and start walk. |

## `knowledge/` — what the business knows

[knowledge/README.md](knowledge/README.md): services · pricing · voice · terms · stack.
Layer-3 for the sell and start workspaces; filled via
[setup/questionnaire.md](setup/questionnaire.md) (ICM-009). Gaps are honest
(`— not yet established`), never invented mid-deal.

## `scripts/` — the seven executables

Each prints a single `RESULT:` line and takes config from the environment, never `.env`.

| Script | Does |
|---|---|
| [scripts/icm-check.sh](scripts/icm-check.sh) | Checks every repo **on disk** — this one included — against the baseline + canonical assets. `--fix` seeds gaps from [template/](template/README.md), **never overwrites**; drift from canonical is reported, never repaired. |
| [scripts/estate-conformance.sh](scripts/estate-conformance.sh) | The same question **over the GitHub API** — so it runs in CI, where `projects/` does not exist. Reports only; never writes. |
| [scripts/tickets-board.sh](scripts/tickets-board.sh) | The estate board. `--today` powers the SessionStart hook. |
| [scripts/ticket-hygiene.sh](scripts/ticket-hygiene.sh) | Read-only drift report, plus contract lint over every ticket; `/day` applies the fixes with judgment. An empty `.icm/dormant` parks a repo ([TICKETS.md](contracts/TICKETS.md)). |
| [scripts/pull-all.sh](scripts/pull-all.sh) | Pull every repo. |
| [scripts/self-check.sh](scripts/self-check.sh) | Holds **this** repo to its own rules: links resolve, tickets meet the contract. |
| [scripts/vercel-env.sh](scripts/vercel-env.sh) | The estate's Vercel env plumbing, over [scripts/vercel-env-registry.json](scripts/vercel-env-registry.json) — which repo/app path is which Vercel project, on which of the three teams. `link`, `init` and `audit` so far — `init` seeds each app's committed `.env.example` from the names Vercel holds, never values, never overwriting a line; `audit` is the drift report the three one-way flows imply, read-only in the strong sense (no file written, the API only ever asked, the CLI never run) and using the same `GAP`/`warn` severity split as the two above (epic `vercel-env-system`). Local machine only, and per-team `VERCEL_TOKEN_*` env vars only. |

The first two are a deliberate pair, not a duplication — one severity model (`GAP` =
what `--fix` would seed; `warn` = never auto-fixed), two vantage points.

## The shape of a repo

Every estate repo looks like this:

```
.icm/
  CONTEXT.md         ← the repo's .icm map + profile  → contracts/PIPELINE.md
  project.md         ← what this is for, and why      → contracts/PROJECT.md
  intake/            ← the work                       → contracts/TICKETS.md
    <epic-slug>/       breakdown.md + stubs + _done/
    triage/            parked one-off bug/tweak/chore stubs
    _done/             completed epics + the legacy archive; nothing is deleted
  runs/ stages/ …    ← pipeline profile only          → contracts/PIPELINE.md
  docs/              ← ad hoc reports, client words, runbooks
  onboarding/        ← client questionnaires, when there's a client
.claude/
  settings.json      ← clean policy + hook wiring     → template/README.md
  hooks/ · skills/   ← canonical estate assets; drift reported, repo wins
AGENTS.md            ← Layer 0: identity + routing only
CLAUDE.md            ← one-line `@AGENTS.md` import (Claude Code)  → template/README.md
opencode.jsonc       ← OpenCode rails, seeded beside the importer  → template/README.md
                       icm-board pilots this set; the rest of the estate still carries
                       Layer 0 as a full CLAUDE.md, and the conformance scripts accept
                       either shape until the rollout completes
```

## House doctrine

Converged conventions. Where these conflict with a repo's own contracts, **the repo wins**.

- **The folders are the orchestration.** Never build an orchestrator — no scripts or
  frameworks to "drive" a pipeline; a workspace stage runs when Jamie enters it.
- **Tickets ARE the plan.** No sprint field, no plan file, never a loose `TODO.md` or
  `BACKLOG.md`. A week's plan is the priorities and build orders; a day's plan is
  `.icm/today.md` here — at most **10 entries estate-wide**, written by `/day`.
- **Status is positional; done is a folder, not a field.** Where a stub sits is its
  state; `git mv` to `_done/` is the change. Abandoned work moves the same way with a
  `> Dropped:` line — nothing is deleted, no slug reused in its epic. Deals follow the
  same spirit: a lost deal keeps its folder and its log.
- **No outbound action without Jamie.** Sessions draft; he sends, invoices, and flips
  ladder rungs. Business state lives in Neon/Stripe, never mirrored into git.
- **CI is the source of truth.** The agent never runs `build`/`lint`/`typecheck`/`test`
  locally; it pushes and reads the checks.
- **Gates are human checkboxes** — the agent reads them, never ticks them.
- **Adopt or stop.** Resolve an existing run, register, deal folder or ticket set; never
  fabricate one.
- **Edit the source, not just the output.** A correction made twice at the same stage is
  a Layer-3 bug; fix the reference file so every future run inherits it.
- **Thin Layer-0 identity file** that routes rather than teaches — `AGENTS.md` here,
  still `CLAUDE.md` across the rest of the estate. Never templated either way: each repo
  writes its own. Only the one-line importer beside it is canonical.
- **Redirect files, not copies**, for cross-layer references — except where a repo must
  stand alone in a cloud session, which is why `.icm/intake/README.md` is a deliberate
  micro-copy.
- **Ticket-only commits go straight to `main`** (planning is data); code goes through a
  PR on a `claude/` branch.
- **No secrets in git, ever** — env vars only; flag any plaintext credential found. Deal
  folders record that access exists, never its value.
- **`settings.local.json` is the accretion layer**; `settings.json` stays clean policy.
- **Sustentus is exempt** from all of this — its `.icm/` carries its own pipeline
  semantics, and is the source the estate pipeline was extracted from
  ([contracts/PIPELINE.md](contracts/PIPELINE.md)). The board reads it; the tooling
  never touches it.
