---
description: The estate ticket ritual — reconcile the board, pick today's ≤10, or close out a session. Ends as ticket commits pushed to main.
allowed-tools: Bash(_system/scripts/tickets-board.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/tickets-board.sh:*), Bash(_system/scripts/ticket-hygiene.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/ticket-hygiene.sh:*), Bash(git -C:*), Read, Glob, Grep, Edit, Write, Agent, AskUserQuestion
---

# /day [wrap] — thin entry point

Read [`workspaces/deliver/stages/day/CONTEXT.md`](../../workspaces/deliver/stages/day/CONTEXT.md)
and follow it exactly — **the stage contract is the process**; this file only routes.

Argument: `$ARGUMENTS` (empty = plan mode; `wrap` = close out).
