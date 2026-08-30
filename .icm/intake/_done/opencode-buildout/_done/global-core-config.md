# Stub: Global OpenCode core — install, OpenRouter, config, rules, theme

> Completed 2026-08-30. **OpenRouter was dropped, not connected** — Jamie's call, since
> the Vercel AI Gateway and opencode Zen already cover the ladder. Step 2 is therefore
> satisfied by the two providers that were connected (Zen was already there; Vercel came
> with the box), and no key was ever handled in-session.
>
> That made the report's two committed model IDs dead, so both were substituted keeping
> its intent: `model` → `vercel/zai/glm-5.3-flash`, the peer the report itself named
> alongside its own pick and at the same price ($0.15/$0.50 per M vs $0.15/$0.47), 1M
> context; `small_model` → `vercel/alibaba/qwen3.7-flash` at $0.03/$0.13, since it only
> serves titles, summaries and compaction. The default stays deliberately *paid*: free
> models are trial/data-collection endpoints and must never drive a client-repo session,
> so a global default has to be safe everywhere.
>
> Verified: a session opens on `zai/glm-5.3-flash` with no model flag, `opencode models`
> lists the five Zen free models, and the resolved config reports `share: "disabled"`.
> Steps 1, 3, 4 and 5 shipped as written. One correction to the report: the shipped
> runtime loads `opencode.jsonc` as well as `opencode.json`, so the pre-existing empty
> `.jsonc` was moved aside to keep one authoritative config.

- feature-slug: global-core-config
- epic: opencode-buildout
- priority: P1
- size: S
- depends-on: none
- sequence: 1 of 5
- sources: report artifact §Phase 1
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

OpenCode is meant to be the second daily driver but has no personal-layer setup:
no provider, no model policy, no global rules file, no guardrail defaults. The
repo-side rails exist (opencode-sidecar); the machine side is empty.

## Change

All on Jamie's box, nothing committed anywhere. The desktop app is already
installed and shares `~/.config/opencode` with the CLI — every step serves both.

1. Have the desktop app install the CLI (kept for worktree terminals and headless
   `opencode run`), or `curl -fsSL https://opencode.ai/install | bash`.
2. Connect BOTH providers — Jamie pastes keys himself (credentials land in
   `~/.local/share/opencode/auth.json`, never in config): OpenRouter for the paid
   ladder, opencode Zen (opencode.ai/auth) for the free beta models.
3. Write `~/.config/opencode/opencode.json` exactly as the report's Phase 1 block:
   model `openrouter/qwen/qwen3.8-flash` (near-free committed default; Zen free
   models picked per-session, pinned later if one earns trust), small_model
   `openrouter/google/gemini-3.5-flash-lite`, `share: "disabled"`,
   `formatter: false`, `lsp: true`, `compaction: {auto: true, prune: true}`,
   plugin array (quota, DCP — stub 2 activates them), MCP servers context7 +
   playwright with `tools: {"playwright_*": false, "context7_*": false}`.
4. `cp ~/.claude/CLAUDE.md ~/.config/opencode/AGENTS.md` (explicit beats fallback).
5. TUI-only, optional: Ayu Dark theme JSON into `~/.config/opencode/themes/` +
   `tui.json` with `"theme": "ayu-dark"` (desktop app ignores this).

Standing rule established here: free models are trial/data-collection endpoints —
never drive a session in a client repo on one (report §model ladder).

Done when a session opens showing qwen3.8-flash as the model, `opencode models`
lists the Zen free set, and `/share` reports sharing disabled.

## Prompt

Read `.icm/intake/opencode-buildout/global-core-config.md` in this repo and the
report artifact it cites (Phase 1 section) for exact file contents. Set up the
global OpenCode config on this machine per the stub: install/upgrade opencode,
write ~/.config/opencode/opencode.json, AGENTS.md, tui.json and the Ayu theme.
Do NOT handle API keys — ask Jamie to connect OpenRouter and opencode Zen
himself. Nothing in this stub is committed to any repo.
