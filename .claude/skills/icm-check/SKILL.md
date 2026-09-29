---
name: icm-check
description: Check every estate repo against the .icm/.claude baseline, populate gaps from _system/template, review each repo's .claude setup — or, with `adopt <repo>`, bring one repo onto the pipeline and hand it to its own /setup
allowed-tools: Bash(gh repo clone:*), Bash(git -C:*), Bash(_system/scripts/icm-check.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/icm-check.sh:*), Bash(_system/scripts/icm-sync.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/icm-sync.sh:*), Bash(projects/*/.icm/scripts/setup.sh --report), Read, Glob, Grep, Agent
---

# /icm-check — thin entry point

Read [`workspaces/deliver/stages/conformance/CONTEXT.md`](../../../workspaces/deliver/stages/conformance/CONTEXT.md)
and follow it exactly — **the stage contract is the process**; this file only routes.

Argument: `$ARGUMENTS` — empty for the estate walk; `adopt <repo>` for § Adopt (a repo
name, or a client's name — resolve with Jamie if ambiguous).
Where a repo carries `.icm/scripts/setup.sh`, the contract runs that repo's `setup.sh
--report` — its own answer to "complete, current, configured" — rather than re-deriving it.
Every repo drift-reports the template's canonical assets (ticket-craft, and — D45 — the
baseline copies `.icm/CONTEXT.md` and `.icm/intake/README.md`)
until its own PR carries the new bytes — that is the D7 rule working, not a fault.
