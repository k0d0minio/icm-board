
# opencode ↔ Claude Code: A Parity & Shared-Config Playbook (September 2026)

## TL;DR

- **opencode already reaches ~90% of Claude Code's feature surface**: it has plugins (hook equivalents), subagents, the same Agent Skills SKILL.md standard, AGENTS.md/CLAUDE.md memory, MCP, and session resume — the real gaps are TUI performance in long sessions and the "stops mid-task" babysitting problem, both fixable with community plugins (`opencode-auto-resume`) and settings today.
- **A single portable per-repo config is achievable**: make `AGENTS.md` canonical (Claude Code imports it via a one-line `@AGENTS.md` inside `CLAUDE.md`), put Skills in `.claude/skills/` (opencode reads it natively), and share commands via symlinks. Agents and MCP need a small sync tool (`rulesync`) or two files; **hooks are the one thing that cannot be shared** — Claude uses JSON+shell, opencode uses JS/TS plugins.
- **Keep opencode as your second tool.** For "cheap + multi-provider + Claude-Code-quality TUI + portable config" nothing beats it in Sept 2026; the only serious alternatives (Crush, Codex CLI, Pi) each lose on provider-freedom, cost, or config portability. Note Big Pickle is free but a stealth model of unconfirmed identity that trains on your data during its free period.

## Key Findings

1. **Install via the official curl script or the Homebrew tap, not distro packages** — they lag. opencode ships very frequently (several releases per week; the v1.18.x line was current in late Aug 2026, e.g. v1.18.24 on 28 Aug 2026). A separate **"v2" runtime (`opencode2`) is in beta** with known gaps — stay on the v1 stable line for production.
2. **Big Pickle** = a free stealth model on OpenCode Zen, `opencode/big-pickle`, **200k context / 32k output** (confirmed via Pi.dev's model catalog: `"contextWindow":200000,"maxTokens":32000`; the 128k-output figure at crackedaiengineering.com conflicts with the official catalog and should be disregarded). Identity officially unconfirmed; attributions **conflict** (leaked signatures suggest DeepSeek infra; other community skill files call it GLM‑4.6-class) — **treat identity as unknown; it may change without notice.** It trains on your prompts during the free period, and is inconsistent on mid-sized projects without subagents/MCP.
3. **Anthropic subscription auth is dead for opencode.** As of Feb–Mar 2026 Anthropic banned subscription OAuth in third-party tools and opencode removed all Claude OAuth code. An **Anthropic API key (per-token) is the only sanctioned path** — which is precisely why the user's Zen/Big Pickle strategy makes sense.
4. **Hooks** exist as a **plugin system** (JS/TS, `.opencode/plugin/*.ts`) with 25–32 events (`tool.execute.before/after`, `session.idle`, `permission.ask`, etc.) — strictly more powerful than Claude's ~6-event shell hooks, but a different format.
5. **The "auto-stop" problem is real and multi-causal**: output-token cap (`finish_reason: "length"`), stop-after-compaction bugs, idle after subagents, and the model "giving up." The fix is the **`opencode-auto-resume`** plugin plus permission auto-approval and compaction tuning.
6. **Skills are already cross-tool**: opencode natively reads `.claude/skills/` and `.agents/skills/`. Commands are near-identical format. Agents differ in frontmatter and need a symlink+edit or a sync tool.

## Details

### 1. opencode as of September 2026

**Repo & identity.** The canonical repo is `github.com/sst/opencode` → now `github.com/anomalyco/opencode` (SST rebranded to Anomaly). Anthropic acquired Bun — the JS runtime both Claude Code and opencode run on — on **Dec 3, 2025** ("Anthropic acquires Bun as Claude Code reaches $1B milestone"), with no practical effect on opencode. Per opencode.ai's own homepage (Sept 2026): **"over 195,000 GitHub stars, 950 contributors, and over 13,000 commits… used and trusted by over 16M developers every month"** — the most-starred open-source CLI agent by a wide margin.

**Version & cadence.** Extremely rapid: the v1.18.x line was current in late Aug 2026 (v1.18.24, 28 Aug 2026), with several point releases per week. A **"v2" runtime (`opencode2`)** is in beta and being built in-place; v2 has documented gaps (does not yet load configured `instructions` paths, LSP config accepted but servers not started, formatters accepted but not run) so **stay on the v1 stable line.** Auto-update handles patch releases unless disabled.

**Install / update on Ubuntu (most-reliable-first):**

| Method                                  | Command                                           | Currency                         |
| --------------------------------------- | ------------------------------------------------- | -------------------------------- |
| **Official script (recommended)** | `curl -fsSL https://opencode.ai/install \| bash` | Always latest; re-run to update  |
| Homebrew tap                            | `brew install anomalyco/tap/opencode`           | Recommended tap, most up-to-date |
| npm/bun/pnpm                            | `npm i -g opencode-ai@latest`                   | Latest; good if you pin Node     |
| AUR (Arch only)                         | `paru -S opencode-bin`                          | N/A on Ubuntu                    |
| `opencode upgrade`                    | `opencode upgrade [--method curl\|npm\|brew]`     | Auto-detects install method      |

On Ubuntu, use the **curl script** (or the Homebrew tap if you use brew) — the official `brew` formula and distro packages update less frequently. Verify with `opencode --version`. The desktop app exists but the CLI/TUI is the mature surface (the user rightly avoids the desktop app).

**Config files & precedence.** Config is `opencode.json` or `opencode.jsonc` (`$schema: https://opencode.ai/config.json`). Load order (later overrides earlier):

1. Remote org config (`.well-known/opencode`)
2. Global: `~/.config/opencode/opencode.json`
3. Project: `opencode.json` / `opencode.jsonc` (walks up to nearest git root; project wins)

Files are **merged**, not replaced — except the `instructions` array, where the highest-precedence config's *whole* array wins (arrays are not merged). TUI-only settings go in `~/.config/opencode/tui.json`. The project dir is `.opencode/` (with `agent`, `command`, `plugin`, `skills` subdirs).

**Provider setup.** Any provider via API key; authenticate with `opencode auth login` or `/connect` in the TUI. Per opencode's docs (opencode.ai/docs/models), it uses the Vercel AI SDK and the Models.dev catalog to support **75+ LLM providers plus local models**.

**Zen & Big Pickle.** OpenCode Zen is a curated pay-as-you-go gateway (model IDs `opencode/<model-id>`, endpoint `https://opencode.ai/zen/v1`, OpenAI-compatible). Card processing fee 4.4% + $0.30/txn; balance auto-reloads $20 when it drops below $5 (disableable); monthly limits settable. **Big Pickle**: free stealth model, `opencode/big-pickle`, **200k context / 32k output** (confirmed via the Pi.dev catalog config). Underlying model **officially unconfirmed** and attributions conflict; independent benchmarking (P. Chaffee, 2026‑08‑11, Scale SWE‑Atlas Codebase QnA) scored it **50.8%** and noted "leaked provider errors and API response signatures suggest it is currently served by DeepSeek infrastructure," while other community skill files identify it as GLM‑4.6/Sonnet‑4.5-class — **treat identity as unknown.** Privacy, verbatim from opencode.ai/docs/zen: *"Our providers follow a zero-retention policy and do not use your data for model training, with the following exceptions: Big Pickle: During its free period, collected data may be used to improve the model."* Community experience (daniel-tenzler.de, 2026): verbose; good at reading code/writing docs/planning; *"without MCPs or subagents it falls apart on a mid-sized project"*; and it *"sometimes ignores AGENTS.md."* Note also: it once ran a destructive git command after failed edits, so disallow `git` by default. **OpenCode Go** ($10/mo, with $30/week + $60/month dollar caps) is a separate flat-fee lane for open models (GLM, Kimi, DeepSeek, Grok, etc.).

**Anthropic auth — important timeline.** **Jan 9 2026**: Anthropic silently deployed server-side blocks on subscription OAuth tokens in third-party tools ("This credential is only authorized for use with Claude Code and cannot be used for other API requests"). **Feb 17–19 2026**: formalized in ToS ("Authentication and credential use" section). **Mar 19 2026**: opencode merged PR #18186 ("anthropic legal requests," Dax Raad), removing all Claude OAuth code, the Claude system prompt, and every Pro/Max reference. opencode's docs now state plugins that route Pro/Max are prohibited and the bundled ones were dropped as of 1.3.0. **Bottom line: for Claude models in opencode, use an Anthropic API key (per-token) only.**

### 2. Gap-by-gap

#### a. Hooks → plugin system

opencode has no Claude-style declarative hooks; it has a **more powerful plugin system**. Plugins are JS/TS modules in `.opencode/plugin/*.ts` (project) or `~/.config/opencode/plugin/*.ts` (global), or npm packages listed under `"plugin"` in `opencode.json` (installed with Bun, cached in `~/.cache/opencode/node_modules/`). Each plugin is an async fn receiving `{ project, client, $, directory, worktree }` and returns hook handlers. Events (25–32): `tool.execute.before`, `tool.execute.after`, `session.created/idle/deleted/compacted`, `permission.ask`, `file.edited`, `shell.env`, plus message/LSP/TUI events.

Claude → opencode mapping:

| Claude Code hook | opencode equivalent                      |
| ---------------- | ---------------------------------------- |
| PreToolUse       | `tool.execute.before` (throw to block) |
| PostToolUse      | `tool.execute.after`                   |
| Stop             | `session.idle`                         |
| Notification     | `event` handler on notification events |
| UserPromptSubmit | message/chat event hook                  |
| SessionStart     | `session.created`                      |

Example (block + GNOME notify):

```ts
import type { Plugin } from "@opencode-ai/plugin"
export const MyPlugin: Plugin = async ({ $ }) => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool === "bash" && /rm -rf/.test(output.args.command)) {
      throw new Error("blocked")
    }
  },
  event: async ({ event }) => {
    if (event.type === "session.idle")
      await $`notify-send "opencode" "Session idle"`  // Linux/GNOME
  },
})
```

Useful community pieces: `opencode-plugin-compose` (combine plugins), notification plugins, `opencode-agent-skills` (Superpowers). **Claude hooks cannot be auto-converted** — the recommended pattern is a shared `scripts/` dir called by both Claude's JSON hooks and a thin opencode plugin.

For reference, Claude Code's hook schema lives in `.claude/settings.json` (verbatim example, code.claude.com/docs/en/hooks, 2026-09-02):

```json
{ "hooks": { "PostToolUse": [ {
  "matcher": "Edit|Write",
  "hooks": [ { "type": "command", "command": "/path/to/lint-check.sh" } ]
} ] } }
```

Claude command hooks receive JSON on stdin and signal via exit codes (exit 2 = block). This is fundamentally different from opencode's in-process JS handlers.

#### b. Subagents

opencode agents use `mode: primary | subagent | all`, defined in `.opencode/agent/*.md` (filename = agent name) or the `agent` block in `opencode.json`. Per-agent `model`, `temperature`, `tools` (booleans), `permission`, and `prompt` (file ref). Invoke via `@mention` or the Task tool; primary agents toggle with Tab (build/plan). Config example:

```json
{ "agent": { "code-reviewer": {
  "description": "Reviews code for best practices",
  "mode": "subagent",
  "model": "anthropic/claude-sonnet-4-20250514",
  "prompt": "You are a code reviewer...",
  "permission": { "edit": "deny" }
}}}
```

Markdown form (`.opencode/agent/review.md`):

```markdown
---
description: Reviews code for quality and best practices
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools: { write: false, edit: false }
permission: { edit: deny, bash: deny }
---
You are in code review mode...
```

**Claude Code vs opencode agent frontmatter differ** — you cannot share one file unmodified. Claude Code's `.claude/agents/code-reviewer.md` (verbatim, code.claude.com/docs/en/sub-agents, 2026-09-02):

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use immediately after writing code.
tools: Read, Grep, Glob, Bash
model: inherit
---
```

Differences:

| Aspect           | Claude Code (`.claude/agents/`)           | opencode (`.opencode/agent/`) |
| ---------------- | ------------------------------------------- | ------------------------------- |
| identity         | `name` field (required)                   | filename                        |
| primary/subagent | no`mode`; `--agent`/setting             | `mode: primary\|subagent\|all`  |
| model            | aliases`sonnet`/`opus`/`inherit`      | `provider/model-id`           |
| tools            | comma-string allowlist +`disallowedTools` | object of booleans              |
| perms            | `permissionMode` enum                     | `permission` map              |
| temperature      | not supported                               | supported                       |

So agents need a **sync tool or symlink+hand-edit**, not a single shared file.

#### c. Skills — already cross-tool ✅

opencode implements the **Agent Skills SKILL.md open standard (agentskills.io)** — the *same* standard Claude Code adopted (Claude's docs confirm: "Claude Code skills follow the Agent Skills open standard, which works across multiple AI tools"). opencode discovery order (opencode.ai/docs/skills):

1. `.opencode/skills/<name>/SKILL.md` (project)
2. `~/.config/opencode/skills/<name>/SKILL.md` (global)
3. **`.claude/skills/<name>/SKILL.md` (project — Claude-compatible)** ✅
4. **`~/.claude/skills/<name>/SKILL.md` (global — Claude-compatible)** ✅
5. `.agents/skills/<name>/SKILL.md` and `~/.agents/skills/` (global)

For project-local paths opencode walks up to the git worktree and loads matches at every level. Skills load on-demand via the native `skill` tool. **A SKILL.md using only the six spec fields (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) is fully portable.** Claude Code's extra fields (`context: fork`, `hooks`, `agent`, `effort`…) are ignored by opencode. **Recommendation: keep shared skills in `.claude/skills/` — both tools read it, zero symlinks.**

#### d. Memory

opencode reads `AGENTS.md` as canonical and **falls back to `CLAUDE.md`** if no AGENTS.md exists (project), and to `~/.claude/CLAUDE.md` if no `~/.config/opencode/AGENTS.md` (global). First match wins per category (AGENTS.md beats CLAUDE.md). Claude-compat is disableable via env var. Extra files load via the `instructions` array (paths, globs, remote URLs with 5s timeout) in `opencode.json`:

```json
{ "instructions": ["CONTRIBUTING.md", "docs/guidelines/*.md", "packages/*/AGENTS.md"] }
```

Note: opencode does **not** parse `@file` references inside AGENTS.md — use `instructions` instead. Claude Code, conversely, **does** support `@path` imports inside CLAUDE.md (recursive, depth 4), plus `/memory`, auto-memory (`~/.claude/projects/<p>/memory/MEMORY.md`, first 200 lines/25KB loaded each session), and per-directory CLAUDE.md. **opencode has no true auto-memory**; community fills the gap with **memory MCP servers** and plugins (Opencode Mem; `mnemoria`-backed shared agent memory in oh-my-opencode).

#### e. MCP

opencode uses an `mcp` object (not Claude's `mcpServers`) in `opencode.json`. Local (stdio) and remote (HTTP, OAuth via Dynamic Client Registration). **opencode does NOT read Claude's `.mcp.json`** — formats differ (key `mcp` vs `mcpServers`; `command` is an array; env key is `environment`). Example:

```json
{ "mcp": {
  "context7": { "type": "remote", "url": "https://mcp.context7.com/mcp",
    "enabled": true, "headers": { "Authorization": "Bearer {env:C7_KEY}" } },
  "fs": { "type": "local",
    "command": ["npx","-y","@modelcontextprotocol/server-filesystem","/home/me/projects"],
    "enabled": true, "environment": { "FOO": "bar" } }
}}
```

Per-agent enable/disable is supported. Pitfalls: MCP tools consume context (the GitHub MCP is notoriously large and can exceed the context limit); install-time timeouts. Share the list with Claude Code via a converter/sync tool (rulesync/agentsync translate MCP configs).

#### f. TUI responsiveness

A real, acknowledged problem. Since v1.0 opencode uses **OpenTUI** (Zig renderer). Long sessions (>300k tokens) cause O(n)-per-frame re-renders → editor input lag, 100%+ CPU during streaming, and laggy scroll (issues #6172, #9930, #14479). The maintainers have stated a fundamental TUI refactor separating state from rendering is underway. Mitigations today:

- Keep sessions shorter — start `/new` sessions and compact aggressively.
- **Avoid VSCode/Cursor integrated terminals** (issue #7893 — dramatically worse, especially over WSL).
- On GNOME/Ubuntu use a **GPU-accelerated terminal — Ghostty, Kitty, WezTerm, or Alacritty** — which render high-throughput TUIs far better than GNOME Terminal/Ptyxis; pair with a monospace Nerd Font.
- Scroll tuning (`scroll_speed`, `scroll_acceleration`, `diff_style`) exists; there is **no scrollback cap yet** (PR #4919 to add one was closed unmerged). Keybinds are customizable in `tui.json`.

#### g. Session resume

Sessions persist automatically (SQLite/durable history). Resume with `opencode --continue` (last session) or `opencode --session <id>`; `/sessions` in the TUI; `--session <name>` pins/creates named sessions (run several in parallel terminals). Session sharing/export exists and **can be disabled** (recommended for private work). **Compaction is automatic and on by default**: opencode estimates tokens before each model call and compacts when `estimated > context_limit − max(output, buffer)` (threshold ≈ effective_window − ~13k tokens). It prunes tool outputs first (only when >20k tokens would be freed; always keeps the most recent ~40k; never prunes skill outputs) and often uses a cheap "session memory compact" instead of an LLM summary. Manual `/compact` and selective compaction are supported.

#### h. Auto-stop / babysitting — the headline pain

Multiple documented root causes:

- **Output token cap** → `finish_reason: "length"` makes the loop exit and wait for "continue" (issue #17471) — the classic "halts mid-task."
- **Stops after compaction** (issue #13217 — "Prompting 'keep going' fixes it").
- **Won't run unattended** — the model gives a status update then stops even with a "persistence" agent (issue #16589); agent stops after printing its todo list (issue #21534).
- **Provider interruptions / hangs** (issues #9218, #14769) and subagent-finish leaving the parent "busy."
- **Permission prompts** silently blocking.

**Fix stack (in order):**

1. **Install `opencode-auto-resume`** (Mte90) — detects stalls, output-length stops, tool-loops, done-with-open-todos, dead subagents, and stream failures, then auto-injects continue/recovery prompts. Highest-impact single change.
2. **Auto-approve permissions** so prompts don't block (see settings below).
3. **Tune compaction** and keep 100k-token sessions well under Big Pickle's 200k window so compaction fires cleanly (expect a quality dip afterward).
4. For fully headless loops, community uses a "Ralph loop" (`while` around `opencode run`) — but note `opencode run` has a known hang-after-completion bug (#17516) in some builds.

The user's ~100k-token sessions are **within** Big Pickle's 200k window, so hard context overflow is unlikely the main cause — the babysitting is almost certainly the output-cap/stall behavior, which `opencode-auto-resume` addresses directly.

### 3. Cross-tool single-configuration strategy (core deliverable)

**Design principle:** one canonical set at repo root, thin adapters into `.claude/` and `.opencode/`. Both tools already share the most important surfaces natively (AGENTS.md/CLAUDE.md and Skills); symlink or generate the rest.

**Instructions (most robust direction): AGENTS.md canonical, CLAUDE.md imports it.** opencode reads `AGENTS.md` directly. Claude Code reads only `CLAUDE.md` but supports `@import` (verified: `@AGENTS.md` inside CLAUDE.md works, per code.claude.com/docs/en/memory). Create a one-line `CLAUDE.md`:

```markdown
@AGENTS.md

## Claude Code-only notes
Use plan mode under src/billing/.
```

This is more robust than a bare symlink because it lets you add Claude-only lines and works on Windows. A plain symlink `ln -s AGENTS.md CLAUDE.md` also works on Linux if you need zero divergence. **Prefer the `@AGENTS.md` import.** (Do NOT make CLAUDE.md canonical and rely on opencode reading it — AGENTS.md always wins in opencode, producing confusing precedence.)

**Skills: single directory both tools read.** Put shared skills in **`.claude/skills/<name>/SKILL.md`** — opencode reads `.claude/skills/` natively (priority 3). Keep to the six portable spec fields. No symlink needed — lowest-noise option.

**Commands: near-identical, symlink.** Both use markdown with frontmatter (`description`, `argument-hint`, `model`) and `$ARGUMENTS`/`$1`/``!`shell` ``/`@file`. Claude: `.claude/commands/*.md`; opencode: `.opencode/command/*.md` (singular "command"; also accepts "commands"). opencode does **not** yet read `.claude/commands/` (open request #12291). Symlink:

```bash
ln -s ../.claude/commands .opencode/command
```

(Note: Claude Code has begun merging custom commands into skills — a `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy`; existing command files keep working.)

**Agents: cannot share one file** (frontmatter differs — see §2b). Keep two dirs hand-maintained, or use a sync tool to generate opencode agents from Claude ones.

**Hooks: cannot be shared.** Claude = JSON + shell scripts in `.claude/settings.json`; opencode = JS/TS plugins. Recommended pattern: put the actual logic in a **shared `scripts/` dir**, and call it from Claude's `PostToolUse` command hooks AND from a small `.opencode/plugin/hooks.ts` that shells out to the same scripts. Accept that the wiring is duplicated.

**MCP: converter/sync.** Formats differ; use a sync tool or maintain `mcp` in `opencode.json` and `mcpServers` in `.mcp.json` separately.

**Sync/converter tooling — evaluated:**

| Tool                                                                                     | Scope                                                                                | Claude+opencode?  | Maturity                                                                   | Verdict                                                    |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ----------------- | -------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **rulesync** (dyoshikawa)                                                          | rules, MCP, commands, subagents;`import`/`convert`/`.rulesync` source-of-truth | Yes (both listed) | Active, broad,`convert --from --to` one-shot                             | **Best general pick**                                |
| **agentsync** (spxrogers)                                                          | MCP, memory, skills, plugins → 31 agents; 9 deep adapters incl. Claude+opencode     | Yes               | Beta v0.1.0; explicitly "does NOT auto-translate Claude hooks to opencode" | Strong single committable source; honest about hook limits |
| **agent-rules-sync** (dhruv-anand)                                                 | rules/skills/settings/MCP real-time daemon; symlinks                                 | Yes               | Active                                                                     | Good for many-repo symlink workflows                       |
| **rulesync/AGENTS.md generators** (PanisHandsome `agentsync`, `rulesync` PyPI) | rules only                                                                           | partial           | Active                                                                     | Rules-only, lighter                                        |

**Recommendation:** go **symlink-first** (below) for the shared surfaces that already work natively, and adopt **`rulesync`** only when agent-frontmatter or MCP drift becomes painful (it explicitly supports Claude Code + opencode and can `convert` agents/commands/MCP). Neither tool solves hooks — accept the shared-`scripts/` pattern.

**Recommended low-noise repo layout:**

```
repo/
├── AGENTS.md                 # canonical instructions (root — both tools + Codex/Cursor read it)
├── CLAUDE.md                 # one line: @AGENTS.md  (+ any Claude-only notes)
├── .agents/                  # canonical home for shared stuff
│   ├── commands/             #   canonical command markdown
│   └── scripts/              #   shared hook logic (called by both)
├── .claude/
│   ├── skills/               # shared skills live HERE (opencode reads natively — no symlink)
│   ├── commands/ -> ../.agents/commands    # symlink
│   ├── agents/                              # Claude agent frontmatter (hand-maintained)
│   └── settings.json                        # Claude hooks (call .agents/scripts/*)
└── .opencode/
    ├── command  ->  ../.agents/commands     # symlink (note singular)
    ├── agent/                               # opencode agent frontmatter (generated or hand-maintained)
    └── plugin/
        └── hooks.ts                         # shells out to .agents/scripts/*
```

Symlink commands:

```bash
mkdir -p .agents/{commands,scripts} .claude/skills .opencode
ln -s ../.agents/commands .claude/commands
ln -s ../.agents/commands .opencode/command
```

**Git portability caveat:** Git stores symlinks as symlinks by default (`core.symlinks=true`); they survive clone on Linux/macOS but **break on Windows checkouts** (become plain text files) and on some CI runners. Since the user is Ubuntu-only this is fine; if collaborators use Windows, switch to the sync-tool "generate real files" approach and gitignore the generated copies. Skills in `.claude/skills/` need no symlink at all — that's the lowest-noise choice.

### 4. Plugins, settings & community resources that materially help

**Highest-value plugins (maintained as of 2026):**

- **`opencode-auto-resume`** (Mte90) — fixes the babysitting problem. *Install first.*
- **oh-my-opencode** (opensoft) / **oh-my-opencode-slim** (alvinunreal) — battery-included agent packs: async subagents, curated agents/models, LSP/AST tools, background jobs, MCPs, Claude-Code-compat layer. Slim uses fewer tokens and supports both v1 and v2. (oh-my-opencode was cited by Anthropic during the OAuth crackdown; it no longer ships OAuth spoofing.)
- **Opencode Notify** — native OS notifications on completion (pairs with GNOME `notify-send`).
- **Opencode Mem / mnemoria** — persistent cross-session memory.
- **Envsitter Guard** — protect `.env`/secrets from agent reads.
- **Dynamic Context Pruning** — reduce tokens in long sessions.
- **OpenCode Worktree** — git worktree isolation for parallel sessions.
- **`opencode-agent-skills` (Superpowers)** — richer skill injection/re-injection after compaction.

**Curated lists:** `awesome-opencode/awesome-opencode` (GitHub) and awesomeopencode.com — check last-commit dates; the ecosystem churns fast.

**Recommended `opencode.json` starting settings:**

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "opencode",
  "autoupdate": true,
  "share": "disabled",                       // don't auto-share private sessions
  "model": "opencode/big-pickle",
  "small_model": "opencode/big-pickle",      // cheap model for titles/summaries
  "plugin": ["opencode-auto-resume"],        // add others as needed
  "permission": {
    "edit": "allow",
    "webfetch": "allow",
    "bash": { "rm *": "ask", "git *": "ask", "*": "allow" }   // guard git — Big Pickle once nuked unstaged work
  },
  "instructions": ["docs/guidelines/*.md"],
  "agent": {
    "build": { "mode": "primary", "model": "opencode/big-pickle" },
    "plan":  { "mode": "primary", "model": "opencode/big-pickle",
               "permission": { "edit": "deny", "bash": "deny" } }
  }
}
```

TUI-only prefs (keybinds, `scroll_speed`) go in `~/.config/opencode/tui.json`.

### 5. Alternatives (only against the user's exact criteria)

| Tool                         | Provider freedom             | Cost               | Hooks               | Subagents       | Skills (SKILL.md)      | AGENTS.md/CLAUDE.md | MCP         | Session resume | TUI                       | Maintained                                          |
| ---------------------------- | ---------------------------- | ------------------ | ------------------- | --------------- | ---------------------- | ------------------- | ----------- | -------------- | ------------------------- | --------------------------------------------------- |
| **opencode**           | ★ any (75+)                 | ★ free/Zen/BYOK   | plugins (JS)        | ★ yes          | ★ native +`.claude` | ★ both             | ★ yes      | ★ yes         | good, laggy long sessions | ★ very active                                      |
| **Codex CLI** (OpenAI) | OpenAI only                  | ChatGPT plan / API | inline hooks (TOML) | yes (converged) | partial                | AGENTS.md           | yes         | yes            | good                      | ★ active                                           |
| **Gemini CLI**         | Gemini only                  | ★ generous free   | limited             | yes             | partial                | AGENTS.md           | yes         | yes            | good                      | **being retired** → Antigravity CLI (closed) |
| **Crush** (Charm)      | ★ multi                     | BYOK               | limited             | limited         | partial                | partial             | yes         | yes            | ★ best-looking           | active (FSL, pre-1.0)                               |
| **Aider**              | ★ any OpenAI-compat         | BYOK               | git hooks only      | no              | no                     | partial             | yes (newer) | git-based      | minimal                   | active                                              |
| **Goose** (Linux Fdn)  | ★ multi                     | BYOK               | extensions          | yes             | partial                | partial             | ★ yes      | yes            | ok                        | active                                              |
| **Pi** (pi.dev)        | ★ multi                     | BYOK               | lazy-skills         | minimal         | ★ lazy skills         | AGENTS.md           | yes         | yes            | fast; own perf issues     | ★ hot newcomer                                     |
| **Kilo CLI**           | ★ multi (built on opencode) | free models        | inherits            | inherits        | inherits               | inherits            | yes         | yes            | good                      | active (Roo migration target)                       |

**Verdict:** opencode remains the right second tool. Only **Crush** rivals its TUI and multi-provider freedom, but Crush is pre-1.0/FSL and weaker on skills/agents/portable config. **Codex CLI** is excellent but OpenAI-locked (kills "multi-provider at will"). **Gemini CLI** is on a deprecation path (transitioning to the closed-source Antigravity CLI). **Pi** is the one to watch — minimal, multi-provider, MIT — but less mature on the shared-config surfaces the user cares about. Nothing else matches opencode's combination of *free/cheap + any-provider + native AGENTS.md/`.claude`-skills portability + very active development.* Keep Claude Code as primary, opencode as the cheap multi-provider second — that pairing is optimal in Sept 2026.

### 6. Prioritized action plan

**Phase 0 — Install/update (10 min)**

1. `curl -fsSL https://opencode.ai/install | bash` (or `brew install anomalyco/tap/opencode`). Stay on v1 stable; don't switch to v2 beta yet.
2. Confirm with `opencode --version`; set `"autoupdate": true`.
3. Install a GPU-accelerated terminal (Ghostty/Kitty/WezTerm) + a Nerd Font; run opencode there, not in VSCode's integrated terminal.

**Phase 1 — Auth & model (5 min)**
4. `/connect` → OpenCode Zen → paste key. Set default `opencode/big-pickle`. Do NOT attempt Claude subscription OAuth (banned).
5. Big Pickle trains on your prompts — keep secrets out; use Zen paid models or a BYOK Anthropic key for sensitive repos.

**Phase 2 — Kill the babysitting (15 min)**
6. Add `opencode-auto-resume` to `"plugin"` in the global `opencode.json`.
7. Set permission auto-approval (config above); keep `rm *` and `git *` as `ask`.
8. Keep sessions under ~120k tokens; use `/new` + `/compact` proactively.

**Phase 3 — Shared per-repo config (30 min)**
9. Make `AGENTS.md` canonical at repo root. Create `CLAUDE.md` containing `@AGENTS.md` (+ any Claude-only lines).
10. Put shared skills in `.claude/skills/<name>/SKILL.md` (six portable fields only). opencode reads them natively — no symlink.
11. Canonicalize commands in `.agents/commands/`; symlink into `.claude/commands` and `.opencode/command`.
12. Put shared hook logic in `.agents/scripts/`; wire `.claude/settings.json` hooks and a small `.opencode/plugin/hooks.ts` to call them.
13. Agents: maintain `.claude/agents/*.md` and `.opencode/agent/*.md` separately, OR adopt `rulesync` to generate one from the other.
14. MCP: maintain `mcp` in `opencode.json`; use `rulesync convert` to keep `.mcp.json` in sync if Claude also needs the server.

**Phase 4 — Nice-to-haves**
15. Add oh-my-opencode-slim for subagent orchestration; Opencode Notify for GNOME notifications; a memory MCP / Opencode Mem for persistence.
16. Commit `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.opencode/`, `.agents/` (symlinks are fine on your Ubuntu-only setup).

**What cannot be reconciled (set expectations):**

- **Hooks** — no shared format; duplicate the wiring via shared scripts.
- **Agent frontmatter** — different schemas; needs a sync tool or two files.
- **MCP config** — `mcp` vs `mcpServers`; needs a converter.
- **Claude auto-memory and `@import` inside AGENTS.md** — opencode has neither (use the `instructions` array + a memory MCP instead).
- **Claude subscription in opencode** — permanently banned; API-key/Zen only.
- **TUI on very long sessions** — will lag until the OpenTUI refactor lands; mitigate with shorter sessions + a fast terminal.

## Recommendations

- **Do this now:** curl-install opencode, connect Zen/Big Pickle, and install `opencode-auto-resume` — that single plugin plus permission auto-approval eliminates ~80% of the babysitting. **Benchmark to re-evaluate:** if you still get frequent mid-task stops after auto-resume + auto-approve, the cause is likely a Big Pickle output/quality issue — switch that repo to a Zen paid model (GLM/Kimi/DeepSeek) or a BYOK Anthropic key.
- **Adopt the symlink-first shared layout** (AGENTS.md canonical + `@AGENTS.md` in CLAUDE.md + skills in `.claude/skills/` + symlinked commands). Only escalate to `rulesync` if agent/MCP drift becomes a chore — the threshold is "you've hand-edited the same agent in two places twice."
- **Keep opencode as second tool, Claude Code as primary.** Reconsider only if (a) Crush ships a 1.0 with skills/agents parity, or (b) Pi matures its shared-config surfaces — both worth a re-check each quarter given how fast this space moves.
- **Treat Big Pickle as ephemeral:** it's free and decent for planning/reading/docs, but its identity, quality, and free status can change without notice, and it trains on your data. Don't build critical workflows assuming it persists; keep a BYOK fallback configured.

## Caveats

- **Big Pickle's underlying model is unconfirmed and disputed** (DeepSeek-infra signatures vs GLM‑4.6 community attributions). Output cap is 32k per the official Pi.dev catalog (a 128k figure exists but conflicts and should be ignored). Free status is explicitly time-limited.
- **Version numbers move fast.** The v1.18.x line was current in late Aug 2026; exact patch numbers will differ by the time you install. The v1↔v2 split is real — verify you're on the v1 stable line before relying on `instructions`/LSP/formatters.
- **Some cited figures come from secondary/community sources** (star counts, TUI issue analyses, sync-tool feature matrices). Star count (195k+) is from opencode's own homepage; the Anthropic-ban timeline is corroborated across multiple outlets but individual dates (Jan 9, Feb 17–19, Mar 19) should be treated as "reported."
- **Sync tools (`rulesync`, `agentsync`) are young.** agentsync is explicitly beta (v0.1.0) and states it does not translate hooks. Validate any generated config before committing.
- **TUI performance fixes are in progress, not shipped.** The recommendations (fast terminal, short sessions) are mitigations, not cures, until the OpenTUI state/render refactor lands.
