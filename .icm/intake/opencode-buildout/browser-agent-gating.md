# Stub: Browser automation + MCP gating behind dedicated subagents

- feature-slug: browser-agent-gating
- epic: opencode-buildout
- priority: P2
- size: S
- depends-on: global-core-config
- sequence: 3 of 5
- sources: report artifact §Phase 3–4
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

Browser automation is wanted (web-app verification) but opencode-chromium is two
weeks old with a native-messaging-host trust surface, and ungated MCP tools bloat
every session's context.

## Change

1. Write `~/.config/opencode/agents/web-tester.md` — subagent, description +
   `tools: {"playwright_*": true}`, no file edits — per the report's Phase 3
   block. Playwright MCP is already declared (stub 1) with tools globally off.
2. Verify: a session's build agent has no playwright tools; `@web-tester` does,
   and can navigate + screenshot a local page.
3. Optionally mirror the pattern for context7 (`docs` subagent) — only if
   version-pinned library docs prove wanted in practice.
4. Sanity-check native parallel flow while here: `@explore` / `@scout` subagents
   answer research asks; a second session in a `git worktree` runs independently.

Done when web-tester drives a browser and the main agent's context carries no
playwright tool schemas.

## Prompt

Read `.icm/intake/opencode-buildout/browser-agent-gating.md` in this repo and the
report artifact it cites (Phase 3–4). Create the web-tester subagent for OpenCode,
verify MCP tool gating works as described, and exercise the native subagent and
worktree flows. Machine-only work, nothing committed.
