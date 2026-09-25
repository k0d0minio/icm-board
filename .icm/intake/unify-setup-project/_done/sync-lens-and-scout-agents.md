# Stub: Promote project-lens and ticket-scout to synced agents

- feature-slug: sync-lens-and-scout-agents
- epic: unify-setup-project
- priority: P1
- size: S
- depends-on: none
- sequence: 1 of 5
- sources: `.icm/project.md` D45 · `.claude/agents/project-lens.md` and
  `.claude/agents/ticket-scout.md` (icm-board only today) ·
  `_system/template/claude/agents/auditor.md` (the only agent currently synced)

## Problem

`project-lens` and `ticket-scout` are the two subagents `/project`'s ritual fans out to for
lens analysis and repo scanning. Neither is template-owned — only `auditor.md` is synced to
repos via `_system/template/claude/agents/`. A repo-local skill with no icm-board in view
cannot spawn agents that don't exist in its own `.claude/agents/`.

## Proposed change

Copy `project-lens.md` and `ticket-scout.md` from icm-board's `.claude/agents/` into
`_system/template/claude/agents/`, generalised the same way `auditor.md` was (D44) — no
identity tokens, everything read from `project.json` / `project-rules.md` at runtime. Add
both as `T` entries to `_system/template/icm-pipeline/MANIFEST`. Confirm `icm-sync.sh` syncs
`.claude/agents/` the same way it already does for `auditor.md` (it should — this is the same
path, two more files).

## Acceptance

- [ ] `_system/template/claude/agents/project-lens.md` and `ticket-scout.md` exist, carry no
      repo identity
- [ ] Both listed as `T` in the MANIFEST
- [ ] `icm-sync.sh --dry-run` against a repo that already has `auditor.md` synced shows the
      two new files as additions, nothing else changed

## Prompt

Read `.icm/intake/unify-setup-project/sync-lens-and-scout-agents.md` and
`.icm/intake/unify-setup-project/breakdown.md`. Promote `project-lens.md` and
`ticket-scout.md` to template-owned agents the same way `auditor.md` already is (D44) — check
how that file was generalised and how it's registered, and mirror it.
