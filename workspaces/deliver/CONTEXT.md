# deliver — the estate's engineering machine

*Layer 1 for this workspace. Grammar:
[`_system/contracts/WORKSPACES.md`](../../_system/contracts/WORKSPACES.md). Unlike sell
and start, these stages are **re-entrant rituals**, not a sequence — deliberately
unnumbered. Each is entered by its thin command; **the stage contracts here are the
process**, and there is no second narrative describing them.*

## Stages

| Stage | Command | Scope | When |
|---|---|---|---|
| [`stages/project/`](stages/project/CONTEXT.md) | `/project <repo>` | one repo, deep | Adopting · before a sprint · whenever direction may have moved. Idempotent. |
| [`stages/day/`](stages/day/CONTEXT.md) | `/day [wrap]` | the estate, shallow | Evening: pick tomorrow's ≤10. Session end: bank and cut. |
| [`stages/conformance/`](stages/conformance/CONTEXT.md) | `/icm-check` | the estate, structural | Does every repo carry the baseline. |

Two agents back them ([`.claude/agents/`](../../.claude/agents/)): `project-lens` (one
analysis lens per invocation) and `ticket-scout` (work in flight no ticket knows about).

## Layers, for this workspace

- **Layer 3** — the contracts: [TICKETS.md](../../_system/contracts/TICKETS.md) ·
  [PIPELINE.md](../../_system/contracts/PIPELINE.md) ·
  [PROJECT.md](../../_system/contracts/PROJECT.md) ·
  [LENSES.md](../../_system/contracts/LENSES.md) ·
  [CLIENTS.md](../../_system/contracts/CLIENTS.md).
- **Layer 4** — deliberately not here: the working artifacts are **the estate repos
  themselves** — each repo's `.icm/project.md`, `intake/`, code and git history, under
  `projects/` on Jamie's machine. This workspace never holds a copy of a client's work.

## The seam with the business workspaces

[`start/07_kickoff`](../start/stages/07_kickoff/CONTEXT.md) ends by running `/project`
in a new client repo — that is the only doorway between a deal and the machine. Nothing
in deliver reads a deal folder except that first run's imported documents, and nothing
in sell/start touches a repo's tickets.

**Sustentus takes all three stages like any repo** (D44). The pipeline was extracted from it
(D12), but the template has since moved past it and is the one source: `/icm-check` measures
it, `/day` reconciles it, `/project` works in it. Its project-owned files are its own, as
every repo's are; what changes it goes through a PR there (its `main` is ruleset-guarded), and
nothing may break its code or workflow.
