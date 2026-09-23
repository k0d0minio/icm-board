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
    03_build/CONTEXT.md      ← implement the approved spec; env.sh audit --changed; flip  (T)
    04_release/CONTEXT.md    ← gate read → review → close-out → squash-merge → one read of
                                production → report.sh announce                            (T)
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
  _shared/
    github.md                ← PR regimes, gate anchors, the never-tick rule               (T)
    ci.md                    ← GREEN / RED / PENDING and what green means                  (T)
    stage-preamble.md        ← resolve the run or STOP; run-scoped isolation               (T)
    scope-template.md        ← the shape of a settled scope; the D-n table                 (T)
    conventions.md           ← redirect to the repo's code rules                           (T)
    run-pack/*.md            ← the seven canonical run files run-pack.sh seeds              (T)
    project-rules.md         ← what is true of THIS repo: people, factory, reporting, support,
                                and the Learned rules retrospective.sh (error.log) and
                                close-out (FAILURE.md) append                              (P)
    knowledge-map.md         ← which docs page each stage reads                            (P)
  scripts/
    lib/{gh,changed-files,project,vercel}.sh  lib/model-prices.json                       (T)
    resolve-run.sh validate-spec.sh validate-intake.sh validate-decisions.sh new-run.sh
    project-body.sh project-labels.sh ci-status.sh close-out.sh triage-report.sh
    env-check.sh select-model.sh check-migrations.sh process-raw.sh
    deploy-status.sh rollback.sh usage-snapshot.sh env.sh setup.sh retrospective.sh
    list-skills.sh db-branch.sh security-check.sh run-pack.sh                             (T)
    format.sh lint.sh validate-knowledge-map.sh report.sh                                 (P)
.claude/skills/pipeline/SKILL.md   ← the /pipeline router (one skill, many stages)
.claude/skills/setup/SKILL.md      ← /setup: the report, the questions, the P files
.github/pull_request_template.md   ← carries both gate anchors
.github/workflows/{release,labels}.yaml ← reference workflows, seeded ONCE by /setup (announce_from: ci)
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
from *that*, and pushes it all straight to `main`. A front opens no PR. A repo whose work
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
- **The front's gate has no checkbox** — there is no PR yet. The operator reviews
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
| `new-run.sh <slug> --summary "…" [--stub …] [--lane …] [--ready]` | commit run (+ the canonical file pack, `run-pack.sh --init`) → consume stub → push → open the one PR (draft on the spine and in bug/tweak/chore/handover; **ready** for a hotfix or with `--ready`), body from `project-body.sh`; labels `type:<lane>`; **warns** `[WARN] overlaps <slug> on <path>` when this run's `touches:` shares a surface with a live run (D26) — never refuses | `CREATED` 0 |
| `project-body.sh <slug> [--apply]` | the one implementation of the spine PR body, projected from `spec.md`; `--apply` PATCHes it in place and resets both gate anchors | `APPLIED` 0 |
| `project-labels.sh <slug> --stage <…\|auto>` | project `type`/`stage`/`complexity` from the spec header onto the run's PR (PUT replaces the whole set) — spine runs only | `APPLIED` 0 |
| `ci-status.sh <slug> \| --pr <n>` | block until CI settles; reads check runs **and** commit statuses, dedupes by newest attempt, re-reads the head each pass; required names from `required_checks`, a conditional smoke from `smoke_check` | `GREEN` 0 · `RED` 3 · `PENDING` 4 |
| `close-out.sh <slug>` | copy the run's learned rules into `_shared/project-rules.md` (`run-pack.sh --sync-rules`), then archive the run (and the finished epic, and the front behind it) into `runs_archive` / `intake_archive`, committed **on the run's branch** — refuses `main`, refuses a PR closed unmerged; a dropped stub counts as settled | `CLOSED` 0 · `STOP` 3 |
| `triage-report.sh` | the parking lane's counts by lane / source / area / age, near-duplicates, against the cap | `OK` 0 |
| `env-check.sh [--fix]` | pre-flight: binaries (gitleaks recommended), a GitHub route, `required_env`, `complexity`, `migrations.stamp`, `database.isolation` and its engine, the folder shape (skills parse, run-pack templates present), executable bits (repaired only with `--fix`), a UTF-8 locale | `PASS` 0 · `FAIL` 1 |
| `select-model.sh <epic/slug \| stub \| path \| --complexity <w>> [--stage <s>]` | complexity × stage → tier → alias: three tiers (`haiku` fast · `sonnet` balanced · `opus`/`fable` frontier) and three roles — Scope/Define the **advisor** (tier 3), Build/Release/lanes/subagents the **executor** (tier 2, `opus` on `high`), a lint or format fix the **validator** (`haiku`); without `--stage` the complexity mapping alone; an explicit `recommended-model` wins for the work, never for a validator. Prints the alias, the tier, the role and `flags: --model <alias>`. **A recommendation; launches nothing** | `MODEL <alias>` 0 · `INVALID` 2 |
| `check-migrations.sh [--apply]` · `--new <name> [--apply]` | Build step 10 and Release step 7, after `main` is merged in: are this run's migrations still newer than `main`'s, and in the declared form? Both forms read (`V<17 digits>__name.sql`, the UTC millisecond default; `<14 digits>_name.sql`, legacy `migrations.stamp: seconds`); only this branch's own are judged. `--apply` re-stamps every local one in order (STALE) or renames into the form (MISNAMED) — renames, never commits, never touches a migration `main` has. `--new` names the next migration after everything that exists; prints the tool's out-of-order setting (`migrations.tool`, `migrations.out_of_order`) | `OK` 0 · `SKIP` 0 · `STALE n` 2 · `MISNAMED n` 2 · `RESTAMPED n` 0 · `RENAMED n` 0 · `NAMED <f>` 0 · `CREATED <f>` 0 |
| `list-skills.sh [--json \| --bare] [--check]` | the Level-1 registry of `.icm/skills/*/SKILL.md` — one line per skill from its front matter (`name`, `description`, `triggers`), for the session-start hook and a stage's Inputs; `--check` validates the three keys, a body, the folder name, a ≤80-token Level 1. Loads nothing | `OK n` 0 · `INVALID n` 2 |
| `db-branch.sh <slug> [status\|up\|env\|down]` | one database per run, named after the slug: a Postgres schema `run_<slug>` on the variable `database.url_env` names, or a local container `icm-db-<slug>`; `up` records a `- db:` pointer (the variable's NAME) in `run.md`, `env` prints the exports to eval (stdout is only the exports), `down` drops only what `up` made. Adopts a live run, never creates one; runs no migration; `none` isolation → SKIP | `BOUND` 0 · `ABSENT` 0 · `ENV` 0 · `RELEASED` 0 · `SKIP` 0 |
| `security-check.sh [<slug>] [--staged\|--branch\|--all] [--audit\|--no-audit] [--strict]` | the zero-trust gate before a commit (Build) or a push (every lane): `gitleaks` over the staged change / the branch / the tree (`gitleaks protect --staged --redact`; a built-in pattern scan as the fallback, said aloud), a real `.env*` in the change set, and `npm\|pnpm\|yarn audit --audit-level=high` (or `security.audit_command`) when a manifest moved or the scope is wider; every finding redacted, the trace appended to the run's `03_build/output/error.log` (a lane: `lane/output/`), exit 1 aborts the commit. Never edits, never rotates, never `--no-verify` | `OK` 0 · `SKIP` 0 · `BLOCKED n` 1 · `FAIL` 1 |
| `run-pack.sh <slug> [--check\|--init\|--sync-rules]` | the canonical file pack for session continuity — `project.md`, `plan.md`, `tasks.md` (DoD from the spec's criteria), `decisions.md` (the scope's `D-n` rows), `status.md`, `handoff.md`, `FAILURE.md` — seeded from `_shared/run-pack/` by `new-run.sh` (never overwritten); `--sync-rules` copies `FAILURE.md` → Learned rules into `_shared/project-rules.md` (append-only, deduplicated, in `retrospective.sh`'s shape — the two writers split one section: error.log's errors there, what no tool logged here), called by `close-out.sh` | `OK` 0 · `MISSING n` 2 · `SEEDED n` 0 · `SYNCED n` 0 |
| `retrospective.sh <slug\|path> [--apply] [--min n]` | Release step 7 and every lane's last act before the close-out: the run's `error.log` (what a stage fixed, entry by entry, with its `- resolved:` / `- rule:` lines) → a signature per entry (`TS2532`, an ESLint rule id, an errno, an exception class — the class, never the instance), counted across the archive's `error.log`s; an entry flagged `- rule:`, or one whose signature recurs (`--min`, default 2) and carries a resolution, is a candidate; a signature already in `project-rules.md` is skipped. Reports; `--apply` appends each candidate under `## Learned rules` in the project-owned `_shared/project-rules.md` with its provenance — **never commits, never judges** (the rule is the session's words at the moment of the fix; a slip is deleted by hand before the commit) | `SKIP` 0 · `NONE` 0 · `CANDIDATES n` 0 · `APPENDED n` 0 |
| `process-raw.sh [--dry-run]` | `.icm/raw/` → `.icm/processed/`: extract text with **local** tools only (email, chat export, PDF, deck, image; **audio and video** through ffmpeg + whisper.cpp — `SKIP` with the install hints when either is absent, the recording never uploaded and never committed), log `manifest.json` (extractor, model, language for a transcription), archive the original to `raw/_processed/`, park one triage **pointer** stub per asset — it never scopes, cuts or sequences | `PROCESSED n` 0 · `DRY-RUN n` 0 · `EMPTY` 0 |
| `deploy-status.sh <slug> \| --sha <sha>` | Release step 9, **once**: the merge commit's production deployment per `deploy.projects[]`, waited for (bounded), with the previous READY id — the `- production:` line | `READY` 0 · `ERROR <p>` 3 · `PENDING` 4 · `SKIP` 0 (no deploy block) |
| `rollback.sh <slug> \| --sha <sha> [--revert] [--vercel]` | **prepares** a recovery: a `claude/hotfix-revert-<slug>` branch + the hotfix PR (through `new-run.sh`), and/or the previous READY deployment with the exact CLI/REST rollback call — printed, never called; warns when the merge carried a migration and `migrations.reversible` is false | `PREPARED …` 0 · `DRY-RUN` 0 · `SKIP` 0 |
| `usage-snapshot.sh <slug> <stage> start\|end` · `--report <slug>` | appends one cumulative `- usage:` line to the run's `usage.md` from the harness's own store (Claude Code transcript · OpenCode SQLite), priced in-repo from `lib/model-prices.json`; never estimates, never blocks | `RECORDED` 0 · `SKIP (<why>)` 0 · `REPORT` 0 |
| `env.sh audit\|init\|pull\|push-notes\|add\|doc` | the repo's env across five surfaces, driven by the deploy block: names only; `add` takes the value **on stdin only** and never prints it; `--changed` is Build's pre-push check and Release's stop class 3 | `OK` · `GAPS n` · `SEEDED n` · `PULLED n` · `PUSHED n` · `ADDED …` · `SKIP` · `DOC` |
| `setup.sh [--fix] [--template <path\|url>] [--report]` | the eleven-section report behind `/setup`: baseline (from the repo's own `.icm/MANIFEST`), formatter exposure, `project.json`, environment, tickets, raw, runs, knowledge, reporting, workflows, support; `--fix` seeds what is missing from an explicit source, never overwrites; no default source | `OK` 0 · `GAPS n` 0 |
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
visible. Either way the pipeline grows in the folder tree, not the skills list.
