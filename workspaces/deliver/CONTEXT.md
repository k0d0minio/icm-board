# deliver — the estate's engineering machine

*Layer 1 for this workspace. Grammar:
[`_system/contracts/WORKSPACES.md`](../../_system/contracts/WORKSPACES.md). Unlike sell
and start, these stages are **re-entrant rituals**, not a sequence — deliberately
unnumbered. Each is entered by its thin command; **the stage contracts here are the
process**, and there is no second narrative describing them.*

## Stages

| Stage | Command | Scope | When |
|---|---|---|---|
| [`stages/day/`](stages/day/CONTEXT.md) | `/day [wrap]` | the estate, shallow | Evening: pick tomorrow's ≤10. Session end: bank and cut. |
| [`stages/conformance/`](stages/conformance/CONTEXT.md) | `/icm-check [adopt <repo>]` | the estate, structural | Does every repo carry the baseline · bring a repo onto the pipeline. |

The deep, per-repo ritual — intent, lenses, the cut — is not a stage here: it is `/setup`,
carried by every adopted repo and run in it (D45).

`/day` spawns `ticket-scout` ([`.claude/agents/`](../../.claude/agents/)) for work in flight
no ticket knows about; `project-lens` is spawned by each repo's `/setup`, not here.

## Layers, for this workspace

- **Layer 3** — the contracts: [TICKETS.md](../../_system/contracts/TICKETS.md) ·
  [PIPELINE.md](../../_system/contracts/PIPELINE.md) ·
  [register.md](../../_system/template/icm-pipeline/_shared/register.md) ·
  [lenses.md](../../_system/template/icm-pipeline/_shared/lenses.md) ·
  [CLIENTS.md](../../_system/contracts/CLIENTS.md).
- **Layer 4** — deliberately not here: the working artifacts are **the estate repos
  themselves** — each repo's `.icm/project.md`, `intake/`, code and git history, under
  `projects/` on Jamie's machine. This workspace never holds a copy of a client's work.

## The seam with the business workspaces

[`start/07_kickoff`](../start/stages/07_kickoff/CONTEXT.md) ends by adopting a new client
repo and running its `/setup` — that is the only doorway between a deal and the machine. Nothing
in deliver reads a deal folder; the repo's first `/setup` reads only the snapshots kickoff put in its `.icm/docs/`, and nothing
in sell/start touches a repo's tickets.

**Sustentus takes both stages like any repo** (D44). The pipeline was extracted from it
(D12), but the template has since moved past it and is the one source: `/icm-check` measures
it, `/day` reconciles it, its own `/setup` works in it. Its project-owned files are its own, as
every repo's are; what changes it goes through a PR there (its `main` is ruleset-guarded), and
nothing may break its code or workflow.
