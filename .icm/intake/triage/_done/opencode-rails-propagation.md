# Stub: Propagate share/formatter rails to the 22 repos that predate them

- lane: chore
- found-by: opencode-buildout/template-opencode-rails, 2026-08-30
- priority: P1
- sources: `.icm/intake/opencode-buildout/_done/template-opencode-rails.md` ·
  report artifact §Phase 5
  https://claude.ai/code/artifact/806e3001-9c27-40a3-be2f-851c050086f8

## Problem

`template-opencode-rails` added `"share": "disabled"` and `"formatter": false` to
`_system/template/root/opencode.json` — but `opencode-sidecar/estate-rollout` had
already seeded every repo. All 23 estate repos carry an `opencode.json`; 22 are
byte-identical to the pre-change template and set neither key (sustentus differs and is
exempt from the baseline). `icm-check.sh --fix` creates only what is missing and never
overwrites, so **the template change reaches none of them.** This is the expensive
order the stub named.

It matters more here than a normal drift: Claude Code hooks do not run under OpenCode,
so `block-local-checks.sh` is inert there and the config is the *only* enforcement. Until
these two keys land in each repo, OpenCode will auto-format after every edit (a local
check by another name, which CI owns) and session share links stay public-by-URL in
repos that hold client work.

The gap is at least visible: `opencode.json` is in `CANONICAL_ROOT`, so `/icm-check`
reports each stale repo as "drift from canonical" — reported, never repaired.

## Change

Add the two keys to `opencode.json` in each of the 22 repos, matching the template
exactly and leaving each permission block untouched (it is a last-match-wins
fall-through chain, not a set — never reorder it). One PR per repo on a `claude/`
branch, per that repo's own conventions; ticket-only commits do not apply since this
touches config.

Sustentus is exempt from the estate baseline — leave it alone unless its own `.icm/`
asks for the change.

Done when `/icm-check` reports no `opencode.json` drift across the estate.

## Prompt

In the icm-board repo (`~/Apps`), run `_system/scripts/icm-check.sh` and collect every
repo reported with "drift from canonical: opencode.json". For each one, add
`"share": "disabled"` and `"formatter": false` immediately after the `$schema` line in
that repo's root `opencode.json`, so it matches `_system/template/root/opencode.json`.
Do not touch the `permission` block — OpenCode evaluates its bash patterns
last-match-wins and the existing ordering resolves correctly; reordering it silently
breaks the guardrails. Each repo is its own git repository under `projects/` and is
gitignored by icm-board: work in each repo, on a `claude/` branch, and open a PR there.
Skip `sustentus`, which is exempt from the estate baseline. When every repo is done and
`/icm-check` reports no opencode.json drift, `git mv` this stub into
`.icm/intake/triage/_done/`.
