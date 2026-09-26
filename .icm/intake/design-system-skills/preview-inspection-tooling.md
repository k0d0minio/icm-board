# Stub: Preview-side inspection — playwright-cli and impeccable detect against deployed URLs, with the guard carve-out

- feature-slug: preview-inspection-tooling
- scope: design-system-skills
- priority: P1
- size: M
- depends-on: research-fit-and-overlap
- sequence: 4 of 7
- sources: `breakdown.md` → What I understood (3) · `microsoft/playwright-cli` README +
  `skills/playwright-cli/SKILL.md` (v0.1.21: `npm i -g @playwright/cli`, `playwright-cli
  open|goto|snapshot|screenshot|console`, `.playwright/cli.config.json` → `allowedOrigins`,
  headless default, in-memory profile, `close-all`) · `pbakaus/impeccable` README (`npx
  impeccable detect <path|url>` needs an installed Chrome/Chromium/Edge; hooks on
  SessionStart/PostToolUse/Stop download a Rust binary; `--no-hooks`) ·
  `~/.claude/hooks/block-local-checks.sh` lines 69–71 (the regex) and the block it raised on
  2026-09-25 against a `grep` containing the word · `_system/template/root/opencode.jsonc`
  (`"* playwright*": "deny"`) · `.icm/project.md` D43 (the deploy is the verdict)

## Problem

The design loop needs eyes on the rendered page. The estate's doctrine is that the rendered
page is the Vercel preview or UAT deployment, never a local server — and the guard that
enforces it blocks anything named `playwright` outright. playwright-cli is a CLI that
screenshots and snapshots a URL; impeccable's `detect` scores a URL against 61 rules. Both are
inspection, not testing, and both are currently unreachable from a session. impeccable's
install also wires three hooks and a binary download the estate does not want.

## Proposed change

1. **The runnable.** `skills/design/scripts/inspect.sh <url> [--critique]` (T, executable):
   refuses any URL that is not `https://` on a `*.vercel.app` host or the repo's declared
   `uat`/`production_url` from `project.json` (never `localhost`, never `127.0.0.1`); opens a
   named headless playwright-cli session, captures a full-page screenshot and an accessibility
   snapshot at three widths (390, 768, 1280) into the run's `output/`, runs `npx impeccable
   detect <url>` when `--critique` is passed, closes the session, and prints `RESULT: OK
   <n> findings` / `RESULT: UNAVAILABLE <reason>` in the template's vocabulary. Preview URLs
   behind Vercel SSO need the bypass token `deploy-status.sh` already knows — reuse it, never
   print it.
2. **The carve-out, narrowest first.** The research report (stub 1) chose the pattern; apply
   it in all three places and prove it: `~/.claude/hooks/block-local-checks.sh` (Jamie's
   machine — flag, do not edit from a repo; the guard's own copy doctrine applies), the
   canonical copy under `_system/template/claude/hooks/` if one exists there, and
   `opencode.jsonc`'s bash permissions. Prove with the hook's fixture-test style that
   `playwright-cli open <url>` and `npx impeccable detect <url>` pass while `playwright test`,
   `npx playwright test`, `pnpm e2e` and `pnpm test` still block.
3. **What is not installed.** No impeccable hooks (`npx impeccable install --no-hooks`, or
   no install at all — `npx impeccable detect` runs without one); no `.impeccable/` config
   tracked in any repo unless stub 6 finds a reason; no `live` mode; no playwright-cli skill
   file in `.claude/skills/` (its 15 KB `SKILL.md` is replaced by the six commands
   `inspect.sh` actually uses, listed in the design skill's Level 2). Machine prerequisites
   (`@playwright/cli` global, a Chromium) are recorded in `_system/knowledge/stack.md`-style
   machine notes, and `inspect.sh` degrades to `RESULT: UNAVAILABLE` when they are absent —
   a cloud session without them still finishes the ticket, minus the screenshots.

## Acceptance

- [ ] `inspect.sh` against a real preview URL of one estate repo writes three screenshots and
      three snapshots into a run's `output/` and prints `RESULT: OK`; against
      `http://localhost:3000` it prints `RESULT: REFUSED` without launching anything
- [ ] The guard fixture proves the four blocked commands still block and the two allowed
      commands pass, in both Claude Code (hook) and OpenCode (`opencode.jsonc`)
- [ ] No hook, binary download or `.impeccable/` file is added to any repo by this stub;
      `git status` on the fixture repo after a full `inspect.sh --critique` run shows only
      `output/`
- [ ] The Vercel bypass token is read from the environment, never written to `output/` or
      a log

## Prompt

Read `.icm/intake/design-system-skills/preview-inspection-tooling.md` and
`.icm/intake/design-system-skills/breakdown.md`, then `.icm/docs/design-system-skills-research.md`
(stub 1 — take the carve-out pattern from it). Read `~/.claude/hooks/block-local-checks.sh`,
`_system/template/root/opencode.jsonc`, `_system/template/icm-pipeline/scripts/deploy-status.sh`
and `_system/template/icm-pipeline/skills/preview-deploy/`. Write `inspect.sh` under
`_system/template/icm-pipeline/skills/design/scripts/`, apply and prove the carve-out, and
state in the PR body the machine prerequisites and which hook copy Jamie must edit himself.
PR on a `claude/` branch.
