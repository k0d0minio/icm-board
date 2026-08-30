# Stub: Browser automation + MCP gating behind dedicated subagents

> Completed 2026-08-30. Gating verified end to end: the build agent's tool list carries
> no `playwright_*` and no `context7_*`, while the `web-tester` subagent carries all 24
> `playwright_browser_*` tools — opencode namespaces MCP tools as `<server>_<tool>`, so
> the report's `playwright_*` pattern matches. Evidenced by a child session recorded
> under agent `web-tester` making four completed calls: navigate, evaluate,
> take_screenshot, console_messages against a local page.
>
> One fix the report did not anticipate: both MCP servers were declared as bare `npx`,
> which resolves only in an interactive shell. `npx` is Homebrew's and its PATH is
> exported from `~/.zshrc` alone, so under the systemd user session the desktop app
> inherits — the epic's primary surface — both servers failed with "Executable not
> found in $PATH". Each server now sets `environment.PATH` explicitly; an absolute npx
> alone would not have sufficed, since it is a symlink to a JS file with
> `#!/usr/bin/env node`. Verified connecting under a stripped environment.
>
> Step 3 (context7 docs subagent) deliberately not done — the report's own guidance is
> to leave context7 dormant until version-pinned library docs prove wanted; it is
> declared and gated off, costing nothing. Step 4: worktrees run independent sessions
> as described, and `explore`/`general` subagents exist — but there is no `scout` agent
> in v1.18.25, contrary to the report.

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
