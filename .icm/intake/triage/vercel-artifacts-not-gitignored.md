# Stub: 17 estate paths do not gitignore what `vercel link` writes

- feature-slug: vercel-artifacts-not-gitignored
- lane: bug
- priority: P2
- sources: found during registry-and-link (epic vercel-env-system), 2026-09-05 ·
  `vercel-env.sh link --dry-run` over all 40 registry paths · `git check-ignore` per path

## What this is

`vercel link` writes two files into the directory it links: `.vercel/project.json`,
which holds only ids, and a `.env.local` carrying a short-lived `VERCEL_OIDC_TOKEN`.
The registry-and-link stub assumed both were gitignored estate-wide ("`.vercel/` is
gitignored in each client repo, so `link` commits nothing anywhere"). Measured, that
is false for 17 of the 40 paths:

- **`.env.local` not ignored — 1 path:** `garmani`. Its whole `.gitignore` is
  `/node_modules`, and it already tracks a committed `.env` (only
  `NEXT_PUBLIC_SITE_URL`, so nothing secret is exposed today — but the habit is there).
  `vercel-env.sh link` **refuses** this entry rather than dropping an OIDC token into a
  tree that visibly commits env files.
- **`.vercel/` not ignored — 16 paths:** `kau-american-bbq`, `lourenco-botelho`,
  `vinecliff`, and every app directory in the two monorepos — `sustentus/apps/*` (7)
  and `remi-ai/apps/*` (6). The monorepo cases are an anchoring artefact: both repos
  ignore `/.vercel` at the root, which does not reach `apps/<name>/.vercel`. Ids only,
  so `link` warns and proceeds.

## Why it is worth a ticket

Every later flow in the epic writes `.env.local` into these same directories with
**real values** in it, not just an OIDC token. `pull-documented` turns a warning here
into a live secret-in-git risk, so the gaps want closing before that ships — and
`garmani` wants closing before `link` can complete at all.

The fix is one `.gitignore` line per repo, but it is **not this repo's to make**:
`sustentus` and `remi-ai` are governed by their own repos (breakdown, out of scope),
and the kodominio repos each own their `.gitignore`. So this is a small fan-out of
per-repo PRs, not an estate script — and emphatically not something `vercel-env.sh`
should repair, which is why it reports.

## Rough shape

- kodominio (4 repos, one line each): `garmani` gets `.env*.local` **and** `.vercel`,
  and its tracked `.env` reviewed; `kau-american-bbq`, `lourenco-botelho`, `vinecliff`
  get `.vercel`.
- `sustentus` and `remi-ai`: change the anchored `/.vercel` to `.vercel` so it reaches
  the app directories. One PR each, in their own repos.
- Re-run `_system/scripts/vercel-env.sh link --dry-run` — the Warnings section is the
  acceptance check, and empty is done.
