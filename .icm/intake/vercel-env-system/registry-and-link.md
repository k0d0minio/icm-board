# Stub: Registry and link — every repo knows its team and Vercel project

- feature-slug: registry-and-link
- epic: vercel-env-system
- priority: P1
- size: S
- depends-on: none
- sequence: 1 of 6
- sources: breakdown (`.icm/intake/vercel-env-system/breakdown.md`) · live team/project
  listing 2026-09-02 via Vercel MCP + CLI

## Problem

`vercel env pull` needs a `.vercel/project.json` link and only 4 of 24 local repos have
one. Nothing records which team a repo deploys under, and the three-team split
(kodominio / sustentus / remi21) means every later subcommand needs a token-per-team
lookup. Without a registry, each flow would re-derive the mapping.

## Proposed change

- `_system/scripts/vercel-env-registry.json` — committed, no secrets: one entry per
  local repo (or monorepo app path) → `{ team, project }`. Vercel project *names* are
  enough (`vercel link --project` resolves them); IDs optional. Model the fan-outs:
  `jamienisbet` → portfolio, client-referrals, jamie-nisbet; `sustentus` → its 8;
  `remi-ai` → its 6 (enumerate via `vercel projects ls --scope <team>`).
- `_system/scripts/vercel-env.sh` skeleton in the house style (bash + curl + jq +
  Vercel CLI, header comment explaining the three one-way flows) with the `link`
  subcommand: for each registry entry, `vercel link --yes --project <name> --scope
  <team> --token $VERCEL_TOKEN_<TEAM>` in the right directory. Idempotent; skips
  already-linked dirs; fails loudly per entry when a token env var is missing.
- Tokens are Jamie's manual step: three team-scoped tokens created in the Vercel
  dashboard, exported as `VERCEL_TOKEN_KODOMINIO` / `VERCEL_TOKEN_SUSTENTUS` /
  `VERCEL_TOKEN_REMI21`. Env vars only — never committed, and the script never prints
  them. Document the expectation in the script header.
- Local machine only: `projects/` is gitignored here and `.vercel/` is gitignored in
  each client repo, so `link` commits nothing anywhere.

## Acceptance criteria (rough)

- [ ] Registry covers every repo in `projects/` that has a Vercel project, all three
      teams, all three monorepo fan-outs
- [ ] `vercel-env.sh link` links every registry entry; rerun is a no-op
- [ ] Missing token → clear per-team error, no partial silent skips
- [ ] Nothing committed except the registry, the script, and this stub's move

## Prompt

Build the registry and link step of the estate's Vercel env system, in the icm-board
repo (`~/Apps`). Read `.icm/intake/vercel-env-system/registry-and-link.md` and the
epic's `breakdown.md` for full context, and `_system/scripts/estate-conformance.sh`
for the house script style. Create the committed registry
(`_system/scripts/vercel-env-registry.json`) mapping every local repo / monorepo app
path to its Vercel team and project name across kodominio, sustentus and remi21, and
the `vercel-env.sh` script with a working `link` subcommand using per-team
`VERCEL_TOKEN_<TEAM>` env vars. Run it on Jamie's machine only. Ship as a PR on a
`claude/` branch; move this stub to the epic's `_done/` in that PR.
