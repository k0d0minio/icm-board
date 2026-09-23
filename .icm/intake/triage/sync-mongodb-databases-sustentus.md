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

## Progress (2026-09-23)

- Steps 1, 2 and 4 are in sustentus/sustentus#1143 (`claude/sync-template-d35`, unmerged). The
  per-branch switch has two halves there: the Vercel Preview flag plus a repository variable of
  the same name, which the workflows read.
- Step 3 is not run: `MONGODB_URI` was not in the session, and Jamie deferred it. Run it from a
  shell that has the URI, in a checkout of the #1143 branch with the services deps installed:
  `env -u DEMO_TENANT_CLERK_ORG_ID .icm/scripts/db-branch.sh agentic-dashboard prove --base b9ffc066f^`
  (the full-history round trip; `agentic-dashboard` is the one live run). It is known UNPROVEN
  in advance: 6 `down`s throw. What it measures is where it stops and whether the re-applied
  `up` is idempotent. Afterwards, `db-branch.sh agentic-dashboard down`.
- The template findings are parked as `triage/db-branch-prove-runner-semantics`. Its seed order and stamp order
  are fixed in the template (migrate → seed; `--single` walks past an interleaved stamp); the
  throwing-`down` question is parked as `triage/db-branch-prove-declared-irreversible`.
- 2026-09-23, later: #1143 merged (`a51f3b9a0`). D36 put non-production on its own M0
  (`sustentus-staging`) and makes each `preview_<branch>` as a copy of `sustentus-preview`;
  sustentus#1146 carries that. Step 5 now waits on the operator cutover (the session checklist,
  phases 1–7: restore `sustentus-preview` onto the new cluster, split the Vercel and GitHub URIs,
  retire `Vercel-Admin-sustentus`), then #1146, then the two flags. The live `prove` runs
  against the non-production cluster, never production's.
- 2026-09-23, evening: #1146 merged (with `database.isolation: none` — no run databases, so no
  `prove`); icm-board #63 (D36) merged. Jamie confirmed the cutover done (`sustentus-preview`
  restored on `sustentus-staging`; Vercel and GitHub URIs split; both exposed passwords changed;
  local `.env` on the new cluster) and set `MONGODB_PREVIEW_PER_BRANCH=1` on GitHub and the three
  Vercel projects. **Left:** the first real ready PR proves the path — the copy step on a runner,
  the preview on `preview_<branch>`, the smoke waiting, `MongoDB cleanup` on close. Then close
  this stub.
- 2026-09-23, night: the first real ready PR ran (sustentus/sustentus#1150,
  `claude/sentry-web-instrumentation`) and the copy step failed — `preview_<branch>` for that
  branch is 42 bytes, and Atlas's shared/free tier (what `sustentus-staging` is) caps database
  names at 38, not MongoDB's dedicated-tier 63 that `db-name.mjs` assumed. Parked as
  `triage/mongo-preview-db-name-atlas-shared-tier-cap` (P1 bug, blocks this stub). **Still open:**
  once that's fixed and synced, re-run #1150 (or the next ready PR) to get the first clean pass
  through the copy, the preview migrate, the smoke wait and `MongoDB cleanup` on close — only
  then close this stub.

## Prompt

In the icm-board repo (`~/Apps`), confirm the D35 PR is merged (`.icm/project.md` → D35), then
read `.icm/intake/triage/sync-mongodb-databases-sustentus.md` and work its five steps against
`projects/sustentus` on a `claude/` branch per repo. Read `db-branch.sh` and `db-env.sh` headers
first. The cluster URI is `MONGODB_URI` in Jamie's environment — never print it. Stop before
step 5: the flag is Jamie's to set. Record the first live `prove` verdict (and whatever the
fixture runner got wrong about ts-migrate-mongoose) in `.icm/project.md`'s run log.
