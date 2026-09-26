---
name: client
description: One command, every stage of a relationship — find the deal, work out where it stands from the folder, continue from there. Idempotent; re-run it freely.
allowed-tools: Bash(git -C:*), Bash(_system/scripts/validate-deal.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/validate-deal.sh:*), Bash(_system/scripts/render-deal.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/render-deal.sh:*), Read, Glob, Grep, Edit, Write, Agent, AskUserQuestion, WebSearch, WebFetch
---

# /client <name> — the deal's entry point

Argument: `$ARGUMENTS` — a person, a company, or a client slug. Resolve with Jamie if
ambiguous; never guess between two similar names.

**Routing, not process** — the stage contracts are the process
([`workspaces/sell/`](../../../workspaces/sell/CONTEXT.md) · [`workspaces/start/`](../../../workspaces/start/CONTEXT.md);
the folder shape: [`workspaces/deals/README.md`](../../../workspaces/deals/README.md)).

1. **Find the client folder**: `workspaces/deals/<client>/`.
2. **No folder, genuinely new** → confirm with Jamie (inbound lead or outbound prospect),
   then enter [`sell/01_intake`](../../../workspaces/sell/stages/01_intake/CONTEXT.md), which
   creates it.
3. **No folder, but the relationship predates the system** — a Neon row already
   `talking`/`active`, a repo, a proposal already sent → **adopt, never fabricate**: create
   the folder at its *true* stage (confirmed with Jamie), fold in the real artefacts under
   their stage numbers with a provenance line each, leave pre-system stages as honest gaps
   (README § Adopted deals).
4. **Folder exists** → read `DEAL.md` → `- engagement:`. List that engagement's folder;
   **the stage is the highest `NN-` artefact present** (01 intake · 02 look · 03 quote ·
   04 proposal · 05 agreement · 06 onboarding · 07 kickoff · 08 handover), the next stage
   is the one after it. State both out loud before working — the folder may be behind the
   truth — then enter that stage's `CONTEXT.md` and follow it.
5. **`- engagement: none` with a repo** → a returning or delivered client: summarise, and
   **ask whether to open a new engagement** (a new folder beside the old ones, never a new
   client folder). `none` and no repo → the next reply is `01_intake`'s. A deal whose
   engagement row says *lost* gets a summary, not a re-run.
6. **Where the stage needs the client repo** — `07_kickoff`, and the handover lane's record
   step — resolve `projects/<repo>` from `- repo:` and **STOP if it is not on disk**, with
   the clone command; every other stage runs from any session with icm-board in view.

Rules that travel with every stage: writes stay inside `workspaces/deals/` — and, in 07,
the client repo's `.icm/` · drafts are drafted, **Jamie sends** · **the rung is never
written down here** — read it from the dashboard when a stage needs it (one home per
fact, D24) · no secrets, no contact details in a deal folder, ever · `Deal:` commits go
straight to `main`, paths staged explicitly · **D25's Drive step is the only write
outside these two places**, and only for a rendered DOCX into the client's own Drive
folder — never a send.
