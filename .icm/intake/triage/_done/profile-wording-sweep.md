> Done in the 2026-09-22 rework (D24–D26), k0d0minio/icm-board#46 — Phase F commit on
> `claude/rework-deal-workspace-2026-09-22`. Every file listed below was swept: `deliver/project`
> § 1c and `deliver/conformance` (A, F), `start/06_repo` (removed — absorbed into `07_kickoff`, C),
> `07_kickoff` + `kickoff-checklist.md` (C), `TICKETS.md` · `CLIENTS.md` · `_system/README.md` (B, C),
> `AGENTS.md` + `.claude/commands/` (C), this repo's `.icm/CONTEXT.md` (F, the `- profile: intake` line
> gone), `estate-conformance.sh`'s header (F); found by the same grep and swept too: `deliver/day`,
> `.claude/agents/ticket-scout.md`, `pr-conventions/SKILL.md` (canonical + copy).

# Stub: The contracts still describe two profiles — sweep the wording to D22

- feature-slug: profile-wording-sweep
- lane: chore
- priority: P2
- sources: found during the template refinement (decision D22), 2026-09-21 ·
  `grep -rn "profile" workspaces _system/contracts .claude AGENTS.md` after the scripts changed

## What this is

Decision D22 retired the `intake` / `pipeline` tiers: `icm-check.sh`, `icm-sync.sh` and
`ticket-hygiene.sh` no longer read a `- profile:` line, and `contracts/PIPELINE.md`, the
seeded `.icm/CONTEXT.md` and `template/README.md` were brought in line in the same change.
The **process contracts were deliberately left alone** — that change was scoped to the
template and the scripts — so they still tell a session to *declare* a profile:

- `workspaces/deliver/stages/project/CONTEXT.md` § 1c — "declare (Jamie's answer, never the
  fix's)" is now a step with nothing to declare; what is left of it is the formatter guard,
  `--fix`, `--apply`, and filling the project-owned files (now including `complexity`).
- `workspaces/deliver/stages/conformance/CONTEXT.md` — reads the pipeline as conditional.
- `workspaces/start/stages/06_repo/CONTEXT.md`, `07_kickoff/CONTEXT.md`,
  `references/kickoff-checklist.md` — kickoff still chooses a profile.
- `_system/contracts/TICKETS.md`, `_system/contracts/CLIENTS.md`, `_system/README.md` —
  "every profile shares the intake layer" and similar.
- `AGENTS.md` and `.claude/commands/` — "sets a repo up on the pipeline profile".
- This repo's own `.icm/CONTEXT.md` still carries `- profile: intake` (ignored, but it is
  the example every other repo was copied from).
- `_system/scripts/estate-conformance.sh` header — "Pipeline-profile completeness is the
  local script's job": still true of the job, stale in the word.

## Why it is worth a ticket

A contract that tells a session to ask Jamie which profile a repo is on, when no tool
reads the answer, is the estate's named failure mode in miniature — docs richer than the
running system. It is wording only: nothing breaks while it waits, which is why it is
parked rather than folded into a scripts change.

## Prompt

Read decision D22 in `.icm/project.md` and the opening of `_system/contracts/PIPELINE.md`.
Then sweep the files listed under "What this is" so none of them asks anyone to declare,
choose or check a `profile`: every adopted repo carries the one pipeline, and what varies
is `complexity` in its `.icm/project.json` (`standard` | `micro`). Keep `/project` § 1c's
formatter guard, `icm-check.sh --fix`, `icm-sync.sh --apply` and the project-owned-file
interrogation — only the "declare" step goes, replaced by asking whether the repo is
`micro`. Remove the `- profile: intake` line from this repo's `.icm/CONTEXT.md`. Do not
touch any repo under `projects/`. Ship it as one PR on a `claude/` branch.
