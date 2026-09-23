# Stub: sync D35 into sustentus — a MongoDB database per run and per preview, migrations proven

- lane: chore
- found-by: mongodb-databases-d35 · 2026-09-23
- priority: P2
- complexity: high

## Problem

D35 gives a MongoDB repo `run_<slug>` databases, per-branch preview databases, pruning and the
`db-branch.sh prove` round trip — proven only on a fixture with a stand-in driver. Sustentus, the
first adopter, still migrates one shared preview database through a globally serialised job
(`.github/workflows/db-migrate.yaml`, `concurrency: db-migrate-preview`), its app reads
`MONGODB_DATABASE_NAME` directly (`packages/services/src/db/connection.ts`), and its
`project.json` says `reversible: true` while the workflow header says "forward-only". Nothing of
D35 reaches it until the template is synced and the repo-side acts are done.

## Proposed change

After icm-board's D35 PR merges, in this order — each its own step, Jamie's merges:
1. `icm-sync.sh --apply sustentus` (the two new `lib/*.mjs`, db-branch, db-env, setup, the
   contracts, the skill), through a PR (sustentus requires one).
2. `/setup` in sustentus: `provider: mongodb`, `isolation: database`, `previews: branch`,
   `production_name: sustentus-prod`, the shared preview name, `seed_command: pnpm --filter
   @sustentus/services db:seed`, `migrate_command: pnpm --filter @sustentus/services db:migrate`,
   the cluster tier's `limits`; seed `mongodb-cleanup.yaml` (set its `environment:` — the URI is
   an environment secret there). `db-env.sh init` lists the rest.
3. First live proof: `db-branch.sh <slug> up` then `prove` on a real run against the cluster and
   ts-migrate-mongoose — settles `reversible: true` vs "forward-only" (every one of the 93
   migrations' `down` is exercised only when it is this branch's own; a one-off full round trip
   with `--base` at the first migration's parent answers the whole question).
4. The chore in sustentus: `connection.ts` reads the name through `databaseName()` from
   `.icm/scripts/lib/db-name.mjs` (import, or a verbatim copy if the bundler refuses the path);
   `db-migrate.yaml`'s preview job targets `preview_<branch>` (seed + migrate), drops the global
   `db-migrate-preview` queue, and `preview-smoke.yaml` waits for it.
5. Operator: expose Vercel's system variables on the product projects, then set
   `MONGODB_PREVIEW_PER_BRANCH=1` on the Preview target — last. Unsetting it reverts.

## Prompt

In the icm-board repo (`~/Apps`), confirm the D35 PR is merged (`.icm/project.md` → D35), then
read `.icm/intake/triage/sync-mongodb-databases-sustentus.md` and work its five steps against
`projects/sustentus` on a `claude/` branch per repo. Read `db-branch.sh` and `db-env.sh` headers
first. The cluster URI is `MONGODB_URI` in Jamie's environment — never print it. Stop before
step 5: the flag is Jamie's to set. Record the first live `prove` verdict (and whatever the
fixture runner got wrong about ts-migrate-mongoose) in `.icm/project.md`'s run log.
