# Stub: Move Layer 0 to AGENTS.md; CLAUDE.md becomes the importer

- feature-slug: agents-md-layer0
- epic: opencode-sidecar
- priority: P1
- size: M
- depends-on: none
- sequence: 1 of 6
- sources: research session 2026-08-29 — AGENTS.md is the vendor-neutral standard
  (~28 tools, Linux Foundation-stewarded); Anthropic documents the `@AGENTS.md` import
  bridge in the Claude Code memory docs

## Problem

Layer 0 lives in `CLAUDE.md`, a filename only Claude Code loads natively. OpenCode
happens to fall back to it, but the estate is betting on a second harness and the
portable convention is `AGENTS.md`. icm-board pilots the move; the estate template
follows in a later epic only if the pilot holds.

## Proposed change

`git mv CLAUDE.md AGENTS.md`, then recreate `CLAUDE.md` containing the single line
`@AGENTS.md` (Claude Code's import syntax — expands at session start; preferred over a
symlink because it leaves room for a Claude-only addendum later). In the moved text,
make the self-references agent-neutral ("the first file any Claude session reads" and
similar). Grep the repo for links and references that treat `CLAUDE.md` as the identity
doc (`CONTEXT.md`, `_system/` docs, `.icm/`) and re-point them at `AGENTS.md` — leave
history files (`.icm/project.md` decision log) untouched. The conformance scripts only
warn on a *missing* CLAUDE.md and it stays present, so no script change.

## Acceptance criteria (rough)

- [ ] A fresh Claude Code session loads Layer 0 identically through the import
- [ ] `AGENTS.md` at the root carries the full Layer 0 content, agent-neutral wording
- [ ] No live doc in this repo links to CLAUDE.md as the identity file
- [ ] CI green

## Out of scope (this feature)

- The estate template (`_system/template/`) and other repos — template-and-checks and
  estate-rollout, later in this epic.
- `~/.claude/CLAUDE.md` (Jamie's global layer) — machine-level, not this repo's.

## Prompt

Move this repo's Layer 0 from CLAUDE.md to AGENTS.md. Read
.icm/intake/opencode-sidecar/agents-md-layer0.md for full context. git mv CLAUDE.md
AGENTS.md, recreate CLAUDE.md as the one-line `@AGENTS.md` import, neutralize
Claude-specific self-references in the moved text, and re-point live in-repo references
(not .icm/project.md history). Open a PR on a claude/ branch; do not run local checks —
CI is the source of truth.
