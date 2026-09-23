# Stub: Record D37 and rewrite the ticket rule — the ticket base branch, reached through a PR

- feature-slug: ticket-base-contract
- epic: ticket-base-branch
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 4
- sources: breakdown (`.icm/intake/ticket-base-branch/breakdown.md`) · Jamie's rulings 2026-09-23

## Problem

Every contract that tells a session where ticket state goes says "straight to `main`", and every
reader is described as reading `main`. On a UAT repo that splits a ticket between two branches
(breakdown). The words must change before the scripts do, and the decision needs its register
line.

## Proposed change

1. **Register:** add the next free D-number (D37 at cutting) to `.icm/project.md` — the decision
   as the breakdown states it: the ticket base branch (`pipeline_base_branch`), the ticket PR shape,
   landing by auto-merge, Scope's front as a ticket PR, hotfix + knowledge lane on `main` with
   `sync` required after both, icm-board exempt. It amends D31 and PR regime 1.
2. **Ask Jamie the one open point before writing:** where auto-merge is unavailable, does the
   session merge its own `type:tickets` PR on a settled GREEN, or does Jamie merge it?
3. **Contracts:** `_system/contracts/TICKETS.md`, `_system/contracts/PIPELINE.md` (front, UAT
   section), `_system/README.md` House doctrine, `AGENTS.md` + `CONTEXT.md` + `README.md` standing
   rules (client repos: PR; icm-board: direct, and why).
4. **Template (T files):** `_shared/github.md` regime 1 rewritten (front = ticket PR),
   `_shared/stage-preamble.md` rule 4, `stages/01_scope/CONTEXT.md` step 7 + step 8 handoff,
   `stages/02_define/CONTEXT.md` branch check ("the stub was pushed to `main`" goes),
   `intake/CONTEXT.md`, `_shared/template-change.md` step 3, `uat/CONTEXT.md` (a ticket row in the
   path table; `sync` required after a hotfix **and** a knowledge-lane merge),
   `lanes/hotfix/` + `lanes/knowledge/` CONTEXT.
5. **Canonical skills, both copies** (`.claude/skills/` and `_system/template/claude/skills/`):
   `pr-conventions` (the ticket PR shape and how it lands; icm-board's copy says the exemption is
   icm-board only) and `ticket-craft` ("the board reads the ticket base branch — a stub exists
   once its PR merges").
6. **icm-board's delivery stages:** `workspaces/deliver/stages/day/CONTEXT.md` step 5 + Outputs,
   `workspaces/deliver/stages/project/CONTEXT.md` push rule, `.claude/commands/day.md` description.

## Acceptance criteria (rough)

- [ ] D37 in `.icm/project.md`; `validate-decisions.sh` (template) and `self-check.sh` pass in CI
- [ ] No contract, stage or skill left telling a client-repo session to push `.icm/` to `main`
      (`grep -rn "straight to .main"` shows only icm-board's own rules and the plumbing ruling)
- [ ] The ticket PR shape (branch, title, `type:tickets`, `announce: none`, path guard) lives once
      — in `pr-conventions` — and everything else points there
- [ ] Jamie's answer on the auto-merge fallback is written into D37

## Prompt

In icm-board (`~/Apps`), carry out stub 1 of the `ticket-base-branch` epic. Read
`.icm/intake/ticket-base-branch/breakdown.md` and `ticket-base-contract.md` first — they hold the
decision and the full file list. Before writing, ask Jamie (AskUserQuestion) the one open point:
where GitHub auto-merge is unavailable, does the session merge its own `type:tickets` PR on a
settled GREEN, or does Jamie merge it? Then record the decision under the next free D-number in
`.icm/project.md` and rewrite the contracts, template stage docs and both copies of the
`pr-conventions` and `ticket-craft` skills so a client repo's ticket state goes through a PR into
its ticket base branch (`lib/project.sh → pipeline_base_branch`), with icm-board keeping its
direct commits. Words only in this stub — scripts are stub 2. Never run checks locally; ship as a
PR on a `claude/` branch and read CI.
