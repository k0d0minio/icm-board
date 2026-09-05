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

## Acceptance criteria (rough)

- [ ] `garmani` ignores `.env*.local` and `.vercel`, and its committed `.env` is either
      justified or removed from the tree
- [ ] `kau-american-bbq`, `lourenco-botelho`, `vinecliff` ignore `.vercel`
- [ ] `sustentus` and `remi-ai` ignore `.vercel` at any depth, not just at the root —
      raised in their own repos, on their own terms
- [ ] `_system/scripts/vercel-env.sh link --dry-run` reports no Warnings and no REFUSE

## Prompt

Read `.icm/intake/triage/vercel-artifacts-not-gitignored.md` in the icm-board repo
(`~/Apps`). `vercel link` writes a `.vercel/project.json` and a `.env.local` holding a
short-lived `VERCEL_OIDC_TOKEN` into every directory it links, and 17 of the 40 paths in
`_system/scripts/vercel-env-registry.json` do not gitignore one or both — `garmani` (whose
`.gitignore` is only `/node_modules`, and which tracks a committed `.env`), three other
kodominio repos, and every app directory in `sustentus` and `remi-ai`, whose root
`/.vercel` rule does not reach `apps/<name>/.vercel`. This matters before the epic's
`pull-documented` stub ships, because that writes real values into those same
directories. The fix is a `.gitignore` line per repo, so it is a fan-out of small PRs in
the client repos — never a change to `vercel-env.sh`, which reports and does not repair,
and `sustentus` and `remi-ai` are governed by their own repos. Confirm the current state
with `_system/scripts/vercel-env.sh link --dry-run` first; its Warnings section, empty, is
the acceptance check. Run on Jamie's machine — `projects/*` is local-only.

## Outcome — 2026-09-05

Closed the same day it was cut, and mostly by disproving it. Measured after the first
full `link` run:

- **Three repos were real and are fixed** — `kau-american-bbq`, `lourenco-botelho`,
  `vinecliff` had no `.vercel` rule. `vercel link` appended `.vercel` and `.env*` itself
  when it linked them; each was committed with `!.env.example` added on top, because the
  CLI's `.env*` would otherwise have covered the manifest each repo already tracks —
  and the manifest is what `example-convention-and-init` is about to depend on.
  `garmani` Jamie fixed himself.
- **The other 16 were a false positive in the checker, not a gap in the repos.**
  `git check-ignore` cannot match a `dir/`-style rule against a path that does not exist
  yet, and `link` asks before it writes — so every repo whose rule is `.vercel/` looked
  unignored. `sustentus` and `remi-ai` both carry an unanchored `.vercel/` at the root,
  which reaches `apps/<name>/.vercel` perfectly well; the claim in this stub that a root
  rule "does not reach `apps/`" was simply wrong. `vercel-env.sh` now asks about a file
  inside the directory instead, and the estate reports no warnings at all.
- **Nothing was pushed to `sustentus` or `remi-ai`.** The CLI had left redundant
  `.gitignore` edits in both (a duplicate root rule in one, six new per-app files in the
  other); they were reverted rather than committed, since the root rules already did the
  job.

The one thing worth carrying forward is that `vercel link` **edits `.gitignore` in the
repo it links**, unprompted, and its choice of `.env*` is wrong for this estate. That is
now noted in the epic rather than here.
