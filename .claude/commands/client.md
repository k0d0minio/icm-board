---
description: One command, every stage of a relationship — find the deal, work out where it stands, continue from there. Idempotent; re-run it freely.
allowed-tools: Bash(git -C:*), Read, Glob, Grep, Edit, Write, Agent, AskUserQuestion, WebSearch, WebFetch
---

# /client <name> — the deal's entry point

Argument: `$ARGUMENTS` — a person, company, or deal-folder slug. Resolve with Jamie if
ambiguous; never guess between two similar names.

**Routing, not process** — the stage contracts are the process:

1. Find the deal: `workspaces/deals/<slug>/` matching the argument.
2. **No folder** → this is a new relationship. Confirm with Jamie (inbound lead or
   outbound prospect), then enter
   [`workspaces/sell/stages/01_intake/CONTEXT.md`](../../workspaces/sell/stages/01_intake/CONTEXT.md).
3. **Folder exists** → read its `DEAL.md`. The `Stage` row names the next stage to run;
   read that stage's `CONTEXT.md` under
   [`workspaces/sell/`](../../workspaces/sell/CONTEXT.md) or
   [`workspaces/start/`](../../workspaces/start/CONTEXT.md) and follow it. State the
   stage out loud before working, so Jamie can correct it — the folder may be behind
   the truth.
4. A deal past `07_kickoff`, or one whose ladder rung is `lost`, gets a summary and a
   pointer (`/project <repo>` for a running client; nothing to do for a lost one) — not
   a re-run.

Rules that travel with every stage: writes stay inside `workspaces/deals/` (and, in
stages 06–07, the client repo's `.icm/`) · no outbound action from a session — drafts
are drafted, **Jamie sends** · Neon is authoritative for the ladder rung; update
`DEAL.md`'s mirror, remind Jamie of the dashboard step · no secrets in a deal folder,
ever.
