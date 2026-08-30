# Stub: Template rails — formatter and share off in estate opencode.json

- feature-slug: template-opencode-rails
- epic: opencode-buildout
- priority: P1
- size: XS
- depends-on: none
- sequence: 4 of 5
- sources: report artifact §Phase 5 (rails audit)
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8 ·
  builds on `.icm/intake/_done/opencode-sidecar/_done/opencode-config.md`

## Problem

The rails audit found two gaps in `_system/template/root/opencode.json`: OpenCode
auto-formats files after every edit (a local check by another name — CI owns
formatting) and session share links are public-by-URL (client work in repos).
Neither is covered by the permission block, and Claude Code hooks like
`block-local-checks.sh` don't run in OpenCode, so the config is the only
enforcement there.

## Change

Add to `_system/template/root/opencode.json`, permission block untouched:

- `"share": "disabled"`
- `"formatter": false`

Keep the bash pattern ordering exactly as it is — OpenCode evaluates last-match-
wins and the current chain resolves correctly (audited 2026-08-30); note this in
the PR description. Also flag there (decisions for Jamie, not this PR):
(a) OpenCode loads `.claude/skills` in estate repos by default; kill-switch is
the `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1` env var, left unset until evidence.
(b) With free-first models as the daily default, client repos may want a pinned
paid `"model"` in their own opencode.json (project config beats global) so a
free trial/data-collection endpoint can never drive a client session by
accident — recut as its own stub if Jamie wants it enforced.

Lands best before `opencode-sidecar/estate-rollout` runs, so the rollout seeds
the final shape in one pass; if rollout went first, `/icm-check --fix` will not
overwrite existing files — migrated repos then need the two keys added in their
own PRs, which is the expensive order.

## Prompt

Read `.icm/intake/opencode-buildout/template-opencode-rails.md` in this repo.
Make the two-key addition to `_system/template/root/opencode.json` on a `claude/`
branch and open a PR per the estate's PR conventions, with the ordering note and
the skills-loading flag in the description. Move this stub to the epic's `_done/`
in the same PR.
