# Project rules — what is true of THIS repo (Layer 3 reference, project-owned)

The stage and lane contracts under `stages/` and `lanes/` are template-owned: byte-identical in
every pipeline repo, and carrying no repo's identity. Everything that is specific to this repo
lives in two project-owned files the sync never touches — `.icm/project.json` for the values a
script reads (name, docs path, archive paths, required checks and variables) and **this file**
for the rules a stage reads. A contract that says "see `_shared/project-rules.md`" means: the
answer is here, and it is this repo's own.

Fill each section in; a section that genuinely does not apply says so in one line.

## People and gates

- **The operator** — the human who ticks **Spec approved** and **Ready to merge**, and merges
  every PR from GitHub: <name>.
- **Authors** — where a story or request comes from (`run.md` → `author/source:`): <names,
  roles, or "the operator themselves">.
- **The client contact** — who is told what shipped, and by which variable: <`REPORT_EMAIL_TO`
  in the repo's environment names them; never an address in this file>. <Or: no client-facing
  report — the operator relays.>
- **UAT sign-off** — <none: every merge ships to production | `uat` in `.icm/project.json`
  names the Vercel custom environment and the one fixed address; the client contact who signs a
  batch off there, and how they say so (an email, a call); the operator records it with
  `promote.sh approve --by` and publishes the drafted Release (`_shared/promotion.md`); any
  one-time setup act still owed (`promote.sh init`)>.

## Knowledge

- **Docs tree** — `docs_path` in `.icm/project.json`; the stages read it through
  `_shared/knowledge-map.md` (project-owned — it names this repo's pages). <Or: this repo has no
  docs tree; the map is empty and the knowledge lane is unused.>
- **Code rules** — `<path>` (the file `_shared/conventions.md` redirects to).

## The factory

- **Required CI checks** — `required_checks` in `.icm/project.json` (the names `ci-status.sh`
  waits for). Tiering, if any (which checks run on a draft head, which on a ready one): <…>.
- **Deploy** — `deploy` in `.icm/project.json`: <which projects are product (preview on a ready
  head) and which quiet (build on merge only)>. The token is named there, never here.
- **Migrations** — `migrations` in `.icm/project.json`: <where they live; reversible (`down`
  scripts exist) or forward-only — a code revert must then tolerate the newer schema>.
- **Environment surfaces** — `.env.example` per app is the manifest (`env.sh audit`); keys
  scoped `[ci]` live in this repository's Actions secrets/variables, `[cloud]` in the Claude
  cloud environment panel. <Anything unusual about where a key must exist.>
- **Local feedback scripts** — `scripts/format.sh` and `scripts/lint.sh` run <formatter / linter>
  over changed files only; CI stays the verdict. <Or: not wired — the stubs report SKIP.>
- **The security gate** — `scripts/security-check.sh` runs before every commit in Build and
  before every lane's push (template-owned; the one local check that is a gate). Wired as this
  repo's git pre-commit hook: <`.husky/pre-commit` → `.icm/scripts/security-check.sh` | not
  wired — the stages call it>. gitleaks: <installed on every machine that commits | absent —
  the built-in patterns are the floor>. `security.audit_command` in `.icm/project.json` for a
  non-npm ecosystem: <…>.
- **The run's database** — `database` in `.icm/project.json`: <`neon` — one Neon branch per run,
  `run/<slug>`, a child of the production branch (`database.provider: neon`, the project id, the
  key's NAME in `neon.api_key_env`) | `database` — one MongoDB database per run, `run_<slug>`, on
  the cluster `$MONGODB_URI` names, migrated by `<migrate_command> up` and seeded by
  `<seed_command>`; `db-branch.sh <slug> prove` round-trips this branch's migrations before the ready flip and
  the merge | `schema` — one Postgres schema per run on `$DATABASE_URL` |
  `container` — one local Postgres per run | `none` — no database, or migrations are applied by
  the preview and CI only>. Migrations: <the declared stamp form (`millis` default; `epoch`
  with `extension` for a MongoDB runner such as ts-migrate-mongoose), the tool, and whether
  out-of-order is configured in the tool's own file>.
- **The environments' databases** — <none declared | Neon project `<id>`: production is the
  `main` branch (protected: yes/no); previews are the Vercel integration's `preview/<git-branch>`
  (`neon.previews: vercel` — the toggle is on: yes/no); the UAT database is the named
  branch `<uat_branch>`, set on the UAT environment's variables; migrations reach previews and
  UAT at build because <the build command / the `vercel-build` script> runs the migrate step; production migrates by <the workflow — on a UAT repo
  at the promotion, called by release.yaml>; `neon-cleanup.yaml` deletes a PR's branches on close (or: absent, because …) |
  MongoDB cluster via `$MONGODB_URI`: production is `<production_name>`, the shared preview
  database `<preview_name>` (both never dropped or reset); previews <share `<preview_name>` |
  each read `preview_<branch>` — `MONGODB_PREVIEW_PER_BRANCH=1` on the Preview target (set: yes/no),
  the app's connection code reads the name through
  `.icm/scripts/lib/db-name.mjs` (yes/no — the file that does it)>; `<the preview-migrate
  workflow>` migrates and seeds the PR's database on each push and the smoke check waits for it;
  the UAT database is `<uat_name>`, set on the UAT environment's variables; production
  migrates by <the workflow — on a UAT repo at the promotion>;
  `mongodb-cleanup.yaml` drops a PR's databases on close (or: absent, because …); the cluster's
  caps are <100 databases / 500 collections (a shared tier) | uncapped>>.
- **Health endpoint** — `health_endpoint` in `.icm/project.json` (or per project under
  `deploy.projects[]`): <the URL that answers 200 when production is up; `health-check.sh`
  reads it once after the merge>. <Or: none declared — the read reports SKIP.>
- **Archive** — `runs_archive` / `intake_archive` in `.icm/project.json`. <Where they are served
  from, if anywhere; the default `_done/` folders need no note.>

## Reporting

- **Kinds → channels** — `reporting` in `.icm/project.json`: `announce` → <github-release
  (the seeded default) [+ slack, email]>; `alert` → <none — a red CI job and Vercel's own
  deployment-failed email are the alert | slack | email>; `economics` → <none — icm-board's
  run-economics.sh writes it into the deal folder>. Channel variables are NAMES in project.json,
  values in the environment.
- **Who calls the hook** — `announce_from`: <session — Release step 9 calls `report.sh announce`
  | ci — `.github/workflows/release.yaml` (the reference workflow) calls it on the merge>.
- **Changelog** — <where a user-visible change is written up, and the skill or convention that
  owns its shape; or "none" — the PR's Summary line is then the Release's body>.
- **Workflows** — <`release.yaml` / `labels.yaml` present | absent, deliberately>.

## Support

- **Tier** — `support` in `.icm/project.json`: <none | basic — crash fixes on call, needs the
  fail-safe page at `support.failsafe_page` and Sentry via the key named by
  `monitoring.sentry_dsn_env` | retainer>. <Who is on call; what "on call" means here.>

## Capability skills the stages may call

- **Pipeline capability skills** — `.icm/skills/<name>/SKILL.md` (three-tier, loaded on a
  trigger; `.icm/skills/README.md`). Seeded and template-owned: `security-audit`,
  `database-migration`, `preview-deploy`. This repo's own additions: <name · what for | none>.
- **Repo skills** — <the one-job skills under `.claude/skills/` a stage names — e.g. a docs
  skill for the knowledge lane, a smoke-test skill for Release. "None" is a fine answer; the
  contracts say what to do when a named skill is absent.>

## Learned rules

*The constraints earlier runs paid for, appended before each close-out by two writers with one
shape: `.icm/scripts/retrospective.sh --apply` (at Release and at the end of every lane — one
line per error class a run fixed and flagged with `- rule:` in its `error.log`, or fixed again
after an earlier run already had, counted across the archive's `error.log`s) and
`.icm/scripts/run-pack.sh --sync-rules` (called by `close-out.sh` — the `## Learned rules` a run
wrote in its `FAILURE.md`: what no tool logged — a wrong assumption, a STOP, a skipped step).
Each line carries the run it was learned in. Build and the lanes read this section before their
first edit, with the same standing as the code rules. Edit or delete lines freely — this file is
the repo's own, never synced — and delete a line that reads as a slip rather than a constraint.*
