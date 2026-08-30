# Breakdown: OpenCode build-out — the second daily driver, configured

- epic-slug: opencode-buildout
- sources: interrogation + research session 2026-08-30 · report artifact "Opencode
  Build-Out" https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8 ·
  Jamie's decisions same day: second daily driver — refined to ticket executor
  (Claude Code plans, OpenCode runs the stubs), free-first models (Zen free tier +
  near-free OpenRouter; Anthropic banned subscription OAuth in third-party tools),
  frontier per-session only, €20–50/mo ceiling, desktop app as primary surface,
  no OCX registry, voice out of scope

## What I understood

`opencode-sidecar` made the estate's repos speak OpenCode (AGENTS.md shape,
repo-side rails) and deliberately left installing and model-configuring OpenCode as
Jamie's own work. On 2026-08-30 Jamie asked for exactly that plan: triage his 17
candidate plugin links, sweep the ecosystem, and produce the must-do setup. The
report (artifact above) is the spec; this epic is its execution. Of the 17 links
only the Ayu theme survives as-is; notifications become a hand-rolled ten-line
`notify-send` plugin; worktrees and background agents are covered natively;
browser automation is the Playwright MCP gated behind a dedicated subagent, not
opencode-chromium. Jamie's plan (2026-08-30): Claude Code cuts the tickets,
OpenCode executes them — the agent-neutral `## Prompt` contract (opencode-sidecar)
is the handoff. Models are a free-first ladder: Zen free beta models where
suitable, committed default `openrouter/qwen/qwen3.8-flash` (near-free),
`gemini-3.5-flash-lite` small, Sonnet 5 per-session only. Hard rule: free models
are trial/data-collection endpoints and never drive sessions in client repos —
a client repo's own opencode.json can pin a paid model (project beats global).
The desktop app is the primary surface; it shares ~/.config/opencode with the
CLI, so all config serves both. Budget guardrails are part of the must-do:
opencode-quota, Dynamic Context Pruning, compaction pruning, MCP tool-gating,
and no orchestration bundles. Stubs 1–3 are machine work on Jamie's
box (no PR — nothing committed); stub 4 is the one template PR; stub 5 proves the
rails hold in a real repo.

## Build order

1. global-core-config — install/auth OpenRouter, global opencode.json + AGENTS.md + tui — depends-on: none
2. plugins-and-quota — quota, DCP, hand-rolled notify plugin; pin versions — depends-on: global-core-config
3. browser-agent-gating — Playwright/context7 MCP gated behind subagents — depends-on: global-core-config
4. template-opencode-rails — formatter off + share off in the estate template — depends-on: none
5. rails-smoke-test — one non-client repo session proves the rails hold — depends-on: global-core-config, template-opencode-rails

## Out of scope (whole epic)

- Voice (Handy, jarvis-mcp) — dropped by Jamie 2026-08-30; Handy is a plain desktop
  app he can install any time, no config on either side.
- The kdco/OCX plugin set and any third-party plugin registry — Jamie's call;
  native features instead.
- Orchestration bundles (oh-my-opencode and kin) — benchmarked below vanilla at 3×
  the cost; would fight the estate's own agents.
- Porting /day, /client, /project to native opencode commands — deliberate
  do-nothing until daily use shows a real gap; opencode already reads AGENTS.md and
  .claude/skills.
- `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS` — leave unset until there is evidence of
  skills misbehaving under opencode.
