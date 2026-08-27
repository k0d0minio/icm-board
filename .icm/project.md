# icm-board — project register

> Seeded 2026-08-26 at the split from `k0d0minio/jamienisbet`, from intent Jamie stated
> directly in that session. **Not yet a `/project` run** — the empty sections below are
> real gaps, not omissions. Run `/project icm-board` to interrogate and fill them.
> Maintained by `/project`. Amend by re-running it, not by hand-editing during a session.

## What this is

The second brain of Jamie Nisbet's business, written as an ICM system: three workspaces
(`sell`, `start`, `deliver`) that carry the whole client lifecycle as stage contracts
with human gates; the knowledge layer they cite (services, pricing, voice, terms,
stack); the contracts every repo is measured against; the scripts that measure them; and
the canonical Claude assets seeded across the estate. It holds no application code and
ships no product. Its one user is Jamie; its jobs are that every deal moves through a
defined, improvable process, and every repo in the estate stays aligned.

## Intent

- **For whom** — Jamie, and every Claude session opened at `~/Apps` or in any estate repo.
- **The job** — two, and the first wins when they conflict: (1) the business's processes
  and knowledge live here, versioned and improvable, so no deal reinvents them;
  (2) the estate stays conformant, with drift visible before it compounds.
- **Done looks like** — a lead can be taken from first contact to a running project by
  walking folders anyone could read; a repo can be adopted, analysed and ticketed
  without anyone remembering how; and both say so when they drift.
- **Explicitly not** — a pipeline driver. The folders are the orchestration; stages run
  when Jamie enters them, and no outbound action leaves a session. The house rule
  "never build an orchestrator" survives the return of the business workspaces, and
  outranks everything here.

## Business logic

- **The repo wins.** Where a repo's own contracts conflict with the estate baseline, the
  repo is authoritative. Sustentus is the standing example and is exempt outright.
- **Tickets live next to the logic they describe.** A ticket about `_system/scripts/` lives
  here; a ticket about the dashboard lives in `jamienisbet`. This is why the `JN-*` series
  was split at the 2026-08-26 separation.
- **Gates are human checkboxes.** Read, never tick. Anything that cannot be verified from
  the repo (a Vercel setting, a token, a secret) is a human ticket that says so in its
  Prompt.
- **Conformance reports, it does not repair.** `icm-check.sh --fix` seeds only what is
  missing and never overwrites; the scheduled workflow reports and never writes.

## Features
| Feature | State | Tickets |
|---|---|---|
| Four commands — `/client`, `/project`, `/day`, `/icm-check` (thin routers) | shipped | — |
| Sell workspace — intake → discovery → quote → proposal | shipped, unproven | — |
| Start workspace — onboarding → repo → kickoff | shipped, unproven | — |
| Deliver workspace — the three rituals as stage contracts | shipped | — |
| Knowledge layer — services, pricing, voice, terms, stack | shipped | — |
| Canonical Claude asset library + drift report | shipped, unproven | ICM-010 |
| Four estate scripts — icm-check, tickets-board, ticket-hygiene, pull-all | shipped | ICM-003, ICM-004 |
| Self-check CI — shellcheck, contract links, ticket lint | shipped | — |
| Remote conformance CI over the `k0d0minio` org | shipped | ICM-015 |
| Estate heartbeat — scheduled digest | wanted | ICM-001 |
| `/day` run log | wanted | ICM-002 |

## Constraints

- **The estate is half-invisible to CI.** Client repos are gitignored and live only on this
  machine, so anything running in Actions must reach them over the GitHub API and is
  limited to what a read-only token can see.
- **Legal / data** — client repo names and business state are not public; this repo is
  private and `_system/AUDIT.md` is one reason why.
- **Commercial** — solo operator. Every rule here has to earn its maintenance cost.

## Decisions
| ID | Decision | Date | Supersedes |
|---|---|---|---|
| D1 | The control layer gets its own repo, `icm-board`; `jamienisbet` becomes a normal repo under `projects/` and keeps its remote, CI and tickets | 2026-08-26 | the 2026-08-12 consolidation |
| D2 | Ticketing and workflows live next to the code whose logic they describe, not centrally | 2026-08-26 | — |
| D3 | The business processes return as **full ICM workspaces** (Van Clief grammar: numbered stages, CONTEXT.md contracts, review gates) — contracts + human gates, never a driver | 2026-08-26 | the 2026-08-12 factory retirement, narrowly |
| D4 | The whole repo is one five-layer tree: `sell`/`start`/`deliver` under `workspaces/`; the three rituals become deliver's stage contracts; slash commands survive as thin routers. **The stage contracts are the process** | 2026-08-26 | "the commands are the process" (2026-08-14 consolidation), in wording only |
| D5 | Deal artifacts are **tracked in git** at `workspaces/deals/<slug>/` (private repo; cloud sessions must run the pipelines; past deals are precedent). Durable docs copy into the client repo at kickoff; never a secret in a deal folder | 2026-08-26 | — |
| D6 | This repo holds the business **knowledge layer** (`_system/knowledge/`): services, pricing (fixed-price · retainer · in-kind; no day rate), voice, terms, stack — filled via `_system/setup/questionnaire.md`, honest gaps until then | 2026-08-26 | — |
| D7 | Estate Claude assets: **canonical library** in `_system/template/claude/` (session-start + wrap-reminder hooks, ticket-craft + pr-conventions skills); `icm-check.sh` seeds what's missing and reports drift, never overwrites — the repo's copy wins | 2026-08-26 | AUDIT open decisions #1 (skills layering) and #3 (hook strategy) |
| D8 | Client acquisition covers **inbound + outbound** (qualification, target profile, outreach playbook) — marketing/content stays with `jamienisbet` | 2026-08-26 | — |
| D9 | Proposals are **markdown → PDF** in the deal folder; markdown canonical, PDF a build artifact | 2026-08-26 | — |

## Open questions

- Does the estate roster come from the `k0d0minio` org listing, or from Neon
  (`biz.clients.github_repo`) the way the dashboard's board does? The workflow currently
  assumes the org. *Answerable by: Jamie. Blocks: nothing yet — it only affects which
  repos get checked.*
- Should `icm-board` hold the estate `.icm/docs/` research (contabilista, founder brief)
  that stayed in `jamienisbet`? *Answerable by: Jamie. Blocks: nothing.*

## Run log
| Date | Commit | What changed |
|---|---|---|
| 2026-08-26 | — | Seeded at the split. Not a `/project` run; intent taken verbatim from the session that created this repo. |
| 2026-08-26 | — | The second-brain build (cloud session, interrogation-driven — decisions D3–D9 are Jamie's answers verbatim). Three workspaces created, rituals rehoused, knowledge layer scaffolded, canonical asset library seeded into the template. ICM-006 amended; ICM-009/ICM-010 cut. |
| 2026-08-26 | — | ICM-009 done in the same session: questionnaire run conversationally, all seven sections. Knowledge layer + target-profile + outreach filled with Jamie's real answers (band €1.000–€2.500 sites, €500 floor, method-not-band for apps/AI, scoped retainers €200–€4.000/mo, 50/50 default, two revision rounds, both ownership patterns, stack confirmed as policy, profile weighted to AI). Deliberate remaining gaps: voice/outreach example pastes, app/AI standing inclusions, the AI-SME channel. |
