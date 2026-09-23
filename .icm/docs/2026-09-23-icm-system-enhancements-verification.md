# Verification — the five system enhancements (D29), 2026-09-23

*What shipped from `.icm/docs/2026-09-23-icm-system-enhancements-directive.md`, how it was
proven, and what is not proven yet. Decision: `.icm/project.md` → D29. Branch
`claude/icm-system-enhancements-51ef33`, merged over D27 (the retrospective collector, #48).*

## Method

The template cannot be run in place — it is a template. A scratch repository was built from
it the way `icm-sync.sh` and `icm-check.sh --fix` would build one (every `MANIFEST` line copied
into `.icm/`, scripts `+x`, `project.json` named), with a bare `origin` so `origin/main`
resolves, and — for the two scripts that talk to GitHub — a local stand-in for the REST API
(`GITHUB_API_URL` pointed at a Python `http.server` answering the PR, pulls and labels
routes). Nothing reached the network; nothing was run against a real repository. gitleaks,
psql and docker are not installed on this machine, so those paths were exercised only up to
their `SKIP`/fallback branches.

## What was proven

| capability | what ran | result |
|---|---|---|
| **1 · Skills** | `list-skills.sh` (markdown, `--json \| jq`, `--bare`, `--check`) over the three seeded skills; `env-check.sh` step 4 | `OK 3`; JSON pipes clean (verdict on stderr); Level 1 of each skill under the 80-token ceiling; the session-start hook's registry line reads from `--bare` |
| **2 · Model routing** | `select-model.sh` — the directive's own check `--stage 01_scope --complexity high`; every stage word; a stub with `recommended-model`; `--json`; bad words | `opus` (advisor); `research` → `fable`; Build `high` → `opus`, `standard` → `sonnet`; `pre-commit`/`lint` → `haiku` even on an `opus` stub (the override never reaches a validator); no `--stage` → the D22 mapping unchanged; `INVALID` exit 2 on a bad stage or complexity |
| **3 · Databases + migrations** | `db-branch.sh` with `isolation: none` / `schema` (no psql) / `container` (no docker); `env` verb stdout; a run that does not exist; a bad slug. `check-migrations.sh --new`, `MISNAMED` → `RENAMED`, `STALE` → `RESTAMPED`, the `seconds` form, the same-second collision | `SKIP` on every unavailable path, `env` prints nothing to stdout when it cannot bind; exit 1 for a missing run. New files are named `V<17>__<name>.sql` after main's newest; a legacy-form local is renamed with its stamp kept; when main advanced, both locals re-stamped one millisecond apart in order; in the `seconds` form two locals that would share a second are re-stamped instead of collapsed |
| **4 · Security gate** | staged AWS key + a DB URL with a password on a real host + a `localhost` placeholder; a real `.env`; a placeholder in `.env.example`; nothing staged; `--branch`; `--strict` with and without a finding; a `ghp_` token in the integration run | `BLOCKED` with the redacted trace (`AKIA…[redacted]`; the password never appears in `error.log`); the `localhost`/`password@` placeholder allowed; `.env` blocked on its name alone; `OK` on the placeholder; `SKIP` with nothing staged; `--strict` fails when gitleaks is absent; the `error.log` entry is in D27's shape and `retrospective.sh` lists it as unresolved until the session adds `- resolved:` |
| **5 · Run pack** | `run-pack.sh --check/--init/--sync-rules` on a spine run with a spec and a scope behind its stub, and on a front run; `new-run.sh` end to end (stubbed API); `close-out.sh` end to end | Seven files seeded once, never overwritten; placeholders replaced (`status.md` reads `phase: define`, `project.md` carries the stub, scope, spec, touches and the executor model, `tasks.md` the spec's criteria as its DoD, `decisions.md` the scope's `D-n` rows); `new-run.sh` commits the pack with `run.md` (and now records `- stub:`, which `validate-decisions.sh` needs to find the scope); `close-out.sh` appends the run's learned rules to `_shared/project-rules.md` in `retrospective.sh`'s shape, staged in the same archive commit, deduplicated on a second run |

`env-check.sh` → `PASS` with the new checks (gitleaks recommended, `migrations.stamp`,
`database.isolation`, skills parse, run-pack templates, the skills' runnables `+x`).
`setup.sh --report` reads the 66-line manifest and reports the `.claude/` assets the scratch
repo deliberately lacked. Every new and changed script passes `bash -n`; there is no shellcheck
on this machine and none in CI for template scripts (`self-check.yml` covers `_system/scripts/`).

## What is not proven

- **gitleaks itself** — only the fallback ran. The `gitleaks git --staged` / `protect --staged`
  branch is written against the documented CLI and not executed.
- **A real database** — `db-branch.sh up/env/down` against Postgres (schema and container modes)
  ran only to the `SKIP` that a missing `psql`/`docker` produces.
- **npm/pnpm/yarn audit** — the lab had no lockfile; the parsing of `--json` output is written
  against the documented shapes and not executed.
- **A real GitHub** — `new-run.sh` and `close-out.sh` were driven through a stand-in API that
  answers what they ask; label projection ran against a fixed label list.
- **The estate** — nothing is synced. Every pipeline repo (sustentus, remi-ai) drift-reports the
  changed T files and the fifteen new ones until `icm-sync.sh --apply`; `setup.sh` reports the
  new files missing until then. That rollout is its own session, and its first real migration,
  first real secret and first real `error.log` are the first real inputs.
- **The contracts as a whole** — the stage and lane text was edited by hand around the merge
  with D27; a Build or Release run reading them end to end is the proof that the steps still
  read as one procedure.

## Reconciliation with D27 (the retrospective collector)

Both directives landed the same day. D27's `retrospective.sh` learns from `error.log`; this
directive's `FAILURE.md` is "synced to project-rules on close-out". They now split one job with
one shape: `error.log` is the ledger of what a **tool** reported (a RED, a `lint.sh` finding, a
`security-check.sh` block), written verbatim at the fix with `- resolved:`/`- rule:` lines and
read by the collector; `FAILURE.md` is what the run learned that **no tool logged** — a wrong
assumption, a STOP, a rewritten plan — and its `## Learned rules` reach the same section through
`close-out.sh` (`run-pack.sh --sync-rules`) with the same `<!-- Retrospective Learned Rule -->`
stamp. The gate writes its entry in the collector's shape and leaves the `- resolved:` line to
the session, so an unfixed leak is listed as unresolved, never promoted.
