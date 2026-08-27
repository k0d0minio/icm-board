# `_system` — the control layer

**Start here** (after [`../CLAUDE.md`](../CLAUDE.md) and [`../CONTEXT.md`](../CONTEXT.md)).
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
  scripts/       ← the six executables
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
| [contracts/TICKETS.md](contracts/TICKETS.md) | The ticket format, estate-wide, and exactly what the dashboard parses. |
| [contracts/PROJECT.md](contracts/PROJECT.md) | `.icm/project.md` — a project's intent, business logic, features, constraints, decisions. |
| [contracts/LENSES.md](contracts/LENSES.md) | The seven analysis lenses deliver/project fans over a repo. |
| [contracts/CLIENTS.md](contracts/CLIENTS.md) | The client lifecycle — `new → talking → client` (+ `lost`) — which sell and start walk. |

## `knowledge/` — what the business knows

[knowledge/README.md](knowledge/README.md): services · pricing · voice · terms · stack.
Layer-3 for the sell and start workspaces; filled via
[setup/questionnaire.md](setup/questionnaire.md) (ICM-009). Gaps are honest
(`— not yet established`), never invented mid-deal.

## `scripts/` — the six executables

Each prints a single `RESULT:` line and takes config from the environment, never `.env`.

| Script | Does |
|---|---|
| [scripts/icm-check.sh](scripts/icm-check.sh) | Checks every repo **on disk** — this one included — against the baseline + canonical assets. `--fix` seeds gaps from [template/](template/README.md), **never overwrites**; drift from canonical is reported, never repaired. |
| [scripts/estate-conformance.sh](scripts/estate-conformance.sh) | The same question **over the GitHub API** — so it runs in CI, where `projects/` does not exist. Reports only; never writes. |
| [scripts/tickets-board.sh](scripts/tickets-board.sh) | The estate board. `--today` powers the SessionStart hook. |
| [scripts/ticket-hygiene.sh](scripts/ticket-hygiene.sh) | Read-only drift report; `/day` applies the fixes with judgment. |
| [scripts/pull-all.sh](scripts/pull-all.sh) | Pull every repo. |
| [scripts/self-check.sh](scripts/self-check.sh) | Holds **this** repo to its own rules: links resolve, tickets meet the contract. |

The first two are a deliberate pair, not a duplication — one severity model (`GAP` =
what `--fix` would seed; `warn` = never auto-fixed), two vantage points.

## The shape of a repo

Every estate repo looks like this:

```
.icm/
  project.md         ← what this is for, and why      → contracts/PROJECT.md
  intake/            ← the work                       → contracts/TICKETS.md
    <PREFIX>-NNN-slug.md
    _done/           ← finished AND abandoned tickets; nothing is deleted
  docs/              ← ad hoc reports, client words, runbooks
  onboarding/        ← client questionnaires, when there's a client
.claude/
  settings.json      ← clean policy + hook wiring     → template/README.md
  hooks/ · skills/   ← canonical estate assets; drift reported, repo wins
CLAUDE.md            ← Layer 0: identity + routing only
```

## House doctrine

Converged conventions. Where these conflict with a repo's own contracts, **the repo wins**.

- **The folders are the orchestration.** Never build an orchestrator — no scripts or
  frameworks to "drive" a pipeline; a workspace stage runs when Jamie enters it.
- **Tickets ARE the plan.** No sprint field, no plan file, never a loose `TODO.md` or
  `BACKLOG.md`. A week's plan is the `Priority` rows; a day's plan is `Status: today` on
  at most **3 tickets estate-wide**.
- **Done is a folder, not a field.** `git mv` to `_done/`; abandoned work too, with a
  `> Dropped:` line — nothing is deleted, no number is reused. Deals follow the same
  spirit: a lost deal keeps its folder and its log.
- **No outbound action without Jamie.** Sessions draft; he sends, invoices, and flips
  ladder rungs. Business state lives in Neon/Stripe, never mirrored into git.
- **CI is the source of truth.** The agent never runs `build`/`lint`/`typecheck`/`test`
  locally; it pushes and reads the checks.
- **Gates are human checkboxes** — the agent reads them, never ticks them.
- **Adopt or stop.** Resolve an existing run, register, deal folder or ticket set; never
  fabricate one.
- **Edit the source, not just the output.** A correction made twice at the same stage is
  a Layer-3 bug; fix the reference file so every future run inherits it.
- **Thin Layer-0 `CLAUDE.md`** that routes rather than teaches.
- **Redirect files, not copies**, for cross-layer references — except where a repo must
  stand alone in a cloud session, which is why `.icm/intake/README.md` is a deliberate
  micro-copy.
- **Ticket-only commits go straight to `main`** (planning is data); code goes through a
  PR on a `claude/` branch.
- **No secrets in git, ever** — env vars only; flag any plaintext credential found. Deal
  folders record that access exists, never its value.
- **`settings.local.json` is the accretion layer**; `settings.json` stays clean policy.
- **Sustentus is exempt** from all of this — its `.icm/` carries its own pipeline
  semantics.
