---
description: Check every estate repo against the .icm/.claude baseline, populate gaps from _system/template, then review each repo's .claude setup
allowed-tools: Bash(_system/scripts/icm-check.sh:*), Bash(/home/jamie-nisbet/Apps/_system/scripts/icm-check.sh:*), Read, Glob, Grep, Agent
---

# /icm-check — thin entry point

Read [`workspaces/deliver/stages/conformance/CONTEXT.md`](../../workspaces/deliver/stages/conformance/CONTEXT.md)
and follow it exactly — **the stage contract is the process**; this file only routes.
