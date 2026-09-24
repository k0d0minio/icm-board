# The estate pipeline — the spine, the lanes, the gates, the ownership

*The contract for the templated, per-repo SDLC pipeline — extracted from the sustentus
`.icm/` (the reference implementation, which stays exempt from the estate baseline and
authoritative for itself) and seeded from [`_system/template/`](../template/README.md).
Re-founded on that source's current four-stage shape in September 2026, generalised
rather than parameterised — a template-owned copy is exact, which is what makes both the
drift report and the sync honest. Companions: [TICKETS.md](TICKETS.md) (the intake layer
every repo carries) · [PROJECT.md](PROJECT.md) (the register). Decisions D10–D12,
D20–D21 and D22, [`.icm/project.md`](../../.icm/project.md).*

**There is one pipeline, and every adopted repo carries it (decision D22).** `icm-check.sh`
requires it everywhere, `icm-sync.sh` syncs any adopted repo, and what varies between a
one-page site and sustentus is a **`complexity`** key in the repo's own `.icm/project.json`
— `standard` by default, `micro` for a repo too small to hold a knowledge map (its
`validate-knowledge-map.sh` returns 0 at once). Nothing is declared or chosen beyond that;
an old `- profile:` line, or a `"profile"` key in `project.json`, is ignored, never an
error. `icm-check.sh --fix` is what makes the folders arrive, and nothing starts running
by itself. The project-owned files are then filled by **`/setup`** — a command every repo
carries beside the router (decision D23): `setup.sh` reports what is complete, current and
configured from the repo's own files, the skill asks only what the report left open, writes
the project-owned files, and stops on a `claude/` branch. `/project` keeps intent, analysis
and tickets, with one precondition: `/setup` reports `OK` or names its gaps in the run.

Two rows survive from the first, tiered design because they still describe real things:

| Row | Means | For |
|---|---|---|
| **the reporting layer** | what a repo's own factory does on and after a merge — a GitHub Release by default, Slack or email when declared, a preview smoke walk where one exists | **read from the repo's project-owned files, never templated as a tier**: `project.json` → `reporting`, `deploy`, `smoke_check`; `project-rules.md` → Reporting. Sustentus is the reference; the reference workflows (`release.yaml`, `labels.yaml`) are seeded once by `/setup` where `announce_from` is `ci` |
| *(dormant)* | the empty `.icm/dormant` marker | parked repos ([TICKETS.md](TICKETS.md) § Dormant) |

## What the template seeds, and who owns each file

```
.icm/
  CONTEXT.md                 ← the repo's Layer-1 map                                     (repo's own)
  MANIFEST                   ← this ownership list, in the repo — setup.sh reads it offline (T)
  template-version           ← the icm-board commit the last sync came from (written, not synced)
  project.json               ← the manifest: name, complexity, docs_path, checks, deploy,
                                reporting, migrations, support                            (P)
  stages/
    01_scope/CONTEXT.md      ← source recorded → settled in session → scope.md → the cut (T)
    02_define/CONTEXT.md     ← stub or request → spec.md → the run's ONE draft PR          (T)
    03_build/CONTEXT.md      ← implement the approved spec; env.sh audit --changed;
                                security-check.sh; flip                                   (T)
    04_release/CONTEXT.md    ← gate read → review (security-check.sh measured) → close-out →
                                squash-merge → one read of production (deploy-status.sh, then
                                health-check.sh) → report.sh announce                      (T)
  lanes/
    bug/ tweak/ chore/       ← fast lanes: no spec, the merge button is the gate           (T)
    hotfix/                  ← human-invoked, opens READY; rollback.sh prepares a revert   (T)
    handover/                ← the deal's last lane: accounts, env, setup.sh OK, the record (T)
    knowledge/               ← one docs page, one docs-only PR, no run                     (T)
  intake/CONTEXT.md          ← the breakdown/stub formats, triage, the archive rules       (T)
  runs/<slug>/               ← one folder per run: run.md + usage.md + the canonical file
                                pack (project, plan, tasks, decisions, status, handoff,
                                FAILURE) + stage outputs                                    (Layer 4)
  skills/<name>/             ← three-tier capability skills (security-audit,
                                database-migration, preview-deploy): front matter always
                                in view, body on a trigger, references/ + scripts/ on demand (T)
  runs/README.md             ← the repo's own note on its runs and their archive           (P)
  raw/                       ← what a client sent, as it arrived: README.md + _processed/   (T)
  processed/                 ← text `process-raw.sh` extracted, + manifest.json             (T keeper)
  output/                    ← client-status.sh writes client-status-latest.md here          (T keeper)
  _shared/
    github.md                ← PR regimes, gate anchors, the never-tick rule               (T)
    ci.md                    ← GREEN / RED / PENDING and what green means                  (T)
    stage-preamble.md        ← resolve the run or STOP; run-scoped isolation               (T)
    scope-template.md        ← the shape of a settled scope; the D-n table                 (T)
    conventions.md           ← redirect to the repo's code rules                           (T)
    template-change.md       ← a T file asked to change in a repo → a prompt for icm-board   (T)
    run-pack/*.md            ← the seven canonical run files run-pack.sh seeds              (T)
    project-rules.md         ← what is true of THIS repo: people, factory, reporting, support,
                                and the Learned rules retrospective.sh (error.log) and
                                close-out (FAILURE.md) append                              (P)
    knowledge-map.md         ← which docs page each stage reads                            (P)
  scripts/
    lib/{gh,changed-files,project,vercel,neon}.sh  lib/{mongo,db-name}.mjs  lib/model-prices.json   (T)
    resolve-run.sh validate-spec.sh validate-intake.sh validate-decisions.sh new-run.sh
    project-body.sh project-labels.sh ci-status.sh close-out.sh triage-report.sh
    env-check.sh select-model.sh check-migrations.sh process-raw.sh
    deploy-status.sh rollback.sh usage-snapshot.sh env.sh setup.sh retrospective.sh
    list-skills.sh db-branch.sh db-env.sh security-check.sh run-pack.sh health-check.sh
    client-status.sh promote.sh                                                            (T)
    format.sh lint.sh validate-knowledge-map.sh report.sh                                 (P)
.claude/skills/pipeline/SKILL.md   ← the /pipeline router (one skill, many stages)
.claude/skills/setup/SKILL.md      ← /setup: the report, the questions, the P files
.github/pull_request_template.md   ← carries both gate anchors
.github/workflows/{release,labels}.yaml ← reference workflows, seeded ONCE by /setup (announce_from: ci)
.github/workflows/neon-cleanup.yaml     ← reference workflow, seeded ONCE by /setup (a Neon project branching per preview)
.github/workflows/mongodb-cleanup.yaml  ← reference workflow, seeded ONCE by /setup (a MongoDB repo with a database per preview, D35)
.opencode/plugins/icm-session-env.js    ← optional root asset: hands OpenCode's session id to the shell
```

**File-level ownership (decision D20).** Every file the template seeds is one of two
things, and [`template/icm-pipeline/MANIFEST`](../template/icm-pipeline/MANIFEST) says
which:

- **T — template-owned.** Byte-identical in every pipeline repo. It carries no repo's
  identity — no owner name, no docs path, no channel, no check name, no archive path —
  and reads whatever is repo-specific at runtime from the two project-owned files below.
  `icm-check.sh` reports a diverged copy as drift; **`icm-sync.sh --apply <repo>`** is
  the repair, invoked by a human, defaulting to a dry run, moving nothing outside the
  manifest and deleting nothing. This is the one narrow exception to "repos own their
  copies": the contracts are the estate's, so that a fix to a stage reaches every repo.
- **P — project-owned.** Seeded **once** from the template's stub when missing, then the
  repo's forever: neither script touches it again. `project.json` holds the values a
  script reads (`name`, `complexity`, `docs_path`, `required_env`, `required_checks`,
  `runs_archive`, `intake_archive`, `smoke_check`, `models`, and — decision D23 — the
  `deploy` block (platform, team, the token's *name*, the projects and their classes), the
  `reporting` block (kinds → channels; `github-release` on by default; variable *names*
  only), `migrations` (`path`, `reversible`) and `support` (`tier`, the fail-safe page, the
  Sentry key's name)); `_shared/project-rules.md` holds the rules a stage reads (who the
  operator is, how the repo reports, the support line, which capability skills exist);
  `_shared/knowledge-map.md` names the repo's own doc pages; `report.sh` is the reporting
  hook — complete as seeded, changed by editing `project.json`, never by editing the file;
  `format.sh` and `lint.sh` are the repo's own feedback scripts. **Nothing a repo runs
  reads anything outside the repo** (agency brief flag 1): the cross-repo tools —
  `run-economics.sh`, `vercel-env.sh registry`, `icm-check.sh`, `icm-sync.sh` — are
  icm-board's and are never called from a repo; `setup.sh --template` is the one explicit,
  optional reach, and it reports `SKIP` without one.

**A template-owned file is changed at its source (decision D33).** A request made *in a
repo* to change a `T` file — or a canonical `.claude/` asset (the router, `/setup`,
`pr-conventions`, `ticket-craft`, the hooks) — is not that repo's change to make: the
session edits nothing and writes a **template change request** — a self-contained prompt
for an icm-board session (the file by template path, today's lines quoted, the change in
full, the evidence, the repo), parked in the repo as one `found-by: template-change` triage
stub whose `## Prompt` is the request. No lane consumes it; the board's "Copy prompt" hands
it over. Here the change ships on a `claude/` PR, `icm-sync.sh --apply <repo>` brings a `T`
file back (a `.claude/` asset comes back by hand, drift-reported until it does), and the
stub retires in that commit. The only override is the operator's spoken "patch it here
now" — a named `Patch:` commit the next sync overwrites, the request written all the same.
The shape and the check live in [`_shared/template-change.md`](../template/icm-pipeline/_shared/template-change.md).

**No placeholders.** A template-owned contract never says `{{PROJECT}}`; it says "the
operator", "the docs tree (`docs_path` in `.icm/project.json`)", "the repo's required
checks", "see `_shared/project-rules.md` → Reporting". Generalising the pipeline out of
sustentus meant *removing* its identity, never templating it.

**The front is a stage, and it has no substage.** Scope exists for work
that arrives as someone else's words — a story, a prototype URL, a document, a prompt
written after a call, a chat thread. It records the source verbatim, interrogates it
**live with the operator in session** (`AskUserQuestion`, in rounds) — there is no
question sheet and nothing is answered out of band — settles what can be settled into
`01_scope/output/scope.md` (the source plus an addendum: assumptions, the **`D-n`
decisions table**, out of scope, and what is **Open for Define**), cuts the intake epic
from *that*, and lands it all on `main` in one **direct commit** (D39 (8); the canonical
`pr-conventions` skill). A front opens no PR. A repo whose work
arrives already agreed never invokes it and has no gap; work with a stub goes to
`/pipeline new`.

Then the spine, once per stub: an epic's next stub (or a plain request) → **Define**
writes `runs/<slug>/02_define/output/spec.md`, carrying every `D-n` it builds on and
answering every Open-for-Define line, validates it, and `new-run.sh` commits the run,
consumes the stub into `_done/`, and opens the **one draft PR** (its body projected from
the spec by `project-body.sh`) → the operator ticks **Spec approved** → **Build**
implements exactly the spec, writes `03_build/output/notes.md`, establishes CI green on
the cheap tier and flips the PR draft → open, which is what builds the previews → the
operator smoke-tests and ticks **Ready to merge** → **Release** establishes
`ci-status.sh` GREEN on the full gate, runs the review pass, parks off-ticket findings in
`triage/`, syncs the docs the change made stale, writes the changelog page where the repo
has one, runs `retrospective.sh` (what Build fixed on the way, promoted into
`project-rules.md` → Learned rules for the next run), runs `close-out.sh` **on the branch**,
and squash-merges once. The squash is
what publishes the archive move — and the epic's move, plus the front run that cut it,
when this stub was the last one it had left unshipped ([TICKETS.md](TICKETS.md)).
`revise <slug> "<change>"` is the only way a spec changes after that: it re-projects the
PR body and **resets the Spec-approved anchor**, so a revised spec never inherits a stale
tick.

**The slug is the universal key**: run folder, stub, branch (`claude/<slug>`), PR — one
name throughout. It is also the isolation boundary (D22): a run writes only under
`.icm/runs/<slug>/<stage>/`, on its own branch, in a working tree no other live run
shares — `_shared/stage-preamble.md` → Run-scoped isolation states the rule and every
stage and lane restates it in its Outputs. That, not a lock or a scheduler, is what lets
runs be in flight in parallel. **Runs are cut for disjointness (D26):** `## Parallelizable`
is derived from the stubs' `touches:` guesses (no shared surface in a parallel set; the
shared-file stubs — lockfile, schema and migrations journal, layouts, message catalogues —
first in the build order), Build merges `origin/main` before its ready flip, and
`new-run.sh` warns on an overlap with a live run. The migration check in Release is the one
place parallel runs can still collide without git noticing.

**One branch, two deployment targets (decision D39).** `main` is the only long-lived branch in
every repo: every run, lane, hotfix, knowledge change and ticket commit targets it. A client UAT
environment is optional and is a **deployment target, not a branch**: `/setup` alone declares
`uat: {target, url}` in a repo's `project.json` (both or neither; the seeded stub is empty) —
`target` the slug of a Vercel **custom environment** on each product project (Pro, one per
project; where a team cannot create one, `/setup` refuses the declaration), deployed from `main`
on every merge with its own variables and its own database — on Neon a **second Marketplace
database** (D41: `database.neon.nonprod_project_id`, connected to the environment + Preview, its
default branch UAT, previews and runs inside it; production's database on Production only and
never written by the pipeline), on MongoDB the named `database.mongodb.uat_name` — `url` the
domain attached to it — the client's one fixed address.
Undeclared, every merge is the production release, as it always was. Declared, the operator turns
off **Auto-assign Custom Production Domains**, so every merge builds a **Staged** production
deployment; Release reads the UAT deployment once (`deploy-status.sh --uat`) and announces nothing.
**The batch is `git log <last published release>..origin/main`** — no file, no reset. The client
tests it and says yes; the operator records that word — `promote.sh approve --by "<who>"`, the
operator's act, never an agent's inference (the agency brief's rule 1 stands: no client-facing
gate) — which **drafts** a GitHub Release at the signed-off SHA; **the operator publishes it on
GitHub**, and the reference `release.yaml`, on `release: published`, finds the staged production
deployment of that SHA (missing → fail before anything else), runs the repo's production
migration (the reference `db-migrate.yml`, called — on a UAT repo its `push: main` migrates
nothing), promotes the staged deployment (never a rebuild; already Current → a no-op), reads
production once and announces (reusing the Release's tag). No script publishes or promotes;
nothing promotes on its own; a Release is never unpublished (rollback is Vercel's). **A hotfix
promotes everything before it**: a run not fit for production does not merge, or merges dark.
The operator's Vercel acts are listed by `promote.sh init` and never performed by a script.
The retired branch model fails `setup.sh` outright (a `uat.branch` key, a `.icm/uat/batch.json`).
[`template/icm-pipeline/_shared/promotion.md`](../template/icm-pipeline/_shared/promotion.md)
owns the rule; it replaces D31's UAT branch, batch file, promotion PR and `sync`.

**Ticket state lives on `main` (D39 (8)).** `.icm/intake/` has one home in every repo, UAT or
not: `main`. Every reader — the dashboard, the board scripts, `client-status.sh`'s queue — reads
it there; every writer reaches it either through the run's own PR inside a run, or by a **direct
commit to `main`** outside one (Scope's front included, under its path guard). No ticket PR, no
`--admin`, no ticket base branch; a ruleset that requires checks on `main` keeps the operator's
identity on its bypass list. This supersedes D38 and restores the front's direct push.

**The client's status report is everywhere, and needs no UAT.** `client-status.sh` (template-
owned) compiles `.icm/output/client-status-latest.md` from the pipeline's own records — what
shipped to production and when (the archive on `origin/main` — at the last published Release,
on a UAT repo), what is on UAT (archived on `origin/main` since that Release, where UAT exists), what is in progress (stubs spun out and not merged; the open PRs'
stages when a GitHub route exists), what is queued (the epics in build order) — in the work
items' own titles, never a slug or a SHA. `/pipeline status` runs it; nothing sends it.

## Gates — human checkboxes in the PR body

Anchored so parsing never depends on wording:

```md
<!-- gate:spec-approved -->
- [ ] Spec approved (Define gate — a human ticks this before Build)
<!-- gate:ready-to-merge -->
- [ ] Ready to merge (Release gate — a human ticks this to authorise the squash-merge)
```

- The agent **reads** gates (find the anchor, the next checklist line is the gate) and
  **never ticks either box** — no scripted exception. Unticked → STOP and say so.
- **A missing anchor means "not required", never "unticked".** Lane PRs carry no
  checkboxes at all: their gate is the merge button, which the operator presses in the
  GitHub UI after their own smoke. A spine PR missing an anchor is malformed — fix the
  body first (`project-body.sh <slug> --apply` re-projects it).
- Ticking **Ready to merge** attests the operator's own testing of the change; Release
  re-asks for no manual checks.
- Nothing self-advances across a gate: after each stage, say what's done and which
  `/pipeline <next>` comes when the human is ready.
- **The front's gate has no checkbox** — there is no feature PR yet. The operator reviews
  `scope.md` and the cut on `main` and runs `new` when happy; nothing downstream is cut
  from a scope the operator did not settle.

## Scripts — the deterministic factory

Each is one job, config from the environment and `.icm/project.json` (never `.env`), one
`RESULT:` line last on stdout, documented exit codes. Every GitHub call goes through
`lib/gh.sh` — curl with `GITHUB_TOKEN`/`GH_TOKEN`, else a logged-in `gh` CLI — and
**`GITHUB_REPO` is derived from `origin`** with the env var as an override; the template
ships no repo literal. `lib/project.sh` reads the manifest, with the estate's own defaults
for every key.

| Script | Job | Verdicts |
|---|---|---|
| `resolve-run.sh <slug>` | adopt an existing run (run.md live or archived → branch, else the PR by slug through the pulls listing — never the search API) — **never creates anything** | `READY` 0 · `STOP` 3 |
| `validate-spec.sh <slug\|path>` | spec structure: header fields, five sections, criteria-are-checkboxes | `OK` 0 · `INVALID` 2 |
| `validate-intake.sh <epic\|path>` | the cut's bookkeeping: sequences contiguous, depends-on ordered, build order agrees; triage stubs lane-tagged | `OK` 0 · `SKIP` 0 · `INVALID` 2 |
| `validate-decisions.sh <slug\|path>` | every `\| D-n \|` row of the scope's Decisions table appears in `spec.md` and `notes.md` (the front's own, or the front of the epic behind the stub); a file not yet written is "not yet", never a failure | `OK` 0 · `SKIP` 0 · `MISSING n` 2 |
| `new-run.sh <slug> --summary "…" [--stub …] [--lane …] [--ready] [--base <branch>]` | commit run (+ the canonical file pack, `run-pack.sh --init`) → consume stub → push → open the one PR (draft on the spine and in bug/tweak/chore/handover; **ready** for a hotfix, or with `--ready`) into `main` — the one base (D39) —, body from `project-body.sh`; labels `type:<lane>`; **warns** `[WARN] overlaps <slug> on <path>` when this run's `touches:` shares a surface with a live run (D26) — never refuses | `CREATED` 0 |
| `project-body.sh <slug> [--apply]` | the one implementation of the spine PR body, projected from `spec.md`; `--apply` PATCHes it in place and resets both gate anchors | `APPLIED` 0 |
| `project-labels.sh <slug> --stage <…\|auto>` | project `type`/`stage`/`complexity` from the spec header onto the run's PR (PUT replaces the whole set) — spine runs only | `APPLIED` 0 |
| `ci-status.sh <slug> \| --pr <n>` | block until CI settles; reads check runs **and** commit statuses, dedupes by newest attempt, re-reads the head each pass; required names from `required_checks`, a conditional smoke from `smoke_check` | `GREEN` 0 · `RED` 3 · `PENDING` 4 |
| `close-out.sh <slug>` | copy the run's learned rules into `_shared/project-rules.md` (`run-pack.sh --sync-rules`), then archive the run (and the finished epic, and the front behind it) into `runs_archive` / `intake_archive`, committed **on the run's branch** — refuses `main`, refuses a PR closed unmerged; a dropped stub counts as settled | `CLOSED` 0 · `STOP` 3 |
| `triage-report.sh` | the parking lane's counts by lane / source / area / age, near-duplicates, against the cap | `OK` 0 |
| `env-check.sh [--fix]` | pre-flight: binaries (gitleaks recommended), a GitHub route, `required_env`, `complexity`, `migrations.stamp`, `database.isolation` and its engine, the folder shape (skills parse, run-pack templates present), executable bits (repaired only with `--fix`), a UTF-8 locale, the lockfile's audit tool and a declared `health_endpoint` (reported, never required) | `PASS` 0 · `FAIL` 1 |
| `select-model.sh <epic/slug \| stub \| path \| --complexity <w>> [--stage <s>]` | complexity × stage → tier → alias: three tiers (`haiku` fast · `sonnet` balanced · `opus`/`fable` frontier) and three roles — Scope/Define the **advisor** (tier 3), Build/Release/lanes/subagents the **executor** (tier 2, `opus` on `high`), a lint or format fix the **validator** (`haiku`); without `--stage` the complexity mapping alone; an explicit `recommended-model` wins for the work, never for a validator. Prints the alias, the tier, the role and `flags: --model <alias>`. **A recommendation; launches nothing** | `MODEL <alias>` 0 · `INVALID` 2 |
| `check-migrations.sh [--apply]` · `--new <name> [--apply]` | Build step 10 and Release step 7, after `main` is merged in: are this run's migrations still newer than `main`'s, and in the declared form? Three forms read (`V<17 digits>__name.sql`, the UTC millisecond default; `<14 digits>_name.sql`, legacy `migrations.stamp: seconds`; `<13 digits>-name.<ext>`, the epoch-millisecond form a MongoDB runner such as ts-migrate-mongoose writes — `migrations.stamp: epoch` with `migrations.extension`, D34); only this branch's own are judged. `--apply` re-stamps every local one in order (STALE) or renames into the form (MISNAMED) — renames, never commits, never touches a migration `main` has. `--new` names the next migration after everything that exists; prints the tool's out-of-order setting (`migrations.tool`, `migrations.out_of_order`) | `OK` 0 · `SKIP` 0 · `STALE n` 2 · `MISNAMED n` 2 · `RESTAMPED n` 0 · `RENAMED n` 0 · `NAMED <f>` 0 · `CREATED <f>` 0 |
| `list-skills.sh [--json \| --bare] [--check]` | the Level-1 registry of `.icm/skills/*/SKILL.md` — one line per skill from its front matter (`name`, `description`, `triggers`), for the session-start hook and a stage's Inputs; `--check` validates the three keys, a body, the folder name, a ≤80-token Level 1. Loads nothing | `OK n` 0 · `INVALID n` 2 |
| `db-branch.sh <slug> [status\|up\|env\|down\|prove] [--base ref]` | one database per run, named after the slug: a Neon branch `run/<slug>` (a child of the production branch — of the UAT database in the non-production project on a UAT repo, D41 — 7-day expiry — `database.isolation: neon`, through `lib/neon.sh`), a MongoDB database `run_<slug>` on the repo's one cluster (`isolation: database`, `provider: mongodb`, through `lib/mongo.mjs` and the repo's own driver — `up` runs the repo's `migrate_command up` then `seed_command`, D35), a Postgres schema `run_<slug>` on the variable `database.url_env` names, or a local container `icm-db-<slug>`; `up` records a `- db:` pointer (the variable's NAME) in `run.md`, `env` prints the exports to eval (stdout is only the exports), `down` drops only what `up` made. `prove` (MongoDB, Build step 10 and Release step 7): on a fresh, unseeded `run_<slug>` migrated through exactly the base's migrations (one at a time, `up <name> --single`, past a stamp of this branch's own — the runner follows the stamp), this branch's own migrations up → down → up, collection list and index specs compared — `down` must restore them (`migrations.reversible: true`), the second `up` reproduce the first, and an `up` after the runner forgets them (a re-stamp, replayed) change nothing; out of stamp order the round trip reverts this branch's own one at a time (`down <name> --single`), never a base migration; the seed runs after `PROVEN`. Adopts a live run, never creates one; `none` isolation → SKIP | `BOUND` 0 · `ABSENT` 0 · `ENV` 0 · `RELEASED` 0 · `PROVEN` 0 · `UNPROVEN n` 2 · `SKIP` 0 |
| `db-env.sh [status\|init\|reset-uat\|prune] [--apply] [--days n]` | the environments' databases on a Neon repo (`database.provider: neon`): `status` reads the project once (both on a UAT repo, D41 — production's only ever read) — production (protected or not), the UAT database (the non-production project's default branch), `preview/*` (count), `run/*` (each with its expiry and whether its run is live), every other branch by name, and the product project's build command where a Vercel token is in reach; `init` prints the operator's one-time acts (the key and where it lives, the integration's Preview-branching toggle, the migrate step in the build, protecting production, the cleanup workflow) and which are done; `reset-uat --apply` runs the repo's `database.neon.reset_command` against the UAT database (no parent to reset from; never production); `prune --apply` deletes `run/*` whose run is gone or expired and `preview/*` whose git branch is gone. Dry-run by default; production is never written; no name the pipeline did not give is touched (D32). On a MongoDB repo (`provider: mongodb`, D35) the same verbs on the one cluster: `status` lists production, the shared preview database, the UAT database (`database.mongodb.uat_name`), `preview_*` and `run_*` (each live or not) and every other database by name, against the cluster's caps; `init` lists the database user's rights, Vercel's system variables, the app's one connection line through `lib/db-name.mjs`, the preview-migrate workflow and the smoke check waiting on it, `mongodb-cleanup.yaml`, and last the flag `MONGODB_PREVIEW_PER_BRANCH=1`; `reset-uat --apply` drops the UAT database and re-makes it with the repo's migrate and seed commands (nothing copied from production); `prune --apply` drops `run_*` whose run is archived and `preview_*` whose branch is gone — never `production_name`, `preview_name` or the UAT database | `NEON …` 0 · `MONGODB …` 0 · `INIT` 0 · `DRY-RUN` 0 · `RESET` 0 · `PRUNED n` 0 · `UNCHANGED` 0 · `SKIP` 0 |
| `security-check.sh [<slug>] [--staged\|--branch\|--all] [--audit\|--no-audit] [--strict]` | the zero-trust gate before a commit (Build) or a push (every lane): `gitleaks` over the staged change / the branch / the tree (`gitleaks protect --staged --redact`; a built-in pattern scan as the fallback, said aloud), a real `.env*` in the change set, and `npm\|pnpm\|yarn audit --audit-level=high` (or `security.audit_command`) when a manifest moved or the scope is wider; every finding redacted, the trace appended to the run's `03_build/output/error.log` (a lane: `lane/output/`), exit 1 aborts the commit. Never edits, never rotates, never `--no-verify` | `OK` 0 · `SKIP` 0 · `BLOCKED n` 1 · `FAIL` 1 |
| `run-pack.sh <slug> [--check\|--init\|--sync-rules]` | the canonical file pack for session continuity — `project.md`, `plan.md`, `tasks.md` (DoD from the spec's criteria), `decisions.md` (the scope's `D-n` rows), `status.md`, `handoff.md`, `FAILURE.md` — seeded from `_shared/run-pack/` by `new-run.sh` (never overwritten); `--sync-rules` copies `FAILURE.md` → Learned rules into `_shared/project-rules.md` (append-only, deduplicated, in `retrospective.sh`'s shape — the two writers split one section: error.log's errors there, what no tool logged here), called by `close-out.sh` | `OK` 0 · `MISSING n` 2 · `SEEDED n` 0 · `SYNCED n` 0 |
| `retrospective.sh <slug\|path> [--apply] [--min n]` | Release step 7 and every lane's last act before the close-out: the run's `error.log` (what a stage fixed, entry by entry, with its `- resolved:` / `- rule:` lines) → a signature per entry (`TS2532`, an ESLint rule id, an errno, an exception class, `security-check/<rule id>` for the gate's own entries — the class, never the instance), counted across the archive's `error.log`s; an entry flagged `- rule:`, or one whose signature recurs (`--min`, default 2) and carries a resolution, is a candidate; a signature already in `project-rules.md` is skipped. Reports; `--apply` appends each candidate under `## Learned rules` in the project-owned `_shared/project-rules.md` with its provenance — **never commits, never judges** (the rule is the session's words at the moment of the fix; a slip is deleted by hand before the commit) | `SKIP` 0 · `NONE` 0 · `CANDIDATES n` 0 · `APPENDED n` 0 |
| `process-raw.sh [--dry-run]` | `.icm/raw/` → `.icm/processed/`: extract text with **local** tools only (email, chat export, PDF, deck, image; **audio and video** through ffmpeg + whisper.cpp — `SKIP` with the install hints when either is absent, the recording never uploaded and never committed), log `manifest.json` (extractor, model, language for a transcription), archive the original to `raw/_processed/`, park one triage **pointer** stub per asset — it never scopes, cuts or sequences | `PROCESSED n` 0 · `DRY-RUN n` 0 · `EMPTY` 0 |
| `deploy-status.sh <slug> \| --sha <sha> [--uat]` | Release step 9, **once**: the merge commit's production deployment per `deploy.projects[]`, waited for (bounded), with the previous READY id — the `- production:` line; a deployment the project's Ignored Build Step canceled is `SKIPPED` (production stays on the previous READY, named), never ERROR; `--uat` reads the UAT custom environment's deployment of the SHA instead (product projects only) — the `- uat:` line with the fixed address | `READY` 0 · `ERROR <p>` 3 · `PENDING` 4 · `SKIP` 0 (every project skipped by its ignore step, or no deploy block) |
| `rollback.sh <slug> \| --sha <sha> [--revert] [--vercel]` | **prepares** a recovery: a `claude/hotfix-revert-<slug>` branch + the hotfix PR (through `new-run.sh`), and/or the previous READY deployment with the exact CLI/REST rollback call — printed, never called; warns when the merge carried a migration and `migrations.reversible` is false | `PREPARED …` 0 · `DRY-RUN` 0 · `SKIP` 0 |
| `health-check.sh [--sha <sha>] [--url <u>]…` | Release step 9(a), after `deploy-status.sh`, **once**: one GET per `health_endpoint` in `project.json` (top-level, or per deploy project), 200 expected, three attempts with exponential backoff — the `- health:` line. A failure calls `report.sh alert` (the repo's channels) and parks **one** `lane: bug` · `complexity: high` triage stub per merge SHA — written, never committed; rolls nothing back, opens no lane | `OK` 0 · `FAIL <endpoint>` 3 · `SKIP` 0 · `DRY-RUN` 0 |
| `usage-snapshot.sh <slug> <stage> start\|end` · `--report <slug>` | appends one cumulative `- usage:` line to the run's `usage.md` from the harness's own store (Claude Code transcript · OpenCode SQLite), priced in-repo from `lib/model-prices.json`; `end` is called just before `close-out.sh` so the archive commit carries it, and an `end` after the close-out lands in the archived copy, never a recreated live folder; never estimates, never blocks | `RECORDED` 0 · `SKIP (<why>)` 0 · `REPORT` 0 |
| `env.sh audit\|init\|pull\|push-notes\|add\|doc` | the repo's env across five surfaces, driven by the deploy block: names only; `add` takes the value **on stdin only** and never prints it; `--changed` is Build's pre-push check and Release's stop class 3 | `OK` · `GAPS n` · `SEEDED n` · `PULLED n` · `PUSHED n` · `ADDED …` · `SKIP` · `DOC` |
| `setup.sh [--fix] [--template <path\|url>] [--report]` | the eleven-section report behind `/setup`: baseline (from the repo's own `.icm/MANIFEST`), formatter exposure, `project.json`, environment, tickets, raw, runs, knowledge, reporting, workflows, support; `--fix` seeds what is missing from an explicit source, never overwrites; no default source | `OK` 0 · `GAPS n` 0 |
| `client-status.sh [--out <path>] [--stdout] [--all] [--limit n] [--today d] [--no-fetch] [--no-github]` | the client's view: delivered to production (the archive on `origin/main`, dated by git), ready on UAT (archived on `origin/main` since the last published Release, where declared), in progress (spun-out stubs not merged; PR stages with a GitHub route), queued (epics in build order) — titles only, plain words; writes `.icm/output/client-status-latest.md`; chores and `internal` hidden unless `--all`; sends nothing | `WRITTEN <path> — …` 0 |
| `promote.sh status\|init\|approve --by "<who>" [--note] [--sha] [--announce]` | the UAT batch and the client's word (UAT repos only; `SKIP` elsewhere): `status` — the last published Release, the batch since it (runs and PRs), the staged production deployment of `main`'s head (Staged or Current), the UAT deployment, any draft; `init` — the operator's one-time checklist, marked where readable, performed never; `approve` — **the operator's act** — drafts a GitHub Release `<prefix><date>-promote-<sha7>` at the signed-off SHA (refuses a SHA off `main` or already released, an open draft, an existing tag). **Never publishes, never promotes** | `BATCH n · …` 0 · `INIT` 0 · `DRAFTED <tag>` 0 · `DRY-RUN` 0 · `STOP` 3 · `SKIP` 0 |
| `format.sh` · `lint.sh` (P) | changed-files-only **feedback** before a push — never the verdict, never the full sweep (D21) | `OK` · `SKIP` · … |
| `validate-knowledge-map.sh` (P) | every page the knowledge map names resolves under `docs_path` | `OK` 0 · `SKIP` 0 · `INVALID` 2 |
| `report.sh <announce\|alert\|economics> "<summary>"` (P) | the reporting hook: the kind's channels from `project.json` (`github-release` by default — idempotent by tag; `slack`; `email`); `SKIPPED <channel>: <VAR> unset` names the fix; `--dry-run` prints the payloads; **exit 0 always** | `SENT …` · `SKIPPED (…)` · `DRY-RUN …` — all 0 |

Rules the scripts encode, which are the contract even where repo config wouldn't stop
you: **one PR per run** (`new-run.sh` dies if `run.md` records one) · **adopt or STOP**
(never fabricate a run, a branch, or a `run.md`) · **not-yet-red is not green**
(`PENDING` is a third value; nothing merges or hands off on it) · **no PR-event
subscriptions** — the one blocking `ci-status.sh` call per push is the only CI read ·
**the close-out rides the PR** (`close-out.sh` refuses to run on `main`: a branch with
required status checks refuses a direct push, and an archive commit pushed afterwards
strands where nobody merges it) · **a check name may contain a comma** —
`PIPELINE_REQUIRED_CHECKS` and `required_checks` are newline- and array-separated, never
comma-split.

The label vocabulary is the repo's own — `project-labels.sh` writes `type:feature`,
`stage:*` and `complexity:*` and curates nothing. A repo that wants them coloured and
described defines them itself.

## Where the D3 line runs (decision D11)

The house rule stays: **never build an orchestrator — the folders are the
orchestration.** D11 narrows what that excludes: a *project repo's own* deterministic
one-job scripts, and CI that acts only after a human-authorised merge (an announce, a
verify job), are **factory**, not orchestrator. The close-out is the plainest case: it is
a `git mv` and a commit that a human then merges, which is why it moved onto the branch
rather than into CI. The sync tool is the same kind of thing one level up: it copies
files a human asked it to copy and runs nothing. The line that never moves:

- Nothing advances work across a human gate; nothing triggers the next stage.
- No outbound action leaves a session (an announce is CI's, fired by a merge the operator
  authorised, or a hook the operator wired).
- icm-board itself drives nothing — it describes, checks, seeds, and on request syncs.

If a change makes a stage run itself, that is still the signal to stop.

## Adding a stage or lane

**In the template** — for every pipeline repo: add the folder and its `CONTEXT.md` under
`template/icm-pipeline/`, add a `T` line to the MANIFEST, add the lane word to
`lib/project.sh` → `pipeline_lanes` if it is a lane, add the routing row to the seeded
`/pipeline` skill, and run `icm-sync.sh` per repo. **In one repo only** — add a
numbered folder `.icm/stages/NN_<name>/CONTEXT.md` (or `.icm/lanes/<name>/`), a row to
the repo's `/pipeline` routing table, and a note in its `_shared/project-rules.md`;
`icm-check.sh` will list it as "not in the template's manifest" so the addition stays
visible. Either way the pipeline grows in the folder tree, not the skills list. Asked for
*in* a repo, the estate-wide form is a template change request (D33) — the repo's session
writes the prompt, icm-board makes the change.
