# Agency DevOps Brainstorm — what the pipeline template still owes an agency

*Research and interview pass, 2026-09-22, on branch `claude/icm-pipeline-devops-research-e0196c`.
Scope: `_system/template/icm-pipeline/`, `_system/scripts/`, `projects/sustentus/.icm/` plus its
`.github/workflows/` (the reference implementation), and — for the usage-source question — the
two harnesses as installed on this machine (Claude Code 2.1.271, OpenCode 1.18.30). No downstream
repo was touched. Every finding names the file or command it was read from.*

*This document is the whole brief for one implementation session. It replaces a backlog: there
are no stubs behind it, and none should be cut from it. §7 is the build order, §8 the definition
of done, §9 the constraints, §10 the points research settled.*

## Summary

The pipeline is complete for the thing it was built for: one operator, one repo, Vercel, Slack.
What it does not yet carry is the agency layer around that — the same machine running in twenty
client repos, each with a different way of reporting, none of them with a `#alerts` channel, all
of them needing a cost number per client and a way back when a release goes wrong. Eight decisions
were settled in session (§3); one correction arrived mid-session and reshapes the reporting side:
**only sustentus has an alert channel, so reporting must be abstracted into message kinds that a
repo maps to whatever it has — including nothing.**

The shape of the answer is the shape the template already uses: a few more `- key:` lines in the
plain-text surfaces a run already carries, a few more one-job scripts that end in one `RESULT:`
line, two new objects in the project-owned `project.json`, one new lane, and one global OpenCode
plugin on Jamie's machine. Nothing starts itself, nothing crosses a gate, nothing reverts
production without a human.

## 1. What was examined

| Layer | Files and commands |
|---|---|
| Template contracts | `stages/0{1..4}_*/CONTEXT.md`, `lanes/{bug,tweak,chore,knowledge}/CONTEXT.md`, `intake/CONTEXT.md`, `_shared/{ci,github,stage-preamble,scope-template,project-rules,conventions,knowledge-map}.md`, `runs/README.md`, `raw/README.md`, `MANIFEST`, `project.json` |
| Template scripts | all 22 under `scripts/` and `scripts/lib/` |
| Estate scripts | `icm-sync.sh`, `icm-check.sh` (via MANIFEST), `vercel-env.sh` + `vercel-env-registry.json`, `_system/template/claude/hooks/vercel-env-hydrate.sh`, `_system/template/root/opencode.jsonc` |
| Sustentus | `.icm/project.json`, `.icm/CONTEXT.md`, `_shared/project-rules.md`, `scripts/notify.sh`, `docs/token-metrics.md`, the archived `deployment-economics` epic, `.github/workflows/{release,preview-smoke,db-migrate,quality,daily-digest}.yaml`, `.github/scripts/state-of-play.mjs`, skills `production-readiness`, `changelog-entry`, `browser-smoke`, `notification` |
| Business layer | `_system/contracts/{PIPELINE,CLIENTS,WORKSPACES}.md`, `_system/knowledge/*`, `workspaces/start/**`, `workspaces/deals/*/DEAL.md`, `.icm/project.md` D1–D22, `.icm/docs/2026-09-02-opencode-parity-report.md`, `intake/opencode-executor/` |
| Claude Code (this session) | `env` inside the Bash tool; `~/.claude/projects/<cwd-slug>/<session>.jsonl` and `<session>/subagents/`; docs `code.claude.com/docs/en/hooks` |
| OpenCode (this machine) | `opencode --help`, `export`, `stats`, `session list --format json`; read-only `sqlite3` over `~/.local/share/opencode/opencode.db`; `strings` on the binary; `~/.config/opencode/plugins/*.js`; `@opencode-ai/plugin/dist/index.d.ts` (1.18.25); docs `opencode.ai/docs/{plugins,server,sdk,cli}` |
| Vercel | `search_vercel_documentation`: `/v6/deployments` (query `sha`, `target`, `state`), `/v13/deployments/{id}`, `POST /v1/projects/{id}/rollback/{dpl}`, `POST /v10/projects/{id}/promote/{dpl}` |

## 2. How the pipeline works today — the surfaces and the seams

**The edit surfaces are plain text, and every one is already a place a script appends to.**

| Surface | Written by | Read by | Shape |
|---|---|---|---|
| `01_scope/_source/story.md` | Scope, once | everyone, never edited | verbatim source under a provenance header |
| `01_scope/output/scope.md` | Scope | Define, the operator, the business | source reproduced + `D-n` decisions table; canonical until `spec.md` |
| `02_define/output/spec.md` | Define, `revise` | Build, Release, `project-body.sh`, `project-labels.sh`, `validate-spec.sh` | `- key:` header + five sections; the PR body is a one-way projection |
| `03_build/output/notes.md` | Build; Release **appends** `## Release` | Release, the labels job, `release.yaml`'s completeness check | `- key:` lines + sections |
| `run.md` | Scope; `new-run.sh` **appends** `branch:` + `pr:` | `resolve-run.sh`, `ci-status.sh`, `close-out.sh` | pointer index of `- key:` lines |
| the intake stub | Scope's cut | Define, `select-model.sh`, `validate-intake.sh` | `- key:` header + four sections |
| the changelog page (sustentus) | Release / lanes | `release.yaml`, the help-centre index | one MDX file = changelog + ship note + Slack post |

A new fact about a run is a new `- key:` line or a new run-scoped file; a new check is a script
ending in `RESULT:`; the archive keeps both forever.

**The gates.** Two PR checkboxes, both the operator's (`_shared/github.md` → Gates); the scope
review on `main` before `new`; the merge button for lanes. "The business's involvement ends when
the scope is settled at Scope" — `02_define` step 7 and `github.md`.

**The factory seam.** `ci-status.sh` reads two GitHub surfaces (check runs + commit statuses,
where Vercel lands), classifies noise/advisory/skipped, waits, and prints one verdict.
`required_checks` and `smoke_check` in `project.json` are the only repo-specific inputs. The
Vercel dependency is implicit: a skip is recognised by the status *description*, and
`smoke_check.preview_status` is a Vercel context string.

**The announce and close-out seam.** Release step 9 hands a one-line summary to `notify.sh` and
otherwise leaves announcing to "a CI workflow the repo owns". `close-out.sh` rides in the PR.
**The template ships no workflow at all**: the labels job, the release workflow, the smoke walk,
the migrations and the digest are all sustentus's own (`contracts/PIPELINE.md` → `pipeline-full`:
"not templated — sustentus is its only instance"). The MANIFEST is rooted at `.icm/`, so it
*cannot* seed `.github/`.

**What sustentus adds on top:** `release.yaml` (announce from the changelog page to
`#product-update`, verify the archive landed, faults to `#alerts`); `preview-smoke.yaml`
(six-persona walk on the `status` event, writes the `Preview smoke` check on the PR head);
`db-migrate.yaml` (forward-only, preview on PR, production on `main` behind an environment gate);
`quality.yaml` (tiered, draft-aware); `daily-digest.yaml` + `state-of-play.mjs` (delivery
economics — Actions billing, runs, pushes, Vercel; infra proxies only).

## 3. What was settled in session

| # | Domain | Decision (Jamie, 2026-09-22) |
|---|---|---|
| 1 | Client sign-off | **The operator signs off on the client's behalf.** No client-facing gate, no new artifact. |
| 2 | Deploy targets | **Vercel only** — made explicit by a `deploy` object in `project.json`. |
| 3 | Cost tracking | **Per stage, on the run, plus a per-client roll-up.** Tokens first, list-price USD second; margin, never an invoice line (the rate card has no hourly rate). |
| 4 | Rollback | **A `hotfix` lane plus a `rollback.sh` that prepares the recovery and stops.** A human merges or clicks. |
| 5 | Channels | **Slack via CI on merge** (reference shape), **client email via Resend**, **a GitHub Release per merge.** Not Discord, not Linear/Jira. |
| 6 | Health check | **Release step 9 reads production once** via the Vercel API and records READY/ERROR in the Release record. No standing workflow. |
| 7 | Roll-up home | **An icm-board script writes `workspaces/deals/<slug>/economics.md`** — read-only, human-invoked, no new store. |
| 8 | Hotfix entry | **Always human-invoked.** No alert-carried command, no auto-parked stub. |
| — | Correction | **There is no alert channel across projects; only sustentus has one.** Reporting is abstracted so a repo can plug in several forms of reporting — or none. |
| — | Delivery | **No stubs.** This document is the brief for one session that does all of it. |

Decisions 6 and 8 together mean the pipeline never *watches* production: it looks once at the end
of Release, writes what it saw, and the human decides. That removes the alert channel from the
health-check path entirely.

## 4. Gaps, by domain

### 4.0 Reporting is not abstracted (the correction)

**Evidence.** `_shared/project-rules.md` (stub) has one section, *Announcing*, with two slots:
`notify.sh` and a changelog. `notify.sh` takes one argument and knows one kind of message. The
contracts say "the project's alert channel (→ Announcing), where it has one" (`04_release` step 9,
`lanes/bug` step 5, `github.md` regime 3, `close-out.sh` header) — hedged in wording, but there is
no place a repo without a channel can say so and no path by which an alert reaches anyone in such
a repo. In sustentus both channels are hard-wired as IDs in `release.yaml`
(`PRODUCT_UPDATE_CHANNEL_ID`, `ALERTS_CHANNEL_ID`) and `notify.sh` is deliberately inert.

**Recommendation — one project-owned hook, message kinds, channels as configuration.**

- `scripts/report.sh <kind> "<summary>" [--url <link>] [--body <file>]` (P, seeded once) replaces
  `notify.sh`. Kinds: `announce | alert | economics`. It reads `project.json → reporting` (§6)
  mapping each kind to a list of channels, and each channel to the *names* of the environment
  variables that carry its secrets. Channels shipped in the stub, all implemented, none configured:
  `slack` (bot token + channel id, or an incoming webhook), `email` (Resend), `github-release`
  (via `lib/gh.sh`). Exit 0 always; last line `RESULT: SENT <channels> | SKIPPED (no channel for
  <kind>)`. A configured channel whose variable is absent prints `SKIPPED <channel>: <VAR> unset`
  (the remi-ai precedent) so a cloud session without the secret loses nothing.
- **The zero-config alert is a red job.** Where `alert` maps to no channel, the CI workflow that
  found the fault fails, and GitHub's own notification to the repository owner is the alert.
  Vercel's own deployment-failed email is the second free channel. Both are written into the
  `project-rules.md` stub so "none" is a recorded decision, not a hole.
- Every template-owned caller — Release step 9, the lanes' step 5, the reference release workflow
  (§4.7) — calls `report.sh` and never a channel. Sustentus's `release.yaml` becomes
  `report.sh announce` + `report.sh alert` with the channel IDs moved into `project.json`.
  `notify.sh` leaves the MANIFEST (reported for `git rm`, never deleted by a script).

### 4.1 Client review and sign-off — decided: no change

**Evidence.** Scope's writing rule already produces the client-readable artifact ("the operator
could hand it to the business as-is", `01_scope` → Verify); `scope.md` records `agreed:`, `run.md`
records `author/source:`, the `D-n` table is the audit trail. Nothing records that the business
*saw* the settled scope; the deal folder and the run never reference each other.

**As decided:** nothing to close. Where a scope *was* sent to the client, Scope may add
`- shared-with: <who>, <date>, via <medium>` under the header — optional, unread by any script.

### 4.2 Deployment targets — decided: Vercel, made explicit

**Evidence.** Vercel is assumed in five places and declared in none: `ci.md`, `ci-status.sh`
(skip detection by description text), `project.json → smoke_check.preview_status`,
`_system/scripts/vercel-env.sh` (estate-local, three teams, per-team token names in
`vercel-env-registry.json`), and the cloud hook `vercel-env-hydrate.sh` (plain `VERCEL_TOKEN`,
resolves the project by git remote). The repo → Vercel project → team mapping lives only in
icm-board's registry — invisible to a cloud session, which is the deciding fact in §10.

**Recommendation.**
- `project.json → deploy` (P; §6): platform, team slug, the token's *variable name*, and one entry
  per Vercel project with its name, `path`, status context, `product | quiet` class and production
  URL. `/project` § 1c fills it at onboarding from the same API lookup the hydrate hook makes
  (`GET /v9/projects?repoUrl=…`), confirmed by Jamie.
- `scripts/lib/vercel.sh` (T, new) — the one Vercel transport, the way `lib/gh.sh` is the GitHub
  one: curl + the token named by `deploy.token_env`, falling back to plain `VERCEL_TOKEN` in a
  cloud session exactly as the hydrate hook does; `vercel_get`, `vercel_deployments <project>
  [--target production] [--sha <sha>]` (`GET /v6/deployments`), `vercel_deployment <id>`
  (`GET /v13/deployments/{id}`), and `--check`. No write verb lives here.
- `env-check.sh`: when `deploy` is present, verify the Vercel route (`[WARN]` when the token is
  absent, `[FAIL]` only when `deploy` names a project the team does not have).
- `ci-status.sh`: read `deploy.projects[].status_context` for the product class and report a
  product project with *no* status on a ready head as `[INFO] expected, not yet posted`.
  Verdict arithmetic unchanged.

### 4.3 Post-release health check — decided: one read at Release step 9

**Evidence.** The preview smoke is pre-merge only. After the merge, `release.yaml` announces and
checks the archive; production state is a one-off Vercel read the `production-readiness` skill
*asks* for and no contract *obliges*. There is no error tracker ("Observability honesty").

**Recommendation.**
- `scripts/deploy-status.sh <slug|--sha <sha>>` (T, new): for every `deploy.projects[]` entry,
  find the production deployment of the merge commit (`vercel_deployments … --target production
  --sha <sha>`), wait until `state` settles (`READY | ERROR | CANCELED`, bounded like
  `ci-status.sh`), and print per project: state, URL, deployment id, **and the previous READY
  production deployment's id** (`rollbackCandidate=true`, newest before this one). Last line
  `RESULT: READY | ERROR <project> | PENDING`. Read-only.
- `04_release` step 9 gains one call after the merge and the Release record gains one line:
  `- production: READY on <sha> — web dpl_… (prev dpl_…) · docs dpl_… | ERROR web — see hotfix`.
  `ERROR` un-merges nothing and starts nothing: it is written down, said plainly in the stop
  message, and the human opens the hotfix lane. `PENDING` after the bound is recorded as such.
  Where `deploy` is absent: `- production: not declared (no deploy block)`.

### 4.4 Token and cost tracking — decided: per stage on the run, plus a per-client roll-up

**Evidence in the pipeline.** Nothing is recorded. Sustentus's `docs/token-metrics.md`
(2026-09-15) designed a per-stage `- usage:` line sourced from the cloud session record and left
it unimplemented; its survey of sources holds and is extended below with what this machine
actually exposes. The cost figure is a **list-price estimate** everywhere; on a subscription it is
a proxy, not a bill. `pricing.md` has no hourly rate, so the number is a margin input against the
deal's `Value` row, never a line a client sees.

#### 4.4a The usage sources — verified on this machine, 2026-09-22

| | Claude Code (local and cloud) | OpenCode 1.18.30 |
|---|---|---|
| **How a script finds its own session** | `CLAUDE_CODE_SESSION_ID` is exported to every Bash tool call (this session: `2aae8848-…`, equal to the transcript's filename). `CLAUDE_PROJECT_DIR` is exported too. Not `CLAUDE_ENV_FILE` — that mechanism is reported broken or empty in the wild (claude-code issues #15840, #11649) and is not needed. | Nothing is exported by default (the binary's `OPENCODE_*` set has no session variable). The plugin API provides it: `shell.env(input: {cwd, sessionID?, callID?}, output: {env})` — a global plugin sets `output.env.OPENCODE_SESSION_ID = input.sessionID`, with `tool.execute.before(input: {tool, sessionID, callID})` as the fallback that always carries it (`@opencode-ai/plugin` 1.18.25 `index.d.ts`). Verify on the binary, per the standing rule — the types have been stale before. |
| **Where the numbers are** | The transcript `~/.claude/projects/<cwd-slug>/<session>.jsonl` (cloud: `/root/.claude/projects/-home-user-<repo>/…`, verified in the sustentus note). Every API response is a `type: "assistant"` line with `requestId`, `message.model`, `message.usage = {input_tokens, cache_creation_input_tokens, cache_read_input_tokens, output_tokens, output_tokens_details.thinking_tokens, …}` and an ISO `timestamp`. Streaming repeats a `requestId` (this session: 113 lines, 18 requests) — take the **last line per `requestId`**. The `<cwd-slug>` is the working directory with every non-alphanumeric character replaced by `-` (`.claude` → `-claude`); `find ~/.claude/projects -name "$CLAUDE_CODE_SESSION_ID.jsonl"` sidesteps the encoding. | SQLite at `~/.local/share/opencode/opencode.db` (override: `OPENCODE_DB`; `XDG_DATA_HOME` respected). `session` rows carry cumulative `cost`, `tokens_input`, `tokens_output`, `tokens_reasoning`, `tokens_cache_read`, `tokens_cache_write`, `model` (JSON `{id, providerID}`), `directory`, `project_id`, `parent_id`. `message` rows carry per-response `data.tokens {input, output, reasoning, cache{read, write}}`, `data.cost`, `data.modelID`, `data.providerID`, `data.path.cwd`, `data.time {created, completed}` (epoch ms). Read it with `?mode=ro`; WAL is fine. |
| **Subagents** | Sibling files under `<session>/subagents/*.jsonl` — same line shape; sum them in. | Child sessions: `session.parent_id = <id>` — sum the children (`client.session.children` in the SDK; one `WHERE parent_id = ?` in SQL). |
| **Cost** | Not in the transcript. Priced at roll-up from one estate table (below); `cost_usd=unknown` on the line. The cloud session record (`get_session` → `external_metadata.usage.cost_usd`) is a cross-check, not the source. | On the row and on every message, computed by OpenCode from the models.dev catalogue: `$0.0221` across 14 `vercel/zai/glm-5.3-flash` sessions; `0` for Zen free models (`opencode/big-pickle`, 70 sessions). Recorded as-is. |
| **Turn count** | `type: "user"` lines with `origin.kind == "human"` (two so far in this session; confirm the kind name a mid-turn message carries on a real transcript). | `message` rows with `data.role == "user"` in the session. |
| **Per-stage split** | Sum the deduped requests whose `timestamp` falls in the stage window; or record cumulative-to-now at `start` and `end` and subtract at roll-up. The latter is what the line below does — one shape for both harnesses. | Same: sum `message` rows with `time.completed` in the window, or cumulative-to-now from the same query. |
| **Other routes, and why not** | OTel export needs a collector nobody runs and leaks `user.email` by default; `/usage` and the status line are not machine-readable; the Analytics API is per-user-per-day, Admin-key only (sustentus note, unchanged). | `opencode stats` is a human table (no JSON); `opencode export <id>` is the same data as JSON but 13 MB for one long session; `opencode serve` + `GET /session/:id/message` works but needs a server up. The database read is the cheapest and always available. |
| **Known trap** | The transcript is written asynchronously and may lag the current turn (hooks doc); an `end` snapshot taken as the very last act may miss the final response by one request. Accepted — it under-counts by one turn, never over. | Two OpenCode instances in one directory share the database (issue #31307); the plugin-set `OPENCODE_SESSION_ID` is what disambiguates, and the newest-session-for-this-directory fallback is only a fallback. |

**The line.** One run-scoped file, `.icm/runs/<slug>/usage.md`, append-only, archived with the
run by `close-out.sh` (its path guard already covers `.icm/runs/**`). Not `run.md`: Scope has no
`run.md` at its entry, and `run.md` is the pointer index three scripts parse.

```text
- usage: <stage> <start|end> <ISO-8601Z> harness=<claude|claude-cloud|opencode> session=<id> source=<transcript|sqlite|skip> model=<provider/model|mixed> in=<n> out=<n> cache_read=<n> cache_write=<n> cost_usd=<n.nnnn|unknown> turns=<n|unknown>
```

Each number is **cumulative for the session (subagents included) at that moment**; a stage's own
usage is `end − start` when both lines name the same `session=`, and a stage resumed in a second
session is two partial pairs the roll-up reports as such rather than subtracting across sessions.

**`scripts/usage-snapshot.sh <slug> <stage> start|end`** (T, new): detects the harness
(`CLAUDE_CODE_REMOTE` → `claude-cloud`; `CLAUDECODE` → `claude`; `OPENCODE_SESSION_ID` or an
`OPENCODE*` variable → `opencode`), locates the session as in the table, sums, appends the line,
prints `RESULT: RECORDED | SKIP (<reason>)`. Needs `jq`; needs `python3` or `sqlite3` for the
OpenCode reader (whichever is present — `env-check.sh` already lists both classes of binary). It
never estimates and never blocks: a `SKIP` line is still a line, and `close-out.sh` refuses nothing
over it. Every stage and lane contract calls it as the first act after the preamble and the last
act before the stop.

**`~/.config/opencode/plugins/icm-session-env.js`** (Jamie's machine, uncommitted like its two
siblings; the same file also belongs in `_system/template/root/.opencode/plugins/` if the estate
ever wants it per repo):

```js
// Hands the running session's id to the shell, so .icm/scripts/usage-snapshot.sh can read its
// own numbers from ~/.local/share/opencode/opencode.db. shell.env carries sessionID on 1.18.x
// (@opencode-ai/plugin index.d.ts); tool.execute.before always does — kept as the fallback.
let last = ""
export const IcmSessionEnv = async () => ({
  "tool.execute.before": async (input) => { if (input.sessionID) last = input.sessionID },
  "shell.env": async (input, output) => {
    const id = input.sessionID || last
    if (id) output.env.OPENCODE_SESSION_ID = id
  },
})
```

**Pricing the Claude lines.** `_system/scripts/model-prices.json` — one estate table, `as_of`
dated, per model: USD per million input, output, cache-read, cache-write tokens. Filled by the
implementing session from the `claude-api` skill's current table, never from memory, and amended
deliberately when a model's list price moves. `run-economics.sh` prices `cost_usd=unknown` lines
from it and says so in the report; OpenCode's own `cost` is used as recorded.

**`_system/scripts/run-economics.sh [--deal <slug>|--repo <name>] [--since <date>]`**
(icm-board, new, read-only): walks `projects/*/<runs_archive>/*/usage.md` and live `runs/`, pairs
`start`/`end` per stage and session, sums per run, per repo, per client, and writes
`workspaces/deals/<slug>/economics.md` (runs, stages, tokens by class, list-price USD, against
the `Value` row; "unavailable" where no run carries a line). Join key: a machine-readable
`- repo: <owner/name>` line in `DEAL.md`'s header (today `Repo` is a prose table row — the
session converts it, keeping the row). Repos with no deal (`jamienisbet`, this repo) get
`.icm/docs/economics.md` in the repo instead. Nothing is sent: `economics` is a reporting kind
that maps to no channel by default.

### 4.5 Rollbacks and hotfixes — decided: hotfix lane + prepared recovery

**Evidence.** Doctrine is fix-forward and says so three times: `ci.md` line 195, sustentus
`project-rules.md` (quiet apps), `changelog-entry` skill line 90. The only rollback vocabulary is
`lanes/chore` → `- rollback:` and Release stop class 3 ("a migration without a working `down`").
Sustentus's migrations are **forward-only and idempotent** (`db-migrate.yaml`), so a code rollback
must tolerate the newer schema. The bug lane opens draft, blind, then flips — the right economy for
a bug, the wrong one on a live incident. Vercel exposes instant rollback
(`POST /v1/projects/{id}/rollback/{deploymentId}`, `vercel rollback <id>`) and promote
(`POST /v10/projects/{id}/promote/{deploymentId}`); nothing in the estate names either.

**Recommendation.**
- `lanes/hotfix/CONTEXT.md` (T, new). Entered only by a human, from a production `ERROR` line, a
  Vercel failure email, or a client report. Differences from `bug`: `new-run.sh --lane hotfix`
  opens the PR **ready, not draft** (one full gate, previews at once), the slug is
  `hotfix-<what>`, the label `type:hotfix`, `notes.md` carries `- incident: <what broke, when, who
  reported>` and `- recovery: fix-forward | revert <sha> | vercel rollback dpl_…`, and the
  changelog entry is `audience: internal` unless the client saw it. Everything else is the bug
  lane: the operator merges from GitHub; the agent never merges.
- `scripts/rollback.sh <slug|--sha <merge-sha>> [--revert] [--vercel]` (T, new). It **prepares**:
  with `--revert`, a `claude/hotfix-revert-<slug>` branch carrying `git revert -m 1 <merge-sha>`
  and a hotfix-lane PR opened through `new-run.sh`; with `--vercel`, the previous READY deployment
  per product project (from `deploy-status.sh`) and the exact CLI and REST call. It **warns** when
  the merge carried a migration (`migrations.path`, or a tracked `migrations/` diff) and the repo
  declares `migrations.reversible: false`: "the schema moved forward; the reverted code must
  tolerate it". It never calls the rollback endpoint and never merges — `RESULT: PREPARED <what>`.
- Reword the three "not a revert" sentences to "not a revert *by a session's own decision* — a
  revert is the hotfix lane's, prepared by `rollback.sh` and merged by the operator".

### 4.6 Client communication and release notes — decided: Slack via CI, client email, GitHub Release

**Evidence.** Slack: the reference is CI-on-merge from the changelog page (`release.yaml`), which
works because sustentus has a help centre; the template's `notify.sh` carries a commented webhook
example. Email: remi-ai wired `notify.sh` to Resend with a plain `SKIPPED` when the secret is
absent (decisions log, 2026-09-18). GitHub Releases: none anywhere. A repo with no changelog
records `announce: none` and therefore announces nothing, ever.

**Recommendation** (all are `report.sh` channels; the caller never changes):
- **Where the summary comes from** when there is no changelog page: the PR's Summary line, which
  every run has (`new-run.sh --summary`). `report.sh` takes it as its argument; the CI path reads
  it from the merged PR body. A changelog page's `summary:` wins where one exists.
- **`slack`**: bot token + channel id as variable names, one channel per kind. The reference
  workflow (§4.7) is the sustentus one reduced to a `report.sh` call.
- **`email` (Resend)**: `POST https://api.resend.com/emails` with `RESEND_API_KEY`; recipients
  from `REPORT_EMAIL_TO`, sender from `REPORT_EMAIL_FROM` — variable names, never a literal
  address in the repo. Subject = the summary; body = the summary plus the changelog URL or the PR
  link. Also Jamie's own inbox as the alert fallback where Slack is absent.
- **`github-release`**: `POST /repos/{o}/{r}/releases` via `lib/gh.sh` after the merge — tag
  `release/<YYYY-MM-DD>-<slug>` on the merge SHA, name = the summary, body = the changelog body or
  the spec's *Proposed change*, `prerelease: false`. Only for `audience: public` (an `internal`
  entry is announced on the other channels and gets no Release, mirroring the changelog index).
  The tag is also the anchor `rollback.sh --revert` names.

### 4.7 Multi-client onboarding at scale

**Evidence.** `start/06_repo` and `07_kickoff` seed the baseline and hand over to `/project`,
whose § 1c fills the project-owned files, syncs, and proves the result. Sound. What it cannot fill
is what does not exist yet: a deploy block, a reporting block, a release workflow. The MANIFEST
cannot seed `.github/`, so every repo's labels job today is hand-copied or absent.

**Recommendation.**
- `/project` § 1c asks two more things in the intent rounds and writes them: `deploy` and
  `reporting` ("none" is an answer for every kind).
- `_system/template/github-workflows/release.yaml` — a **reference**, seeded once by § 1c the way
  `.claude/` assets are (D7: reported, never repaired), never in the MANIFEST: on `pull_request:
  closed` + merged, checkout, derive the summary, `report.sh announce`, then the archive check →
  `report.sh alert` on fault, and the job fails red either way. The sustentus one with its wiring
  moved into `project.json`. A second reference file carries the labels job.
- `vercel-env-registry.json` becomes a derived artifact regenerated from the repos' `deploy`
  blocks by a read-only sweep (`vercel-env.sh registry`), so one fact has one home (§10).

### 4.8 The local-shell ⇄ cloud-platform gap, in one table

| Platform | Template today | Gap | Closed by |
|---|---|---|---|
| GitHub | `lib/gh.sh`: curl with token → `gh` CLI fallback → one die naming the fix; `env-check.sh` verifies the route | none | — |
| Vercel (reads) | via GitHub commit statuses only; `vercel-env.sh` is estate-local; hydrate hook cloud-only | no transport, no project ids, no route check | `deploy` block · `lib/vercel.sh` · `env-check.sh` |
| Vercel (writes) | none | rollback/promote unnamed | `rollback.sh` prints them, never calls them |
| Slack | a commented example in `notify.sh` | one kind, one channel | `report.sh` `slack` |
| Resend | none in the template (remi-ai precedent) | — | `report.sh` `email` |
| GitHub Releases | none | — | `report.sh` `github-release` |
| Usage / cost — Claude Code | none | no line, no reader | `usage-snapshot.sh` transcript reader (`CLAUDE_CODE_SESSION_ID`) |
| Usage / cost — OpenCode | none | no session id in the shell, no reader | the `shell.env` plugin + the SQLite reader |
| Pricing | none | Claude tokens unpriced | `model-prices.json` at roll-up |
| Docker / AWS / Cloudflare | none | out of scope by decision 2 | — |

## 5. Recommended template changes — consolidated

| Path (relative to `.icm/` unless noted) | Owner | New / changed | What |
|---|---|---|---|
| `project.json` | P | changed | `deploy`, `reporting`, `migrations` objects (§6) |
| `_shared/project-rules.md` (stub) | P | changed | *Announcing* → *Reporting*: kinds → channels, "none = a red job + Vercel's email" written down; *People* gains the client contact by variable name; *The factory* gains the migrations line |
| `scripts/report.sh` | P | new, replaces `notify.sh` | kinds, channels, `SKIPPED` semantics (§4.0) |
| `scripts/notify.sh` | — | retired | MANIFEST line removed; `icm-check` reports it for `git rm` |
| `scripts/lib/vercel.sh` | T | new | the one Vercel transport, read verbs + `--check` |
| `scripts/deploy-status.sh` | T | new | production state per project, previous READY id, `RESULT: READY\|ERROR\|PENDING` |
| `scripts/rollback.sh` | T | new | prepares revert PR and/or names the Vercel rollback; warns on migrations; never executes |
| `scripts/usage-snapshot.sh` | T | new | the `- usage:` line into `runs/<slug>/usage.md`, two readers, `SKIP` when none |
| `scripts/env-check.sh` | T | changed | Vercel route when `deploy` present; reporting variables as `[WARN]`; `python3`/`sqlite3` as recommended |
| `scripts/ci-status.sh` | T | changed | expected-product-preview notice from `deploy.projects[]` |
| `scripts/new-run.sh` | T | changed | `--lane hotfix`; `--ready` opens the PR non-draft; `type:hotfix` label |
| `scripts/resolve-run.sh`, `project-labels.sh`, `close-out.sh` | T | changed | hotfix lane recognised; `usage.md` travels with the archive (already inside the path guard) |
| `lanes/hotfix/CONTEXT.md` | T | new | §4.5 |
| `stages/01–04`, `lanes/*` | T | changed | usage-snapshot first/last act; `notify.sh` → `report.sh announce`; Release step 9 adds `deploy-status.sh` + the `- production:` line |
| `_shared/ci.md`, `lanes/chore`, `04_release` stop class 3 | T | changed | the revert wording; stop class 3 scoped to `migrations.reversible: true` (§10) |
| `_shared/github.md` | T | changed | lane list gains hotfix; a hotfix PR opens ready |
| `MANIFEST` | — | changed | the new T lines; `notify.sh` removed; `report.sh` added as P |
| `.github/labels.yml` guidance in `github.md` | T | changed | `type:hotfix` in the fixed vocabulary |
| `_system/template/github-workflows/{release,labels}.yaml` | reference | new | seeded once by `/project` § 1c (§4.7) |
| `_system/template/root/.opencode/plugins/icm-session-env.js` | canonical root asset (optional) | new | the `shell.env` bridge (§4.4a); also installed globally on Jamie's machine |
| `_system/scripts/run-economics.sh`, `_system/scripts/model-prices.json` | icm-board | new | per-client roll-up → `workspaces/deals/<slug>/economics.md`; the price table (§4.4) |
| `_system/scripts/vercel-env.sh` | icm-board | changed | `registry` verb regenerates `vercel-env-registry.json` from the repos' `deploy` blocks |
| `workspaces/deals/*/DEAL.md` | icm-board | changed | `- repo: <owner/name>` header line as the join key |
| `workspaces/deliver/stages/project/CONTEXT.md` § 1c | icm-board | changed | asks and writes `deploy` + `reporting` + `migrations`; seeds the reference workflows |
| `_system/contracts/PIPELINE.md` | icm-board | changed | `pipeline-full` row → "reporting kinds and the reference workflows"; the file table gains the new scripts |
| `.icm/project.md` | icm-board | changed | decision **D23** recording all of the above |
| sustentus `.github/workflows/release.yaml`, `.icm/project.json`, `project-rules.md` | repo (a separate session, Jamie's PR) | changed | calls `report.sh`; channel ids move to `project.json`; `notify.sh` removed — the first sync target, as for D20 |

Every T addition is a one-job script under D11 (reports, prepares, never advances); every P
addition is configuration a repo owns. No new gate; no script crosses an existing one.

## 6. `project.json` — the expanded schema

```json
{
  "name": "cafe-jardim",
  "complexity": "micro",
  "docs_path": "docs",
  "required_env": ["GH_TOKEN"],
  "required_checks": ["Quality"],
  "personas": [],
  "runs_archive": ".icm/runs/_done",
  "intake_archive": ".icm/intake/_done",

  "deploy": {
    "platform": "vercel",
    "team_slug": "kodominio",
    "token_env": "VERCEL_TOKEN_KODOMINIO",
    "projects": [
      { "name": "cafe-jardim", "path": ".", "status_context": "Vercel – cafe-jardim",
        "class": "product", "production_url": "https://cafejardim.pt" }
    ]
  },

  "reporting": {
    "announce":  ["github-release", "email"],
    "alert":     [],
    "economics": [],
    "channels": {
      "slack":          { "token_env": "SLACK_BOT_TOKEN", "announce_channel_env": "SLACK_ANNOUNCE_CHANNEL_ID", "alert_channel_env": "SLACK_ALERTS_CHANNEL_ID" },
      "email":          { "api_key_env": "RESEND_API_KEY", "from_env": "REPORT_EMAIL_FROM", "to_env": "REPORT_EMAIL_TO" },
      "github-release": { "tag_prefix": "release/" }
    }
  },

  "migrations": { "path": "packages/services/migrations", "reversible": false }
}
```

Rules that keep it honest, all already the estate's: variable *names* only, never values; a missing
block reads as "not declared", never an error (`lib/project.sh` defaults; the old `migrations_path`
string is still read as `migrations.path`); `alert: []` is a decision the stub asks `/project` to
record, and it means a red job. Sustentus's block would read `announce: ["slack"]`,
`alert: ["slack"]`, `migrations.reversible: false`, with `smoke_check` unchanged beside it.

## 7. Build order — one session, dependency-ordered

Not stubs. Work packages for one implementation session in this repo, on one `claude/` branch,
one PR. Each package ends with the proof in §8 that applies to it.

1. **Reporting hook.** `report.sh` + the `reporting` block + the `project-rules.md` stub rewrite;
   `notify.sh` retired from the MANIFEST; Release step 9 and the lanes call `report.sh`.
2. **Deploy block and the Vercel library.** `deploy` and `migrations` in `project.json`,
   `lib/vercel.sh`, `env-check.sh` and `ci-status.sh` reading them; `lib/project.sh` defaults.
3. **Production read at Release.** `deploy-status.sh` + the `- production:` line in step 9.
   *Depends on 2.*
4. **Hotfix lane and prepared rollback.** `lanes/hotfix/`, `new-run.sh --lane hotfix --ready`,
   `resolve-run.sh` / `project-labels.sh` recognising it, `rollback.sh`, the revert-wording sweep,
   stop class 3 scoped to `migrations.reversible`. *Depends on 2 and 3.*
5. **Usage on the run.** `usage-snapshot.sh` with both readers, the two calls in every stage and
   lane, `usage.md` in the archive path, the OpenCode `icm-session-env.js` plugin as a canonical
   root asset. *Independent of 2–4.*
6. **Economics roll-up.** `run-economics.sh`, `model-prices.json` (filled from the `claude-api`
   skill), the `- repo:` line in every `DEAL.md`, `economics.md` shape. *Depends on 5.*
7. **Reference workflows and onboarding.** `_system/template/github-workflows/{release,labels}.yaml`,
   `/project` § 1c asking and writing the three blocks, `vercel-env.sh registry`. *Depends on 1, 2.*
8. **Contracts, PIPELINE.md, D23.** The wording sweep across `PIPELINE.md`, `github.md`, `ci.md`,
   the chore lane, and the D23 row in `.icm/project.md`; the parked `profile-wording-sweep` stub's
   files may be touched where the same sentence is being edited anyway. *Last.*

Sustentus adoption (its `release.yaml` → `report.sh`, ids into `project.json`, `notify.sh` removed,
`icm-sync.sh --apply`) is **a separate session opened in that repo**, exactly as D20's first sync
was — never from this one.

## 8. Definition of done — what the session proves before its PR opens

- `_system/scripts/self-check.sh` passes (shellcheck, contract links, ticket lint), and every new
  script has a header in the house shape: what it does, what it never does, `Usage:`, `Verdict:`.
- `icm-sync.sh projects/sustentus` (dry run) lists exactly the new and changed T files and nothing
  else; `icm-check.sh --repo projects/sustentus` reports the expected drift and no missing P file
  once the stubs are seeded. Neither is applied.
- `env-check.sh` on this repo: `PASS`, with the Vercel route line present when `deploy` is
  declared and `[INFO] deploy not declared` when it is not.
- `usage-snapshot.sh icm-self-test scope start` then `… end`, run inside the implementing session,
  writes two lines with `harness=claude` (or `claude-cloud`), `source=transcript`, a non-zero
  `cache_read`, and `session=$CLAUDE_CODE_SESSION_ID`; the same pair run under
  `opencode run` on Jamie's machine writes `harness=opencode source=sqlite` with the plugin
  installed and `source=skip` with `--pure`. The test run folder is deleted before the commit.
- `run-economics.sh --repo icm-board` renders a table from those two lines and prices them from
  `model-prices.json`, naming its `as_of` date.
- `report.sh announce "x"` with no `reporting` block prints `RESULT: SKIPPED (no channel for
  announce)` and exits 0; with `announce: ["email"]` and `RESEND_API_KEY` unset prints
  `SKIPPED email: RESEND_API_KEY unset` and exits 0. Nothing is sent from the session.
- `deploy-status.sh --sha <any recent sustentus main sha>` run read-only against sustentus's
  `deploy` block (written on a scratch copy of its `project.json`, not committed there) prints one
  line per product project and a `RESULT:`; `rollback.sh --sha <that sha> --vercel` prints the
  rollback call and `RESULT: PREPARED` without opening anything.
- `new-run.sh <slug> --lane hotfix --summary "x" --dry-run` prints a lane body with no gate
  anchors and the `type:hotfix` label named.
- `validate-decisions.sh`, `validate-spec.sh` and `validate-intake.sh` are untouched and still
  `RESULT: OK` on this repo's own intake.
- CI on the PR is green. **No local `build`, `lint`, `typecheck` or `test` was run** — CI is the
  verdict (global rule).

## 9. Constraints for the session

- **Repo boundary.** Everything lands in icm-board, on one `claude/` branch, one PR. Nothing under
  `projects/` is modified — sustentus is proven against read-only, and adopts in its own session.
- **Ownership.** T files carry no identity (no owner name, channel, team, path, address). P files
  are stubs the repo fills. New T files are added to the MANIFEST; nothing else can be synced.
- **Doctrine.** No orchestrator (D3, D11): every script reports or prepares; nothing watches,
  retries, or crosses a gate. Gates stay two and stay human. Fix-forward stays the default.
  `report.sh` exits 0 always. No secret or address in git; variable names only.
- **Harness facts are verified, not assumed.** Where the report cites a hook signature or an
  environment variable, the session confirms it on the installed binary before relying on it
  (the OpenCode types have been stale before — memory note `opencode-machine-setup`).
- **Prices come from the `claude-api` skill**, never from memory, and the table is dated.
- **No stubs.** The session does not cut tickets from this document; findings it cannot finish
  become one triage stub each, in the ordinary way, named in the PR.

## 10. Settled by research — the former open points

| Point | Resolution | Evidence |
|---|---|---|
| **OpenCode usage source** | SQLite read, keyed by `OPENCODE_SESSION_ID` from a `shell.env` plugin; children by `parent_id`; cost as recorded. | `opencode.db` schema and rows; `@opencode-ai/plugin` 1.18.25 `index.d.ts` lines 235–248; `OPENCODE_DB` in the binary and the docs; `opencode export` and `session list --format json` shapes; `stats` is human-only. |
| **Claude Code local source** | Transcript by `CLAUDE_CODE_SESSION_ID`; dedupe by `requestId`; subagents under `<session>/subagents/`. No `CLAUDE_ENV_FILE`. | `env` in this session; this session's transcript (113 lines / 18 requests); claude-code issues #15840, #11649 on `CLAUDE_ENV_FILE`. |
| **Claude Code cloud source** | Same transcript reader (`/root/.claude/projects/…`); the session record is a cross-check. | sustentus `docs/token-metrics.md` → "What was verified". |
| **Where the usage line lives** | `runs/<slug>/usage.md`, not `run.md`. | Scope has no `run.md` at entry; `run.md` is parsed by `resolve-run.sh`, `ci-status.sh`, `close-out.sh`. |
| **Registry vs `deploy` block** | The repo's `deploy` block is authoritative; `vercel-env-registry.json` is regenerated from it. | A cloud session cannot see `projects/` or the registry (`vercel-env-hydrate.sh` header); the block is the only copy every session can read. |
| **GitHub Release tag and audience** | `release/<YYYY-MM-DD>-<slug>`; public entries only. | Unique per run, sortable, no counter to keep; mirrors the changelog index's `internal` rule. |
| **Client email recipients** | Variable names (`REPORT_EMAIL_TO`, `REPORT_EMAIL_FROM`) in the repo's environment. | T files carry no identity (D12/D20); a client-owned repo must not carry Jamie's routing; the deal folder is not readable from a client repo's CI. |
| **Hotfix cadence on sustentus** | Opens ready; the first ready push builds all three product apps and that cost is accepted on an incident. | sustentus `project-rules.md` → "the first ready push always builds all three"; decision 4. |
| **Forward-only migrations vs stop class 3** | `migrations.reversible` in `project.json`; stop class 3 reads "a migration without a working `down` *where the repo's migrations are reversible*"; `rollback.sh` warns when they are not. | `db-migrate.yaml` ("forward-only and idempotent") against `04_release` stop class 3 — a contradiction the reference repo already lives with. |
| **`economics` as a kind** | Kept; maps to no channel by default; no digest templated. | The daily digest is sustentus-only and reads Slack canvases; the kind is the hook if that ever generalises. |
| **Alert channel** | Abstracted (§4.0); "none" is a red job plus Vercel's email. | Jamie's correction, 2026-09-22. |

**Operator actions the session cannot do**, listed so nothing is left implicit: paste
`VERCEL_TOKEN` (and per-team tokens) into the cloud environment panels and GitHub secrets where
`deploy-status.sh` or a reference workflow will run; set `REPORT_EMAIL_*`, `RESEND_API_KEY` and
the Slack variables per repo; install `icm-session-env.js` into `~/.config/opencode/plugins/`
(uncommitted, like its siblings); add `type:hotfix` to each repo's `.github/labels.yml` on
adoption.

## 11. What this deliberately does not change

- **Never build an orchestrator.** Every new script reports or prepares: `deploy-status.sh` looks
  once, `rollback.sh` writes a PR and a command, `usage-snapshot.sh` appends a line, `report.sh`
  sends what a human-authorised merge produced. Nothing watches, nothing retries, nothing crosses a
  gate (D3, D11).
- **Gates stay human, and stay two.** Decision 1 keeps the business out of the PR; the hotfix
  lane's gate is the merge button like every lane.
- **Fix-forward stays the default.** A revert becomes *available*, prepared and named, and is
  still the operator's click.
- **T files carry no identity.** Channels, teams, tokens and addresses are variable names in P
  files; the contracts say "see `_shared/project-rules.md` → Reporting" (D12, D20).
- **CI is the verdict; reporting is never a gate.** `report.sh` exits 0 always; the red job is the
  alert, not a blocker.
- **Sustentus stays the reference and the first sync target**, exactly as D20 did it.
