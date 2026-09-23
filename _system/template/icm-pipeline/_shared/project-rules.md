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
- **Health endpoint** — `health_endpoint` in `.icm/project.json` (or per project under
  `deploy.projects[]`): <the URL that answers 200 when production is up; `health-check.sh`
  reads it once after the merge>. <Or: none declared — the read reports SKIP.>
- **Secret scanning** — `security-check.sh` runs <gitleaks (the repo's `.gitleaks.toml`) |
  the built-in patterns> over the lines a branch adds; the dependency audit is <the lockfile's
  own tool at high | owned by CI / Dependabot, so the branch-time audit is advisory here>.
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

<The one-job skills under `.claude/skills/` a stage names — e.g. a docs skill for the
knowledge lane, a smoke-test skill for Release. "None" is a fine answer; the contracts say what to
do when a named skill is absent.>
