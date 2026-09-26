---
name: project
description: The per-repo workflow — adopt, interrogate intent, analyse, and cut tickets. Idempotent; re-run it any number of times.
allowed-tools: Bash(git -C:*), Bash(gh repo clone:*), Bash(_system/scripts/icm-check.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/icm-check.sh:*), Bash(_system/scripts/icm-sync.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/icm-sync.sh:*), Bash(gh api:*), Read, Glob, Grep, Edit, Write, Agent, AskUserQuestion
---

# /project <repo> — thin entry point

Read [`workspaces/deliver/stages/project/CONTEXT.md`](../../workspaces/deliver/stages/project/CONTEXT.md)
and follow it exactly — **the stage contract is the process**; this file only routes.

Argument: `$ARGUMENTS` (a repo name or a client's name — resolve with Jamie if
ambiguous).
