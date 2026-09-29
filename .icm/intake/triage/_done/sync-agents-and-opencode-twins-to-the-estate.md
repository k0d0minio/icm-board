# Stub: Fan the two promoted agents and their OpenCode twins out to every repo

- lane: chore
- found-by: estate audit 2026-09-26 (icm-check: 27 of 28 repos GAP on agents/project-lens.md + agents/ticket-scout.md after #91) · 2026-09-26
- priority: P1
- complexity: low
- sources: `.icm/intake/unify-setup-project/_done/sync-lens-and-scout-agents.md` (template only) · `_system/scripts/icm-check.sh` CANONICAL + CANONICAL_ROOT · `_system/template/root/.opencode/agents/`

## Problem

#91 promoted `project-lens.md` and `ticket-scout.md` to canonical `.claude/` assets, and the audit
PR adds `.opencode/agents/{auditor,project-lens,ticket-scout}.md` — OpenCode reads agents only from
`.opencode/agents/`, so the "dual harness" agents were never visible to it. Neither has been
seeded anywhere: no stub owned the fan-out, and `icm-check.sh --fix` seeds only when a session runs
it. serviflow is excluded (hands-off, consultancy only); the ten freshly cloned dormant repos take
the seed like any other.

## Proposed change

`icm-check.sh --fix` across the estate, then one `Wrap:` commit straight to `main` per repo
carrying the five new files (sustentus through a PR on its ruleset-guarded `main`), the fan-out
convention of `estate-fanout-commits-to-main`. Re-run `icm-check.sh` and confirm the GAP count for
agents is zero everywhere but serviflow.

## Outcome (2026-09-29)

- **The seed had already landed.** By the time this ran, every repo under `projects/` carried
  `.claude/agents/{project-lens,ticket-scout}.md`, tracked and pushed; the 26 AGENTS.md repos
  also carried `.opencode/agents/{auditor,project-lens,ticket-scout}.md` (the 7 un-migrated
  repos are not required to, by design). `icm-check.sh`: 34 repos, 0 gaps.
- **Eight copies were lag, not local edits.** The dormant repos adopted 2026-09-26
  (ericeirafishing, gui-demo, houseoftherisingmojo, maja-grunzner, sell-my-stuff, shake-easy,
  website-starter) hashed to the pre-#97/#100 template. Refreshed byte-identical, one direct
  commit to each `main`, pushed.
- **sustentus still drift-warns on both agents.** Its copies differ only in Prettier
  formatting (`_italics_`, blank lines, an escaped `\*\*`) — committed by the 2026-09-29
  `icm update` sweep, so its formatter rewrites `.claude/**/*.md` on commit. Left as reported
  drift; re-copying would be reformatted again. The escaped `\*\*` is a real (cosmetic) break.
- serviflow excluded (hands-off).
