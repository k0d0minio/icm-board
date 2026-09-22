# Agency DevOps Brainstorm — what the pipeline template still owes an agency

*Research and interview pass, 2026-09-22, on branch `claude/icm-pipeline-devops-research-e0196c`;
revised the same day on Jamie's four flags (§3, last four rows), then tightened once more (r3,
same day) where a re-read of the flags against the repo found the design still leaning: no
default template path in `setup.sh` (flag 1), a Release on every merge by default (flag 2),
sensitive values in `pull` and the meaning of "document" (flag 4), the workflows' template
folder, and sustentus's on-disk state. Scope:
`_system/template/icm-pipeline/`, `_system/scripts/`, `projects/sustentus/.icm/` plus its
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
of them needing a cost number per client, an environment that is declared once and checked
everywhere, a way back when a release goes wrong, and one command that sets a repo up or keeps it
honest without anyone remembering how. Eight decisions were settled in session (§3); one
correction and four review flags reshaped the design: **reporting is abstracted into message kinds
a repo maps to whatever it has, with a GitHub Release on by default; nothing a repo runs ever calls
icm-board; `/setup` replaces `/project`'s setup step; and the estate env manager becomes a
per-repo script driven by the repo's own deploy block.**

The shape of the answer is the shape the template already uses: a few more `- key:` lines in the
plain-text surfaces a run already carries, a few more one-job scripts that end in one `RESULT:`
line, three new objects in the project-owned `project.json`, one new lane, one new command, and
one global OpenCode plugin on Jamie's machine. Nothing starts itself, nothing crosses a gate,
nothing reverts production without a human, and no value of any secret ever appears in a
command line, a transcript, or git.

## 1. What was examined

| Layer | Files and commands |
|---|---|
| Template contracts | `stages/0{1..4}_*/CONTEXT.md`, `lanes/{bug,tweak,chore,knowledge}/CONTEXT.md`, `intake/CONTEXT.md`, `_shared/{ci,github,stage-preamble,scope-template,project-rules,conventions,knowledge-map}.md`, `runs/README.md`, `raw/README.md`, `MANIFEST`, `project.json` |
| Template scripts and assets | all 22 under `scripts/` and `scripts/lib/`; `_system/template/claude/` (hooks, `ticket-craft`, `pr-conventions`), `_system/template/claude-pipeline/skills/pipeline/SKILL.md` (the router), `_system/template/root/opencode.jsonc` |
| Estate scripts | `icm-sync.sh`, `icm-check.sh` (`CANONICAL`, `CANONICAL_ROOT`, the MANIFEST walk), `vercel-env.sh` (`link · init · push-notes · pull · audit`) + `vercel-env-registry.json`, `_system/template/claude/hooks/vercel-env-hydrate.sh` |
| Sustentus | `.icm/project.json`, `.icm/CONTEXT.md`, `_shared/project-rules.md`, `scripts/notify.sh`, `docs/token-metrics.md`, the archived `deployment-economics` epic, `.github/workflows/{release,preview-smoke,db-migrate,quality,daily-digest}.yaml`, `.github/scripts/state-of-play.mjs`, skills `production-readiness`, `changelog-entry`, `browser-smoke`, `notification` |
| Business layer | `_system/contracts/{PIPELINE,CLIENTS,WORKSPACES}.md`, `_system/knowledge/*`, `workspaces/start/**`, `workspaces/deliver/stages/{project,conformance}/CONTEXT.md`, `workspaces/deals/*/DEAL.md`, `.icm/project.md` D1–D22, `.icm/docs/2026-09-02-opencode-parity-report.md`, `intake/opencode-executor/` |
| Claude Code (this session) | `env` inside the Bash tool; `~/.claude/projects/<cwd-slug>/<session>.jsonl` and `<session>/subagents/`; docs `code.claude.com/docs/en/hooks` |
| OpenCode (this machine) | `opencode --help`, `export`, `stats`, `session list --format json`; read-only `sqlite3` over `~/.local/share/opencode/opencode.db`; `strings` on the binary; `~/.config/opencode/plugins/*.js`; `@opencode-ai/plugin/dist/index.d.ts` (1.18.25); docs `opencode.ai/docs/{plugins,server,sdk,cli}` |
| Vercel | `search_vercel_documentation`: `/v6/deployments` (query `sha`, `target`, `state`), `/v13/deployments/{id}`, `POST /v1/projects/{id}/rollback/{dpl}`, `POST /v10/projects/{id}/promote/{dpl}`; `vercel env add [name] [environment] < [file]` (value on stdin), `--sensitive`, `vercel env ls`, `vercel env pull --environment` |

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
| `.env.example` | humans; `vercel-env.sh init` seeds keys | `vercel-env.sh` (notes → Vercel comments; notes → `.env.local`) | keys with `#` notes above them and an optional `[targets]` suffix — values never |
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
**The template ships no workflow at all**; the MANIFEST is rooted at `.icm/`, so it *cannot* seed
`.github/`, and the MANIFEST itself "stays in the template", so a repo cannot self-check its own
completeness offline.

**The setup seam.** A repo is set up from icm-board: `createClientRepo` scaffolds the baseline,
`icm-check.sh --fix` seeds, `icm-sync.sh --apply` syncs, and `/project` § 1c (four numbered steps
plus questions folded into the intent rounds) fills the project-owned files. All of it runs from
`~/Apps` on Jamie's machine and needs icm-board in view. The env manager is the same shape:
`vercel-env.sh` walks the registry from icm-board; only the reduced cloud hook lives in a repo.

**What sustentus adds on top:** `release.yaml` (announce from the changelog page to
`#product-update`, verify the archive landed, faults to `#alerts`); `preview-smoke.yaml`
(six-persona walk on the `status` event); `db-migrate.yaml` (forward-only, preview on PR,
production on `main` behind an environment gate); `quality.yaml` (tiered, draft-aware);
`daily-digest.yaml` + `state-of-play.mjs` (delivery economics — infra proxies only).

## 3. What was settled in session

| # | Domain | Decision (Jamie, 2026-09-22) |
|---|---|---|
| 1 | Client sign-off | **The operator signs off on the client's behalf.** No client-facing gate, no new artifact. |
| 2 | Deploy targets | **Vercel only** — made explicit by a `deploy` object in `project.json`. |
| 3 | Cost tracking | **Per stage, on the run, plus a per-client roll-up.** Tokens first, list-price USD second; margin, never an invoice line. |
| 4 | Rollback | **A `hotfix` lane plus a `rollback.sh` that prepares the recovery and stops.** A human merges or clicks. |
| 5 | Channels | **A GitHub Release per merge is on by default in every repo**; Slack (via CI on merge, the reference shape) and client email via Resend are added per repo by editing the reporting block. Not Discord, not Linear/Jira. |
| 6 | Health check | **Release step 9 reads production once** via the Vercel API and records READY/ERROR in the Release record. No standing workflow. |
| 7 | Roll-up home | **An icm-board script writes `workspaces/deals/<slug>/economics.md`** — read-only, human-invoked, no new store. A repo can also print its own numbers without icm-board. |
| 8 | Hotfix entry | **Always human-invoked.** No alert-carried command, no auto-parked stub. |
| — | Correction | **There is no alert channel across projects; only sustentus has one.** Reporting is abstracted so a repo can plug in several forms of reporting — or none. |
| — | Delivery | **No stubs.** This document is the brief for one session that does all of it. |
| — | Flag 1 | **Nothing a repo runs may depend on seeing icm-board.** Every script, hook and default below works from the repo's own files and the repo's own credentials; icm-board is involved only when it seeds or syncs, and only from Jamie's machine. |
| — | Flag 2 | **GitHub Release is the seeded default announce channel.** It needs no secret beyond the GitHub route every repo already has. |
| — | Flag 3 | **`/setup` replaces `/project` § 1c** — one idempotent house-cleaning command, seeded into every repo, that sets a bare repo up or maintains an existing one from the pipeline's point of view. `/project` keeps intent, analysis and tickets. |
| — | Flag 4 | **The estate env manager is baked into the pipeline** as a per-repo `env.sh` driven by the deploy block: audit across every surface, document keys in `.env.example`, and create variables through the `vercel` and `gh` CLIs with the value taken from stdin and never from an argument. |

Decisions 6 and 8 together mean the pipeline never *watches* production: it looks once at the end
of Release, writes what it saw, and the human decides. That removes the alert channel from the
health-check path entirely.

## 4. Gaps, by domain

### 4.0 Reporting is not abstracted (the correction), and it must run in the repo (flag 1)

**Evidence.** `_shared/project-rules.md` (stub) has one section, *Announcing*, with two slots:
`notify.sh` and a changelog. `notify.sh` takes one argument and knows one kind of message. The
contracts say "the project's alert channel (→ Announcing), where it has one" — hedged in wording,
but there is no place a repo without a channel can say so and no path by which an alert reaches
anyone in such a repo. In sustentus both channels are hard-wired as IDs in `release.yaml` and
`notify.sh` is deliberately inert.

**Recommendation — one project-owned hook, message kinds, channels as configuration, everything
inside the repo.**

- `scripts/report.sh <kind> "<summary>" [--url <link>] [--body <file>] [--dry-run]` (P, seeded
  once) replaces `notify.sh`. Kinds: `announce | alert | economics`. It reads `project.json →
  reporting` (§6) mapping each kind to a list of channels, and each channel to the *names* of the
  environment variables that carry its secrets. Channels shipped in the stub, all implemented:
  `github-release` (via `lib/gh.sh`, **on by default for `announce`**), `slack` (bot token +
  channel id, or an incoming webhook), `email` (Resend). Exit 0 always; last line
  `RESULT: SENT <channels> | SKIPPED (no channel for <kind>)`. A configured channel whose variable
  is absent prints `SKIPPED <channel>: <VAR> unset` (the remi-ai precedent). `--dry-run` prints
  every payload and sends nothing.
- **Runtime dependencies: none outside the repo.** `report.sh` reads `.icm/project.json`, sources
  `.icm/scripts/lib/gh.sh`, and uses the repo's own `GH_TOKEN`/`gh` login (a fine-grained token
  scoped to that repo with *Contents: read and write* is enough for a Release; in Actions, the
  job's `permissions: contents: write` on the default `GITHUB_TOKEN`) and whatever channel
  variables the repo declares.
  It never reads the registry, the deal folder, or anything under `~/Apps`. The same holds for
  every other script in this brief (§4.9).
- **The zero-config alert is a red job.** Where `alert` maps to no channel, the CI workflow that
  found the fault fails, and GitHub's own notification to the repository owner is the alert.
  Vercel's own deployment-failed email is the second free channel. Both are written into the
  `project-rules.md` stub so "none" is a recorded decision, not a hole.
- **One caller per announce.** `reporting.announce_from` is `session` (default: Release step 9
  calls `report.sh announce` after the merge, so a repo with no workflow still announces) or `ci`
  (the reference release workflow calls it; step 9 records `announce: deferred to CI` and does not
  call). `github-release` is idempotent regardless — it checks the tag first.
- Every template-owned caller — Release step 9, the lanes' step 5, the reference release workflow
  (§4.7) — calls `report.sh` and never a channel. Sustentus's `release.yaml` becomes
  `report.sh announce` + `report.sh alert` with the channel IDs moved into `project.json` and
  `announce_from: ci`. `notify.sh` leaves the MANIFEST (reported for `git rm`, never deleted by a
  script).

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
icm-board's registry — invisible to a cloud session and to any repo, which is the deciding fact
in §10 and the reason the deploy block carries flag 4 as well.

**Recommendation.**
- `project.json → deploy` (P; §6): platform, team slug, the token's *variable name*, and one entry
  per Vercel project with its name, `path`, status context, `product | quiet` class and production
  URL. `/setup` fills it from the same API lookup the hydrate hook makes
  (`GET /v9/projects?repoUrl=…`), confirmed by Jamie.
- `scripts/lib/vercel.sh` (T, new) — the one Vercel transport, the way `lib/gh.sh` is the GitHub
  one: curl + the token named by `deploy.token_env`, falling back to plain `VERCEL_TOKEN` exactly
  as the hydrate hook does; `vercel_get`, `vercel_deployments <project> [--target production]
  [--sha <sha>]` (`GET /v6/deployments`), `vercel_deployment <id>` (`GET /v13/deployments/{id}`),
  `vercel_env_list <project>` (`GET /v9/projects/{id}/env` — names, targets, comments; never a
  decrypted value), and `--check`. No write verb lives here.
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
  `ERROR` un-merges nothing and starts nothing. `PENDING` after the bound is recorded as such.
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
| **How a script finds its own session** | `CLAUDE_CODE_SESSION_ID` is exported to every Bash tool call (this session: `2aae8848-…`, equal to the transcript's filename). `CLAUDE_PROJECT_DIR` is exported too. Not `CLAUDE_ENV_FILE` — reported broken or empty in the wild (claude-code issues #15840, #11649) and not needed. | Nothing is exported by default (the binary's `OPENCODE_*` set has no session variable). The plugin API provides it: `shell.env(input: {cwd, sessionID?, callID?}, output: {env})` — a global plugin sets `output.env.OPENCODE_SESSION_ID = input.sessionID`, with `tool.execute.before(input: {tool, sessionID, callID})` as the fallback that always carries it (`@opencode-ai/plugin` 1.18.25 `index.d.ts` lines 235–248). Verify on the binary, per the standing rule. |
| **Where the numbers are** | The transcript `~/.claude/projects/<cwd-slug>/<session>.jsonl` (cloud: `/root/.claude/projects/-home-user-<repo>/…`). Every API response is a `type: "assistant"` line with `requestId`, `message.model`, `message.usage = {input_tokens, cache_creation_input_tokens, cache_read_input_tokens, output_tokens, …}` and an ISO `timestamp`. Streaming repeats a `requestId` (this session: 113 lines, 18 requests) — take the **last line per `requestId`**. `find ~/.claude/projects -name "$CLAUDE_CODE_SESSION_ID.jsonl"` sidesteps the path encoding (`.claude` → `-claude`). | SQLite at `~/.local/share/opencode/opencode.db` (override: `OPENCODE_DB`; `XDG_DATA_HOME` respected). `session` rows carry cumulative `cost`, `tokens_input`, `tokens_output`, `tokens_reasoning`, `tokens_cache_read`, `tokens_cache_write`, `model` (JSON `{id, providerID}`), `directory`, `project_id`, `parent_id`. `message` rows carry per-response `data.tokens {input, output, reasoning, cache{read, write}}`, `data.cost`, `data.modelID`, `data.providerID`, `data.path.cwd`, `data.time {created, completed}` (epoch ms). Read with `?mode=ro`; WAL is fine. |
| **Subagents** | Sibling files under `<session>/subagents/*.jsonl` — same line shape; sum them in. | Child sessions: `session.parent_id = <id>` — one `WHERE parent_id = ?` in SQL. |
| **Cost** | Not in the transcript. Priced **in the repo** from the synced table `scripts/lib/model-prices.json` (T; below); `cost_usd=unknown` only when the model is missing from the table. The cloud session record (`get_session` → `external_metadata.usage.cost_usd`) is a cross-check, not the source. | On the row and on every message, computed by OpenCode from the models.dev catalogue: `$0.0221` across 14 `vercel/zai/glm-5.3-flash` sessions; `0` for Zen free models (`opencode/big-pickle`, 70 sessions). Recorded as-is. |
| **Turn count** | `type: "user"` lines with `origin.kind == "human"` (confirm the kind name a mid-turn message carries). | `message` rows with `data.role == "user"` in the session. |
| **Per-stage split** | Record cumulative-to-now at `start` and `end`; subtract at roll-up. | Same query, cumulative-to-now. |
| **Other routes, and why not** | OTel export needs a collector nobody runs and leaks `user.email` by default; `/usage` and the status line are not machine-readable; the Analytics API is per-user-per-day, Admin-key only. | `opencode stats` is a human table; `opencode export <id>` is the same data as JSON but 13 MB for one long session; `opencode serve` + `GET /session/:id/message` needs a server up. The database read is the cheapest and always available. |
| **Known trap** | The transcript is written asynchronously and may lag the current turn by one request. Accepted — it under-counts, never over. | Two OpenCode instances in one directory share the database (issue #31307); the plugin-set `OPENCODE_SESSION_ID` disambiguates; newest-session-for-this-directory is only a fallback. |

**The line.** One run-scoped file, `.icm/runs/<slug>/usage.md`, append-only, archived with the
run by `close-out.sh` (its path guard already covers `.icm/runs/**`). Not `run.md`: Scope has no
`run.md` at its entry, and `run.md` is the pointer index three scripts parse.

```text
- usage: <stage> <start|end> <ISO-8601Z> harness=<claude|claude-cloud|opencode> session=<id> source=<transcript|sqlite|skip> model=<provider/model|mixed> in=<n> out=<n> cache_read=<n> cache_write=<n> cost_usd=<n.nnnn|unknown> turns=<n|unknown>
```

Each number is **cumulative for the session (subagents included) at that moment**; a stage's own
usage is `end − start` when both lines name the same `session=`; a stage resumed in a second
session is two partial pairs the roll-up reports as such.

**`scripts/usage-snapshot.sh <slug> <stage> start|end`** (T, new): detects the harness
(`CLAUDE_CODE_REMOTE` → `claude-cloud`; `CLAUDECODE` → `claude`; `OPENCODE_SESSION_ID` or an
`OPENCODE*` variable → `opencode`), locates the session as in the table, sums, prices Claude
lines from `lib/model-prices.json`, appends the line, prints `RESULT: RECORDED | SKIP (<reason>)`.
`--report <slug>` prints the run's totals so far — a repo shows its own numbers without icm-board.
Needs `jq`; needs `python3` or `sqlite3` for the OpenCode reader. It never estimates and never
blocks. Every stage and lane contract calls it as the first act after the preamble and the last
act before the stop.

**`scripts/lib/model-prices.json`** (T, synced everywhere): `as_of` dated, per model USD per
million input, output, cache-read, cache-write tokens. Filled by the implementing session from the
`claude-api` skill's current table, never from memory; amended deliberately in the template and
synced like any T file, so every repo prices its own lines identically.

**`~/.config/opencode/plugins/icm-session-env.js`** (Jamie's machine, uncommitted like its two
siblings; the same file is also a canonical root asset, `_system/template/root/.opencode/plugins/`,
for repos that want it seeded):

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

**`_system/scripts/run-economics.sh [--deal <slug>|--repo <name>] [--since <date>]`**
(icm-board, new, read-only — the one component that *is* icm-board's, because it reads across
`projects/*`): walks `projects/*/<runs_archive>/*/usage.md` and live `runs/`, pairs `start`/`end`
per stage and session, sums per run, per repo, per client, and writes
`workspaces/deals/<slug>/economics.md` (runs, stages, tokens by class, list-price USD, against the
`Value` row; "unavailable" where no run carries a line). Join key: a machine-readable
`- repo: <owner/name>` line in `DEAL.md`'s header. Repos with no deal get `.icm/docs/economics.md`
in the repo. Nothing is sent: `economics` is a reporting kind that maps to no channel by default.

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
  the merge carried a migration and the repo declares `migrations.reversible: false`: "the schema
  moved forward; the reverted code must tolerate it". It never calls the rollback endpoint and
  never merges — `RESULT: PREPARED <what>`.
- Reword the three "not a revert" sentences to "not a revert *by a session's own decision* — a
  revert is the hotfix lane's, prepared by `rollback.sh` and merged by the operator".

### 4.6 Client communication and release notes — decided: GitHub Release by default; Slack and email added per repo

**Evidence.** Slack: the reference is CI-on-merge from the changelog page (`release.yaml`), which
works because sustentus has a help centre; the template's `notify.sh` carries a commented webhook
example. Email: remi-ai wired `notify.sh` to Resend with a plain `SKIPPED` when the secret is
absent (decisions log, 2026-09-18). GitHub Releases: none anywhere. A repo with no changelog
records `announce: none` and therefore announces nothing, ever — which flag 2 ends.

**Recommendation** (all are `report.sh` channels; the caller never changes):
- **`github-release` — on by default.** The seeded `project.json` stub ships
  `announce: ["github-release"]`. `POST /repos/{o}/{r}/releases` via `lib/gh.sh` after the merge:
  tag `release/<YYYY-MM-DD>-<slug>` on the merge SHA, name = the summary, body = the changelog
  body or the spec's *Proposed change* plus the PR link, `prerelease: false`. **Every merge
  gets one unless the run opts out.** The audience defaults to `public`; a changelog entry or a
  `notes.md` line reading `audience: internal` is announced on the other channels and gets no
  Release (mirroring the changelog index), and `announce: none` on the run sends nothing at
  all — both are the run's explicit choice, never a default, and a repo with no changelog page
  never has to say anything to get its Release. Idempotent by tag. The tag is also the anchor
  `rollback.sh --revert` names. Every repo therefore has a public ship log from its first merge
  with zero configuration.
- **Where the summary comes from** when there is no changelog page: the PR's Summary line, which
  every run has (`new-run.sh --summary`). A changelog page's `summary:` wins where one exists.
  `announce: none` stays available for a run with truly nothing to say, and stays explicit.
- **`slack`** (added by editing the block): bot token + channel id as variable names, one channel
  per kind. The reference workflow (§4.7) is the sustentus one reduced to a `report.sh` call, with
  `announce_from: ci`.
- **`email` (Resend)** (added by editing the block): `POST https://api.resend.com/emails` with
  `RESEND_API_KEY`; recipients from `REPORT_EMAIL_TO`, sender from `REPORT_EMAIL_FROM` —
  variable names, never a literal address in the repo. Subject = the summary; body = the summary
  plus the Release URL or the changelog URL. Also Jamie's own inbox as the alert fallback where
  Slack is absent.

### 4.7 `/setup` — one command that sets a repo up or keeps it honest (flag 3)

**Evidence.** Setup is spread over four places, all outside the repo: `createClientRepo`
(dashboard), `icm-check.sh --fix` (seed), `icm-sync.sh --apply` (sync), and `/project` § 1c —
four numbered steps ("declare" now empty after D22, the formatter guard, seed-then-sync, read the
repo for the P files) plus questions folded into `/project`'s intent rounds, the writing in its
§ 6, and proofs in its Audit. `start/06_repo` and `07_kickoff` point at those. Maintenance is
spread the same way: `icm-check.sh` reports gaps and drift from icm-board; nothing in a repo can
tell whether it is complete, current, or configured, because the MANIFEST "stays in the
template". The parked stub `profile-wording-sweep` already records that § 1c "is now a step with
nothing to declare".

**Recommendation — a template-owned command, seeded into every repo beside `/pipeline`.**

- `_system/template/claude-pipeline/skills/setup/SKILL.md` → `.claude/skills/setup/SKILL.md`
  (canonical asset, seeded like the router) and `.icm/scripts/setup.sh` (T). `/setup` — re-run
  any time, from any harness, in any repo. It never needs icm-board in view: everything it checks
  is in the repo, and the one thing it cannot do without a template source (seed a bare repo, or
  bring T files up to date) it reports rather than fakes.
- **`setup.sh [--fix] [--template <path|url>] [--report]`** — the deterministic half, one report,
  `RESULT: OK | GAPS n`. Sections, in order:
  1. **Baseline** — every file the repo's own `.icm/MANIFEST` names is present (the MANIFEST
     becomes a T file, `.icm/MANIFEST`, and `.icm/template-version` records the template commit
     the last sync came from, so completeness and currency are answerable offline); the router
     and `/setup` skills; the two hooks registered in `.claude/settings.json`; `opencode.jsonc`;
     the PR template with both gate anchors. `--fix` seeds only what is missing, from
     `--template` — never overwrites (D7); a diverged T file is reported as drift with the
     `icm-sync.sh --apply` command to run from icm-board.
  2. **Formatter exposure** — a formatter config that would touch T paths and no exclusion for
     them: reported with the exact lines to add (D17/D19: per-repo, by hand; never written by
     a script).
  3. **`project.json`** — `name`, `complexity`, `required_checks`, `personas`, `deploy`,
     `reporting`, `migrations`: each missing or still at the stub's placeholder is a gap
     with the question the skill should ask.
  4. **Environment** — `env-check.sh` (route + binaries) and `env.sh audit` (§4.8): keys
     declared vs present on every surface, names only.
  5. **Tickets** — `validate-intake.sh` over every live epic; every triage stub carries a valid
     `lane:`; `triage-report.sh` against the cap; a loose `TODO.md`/`BACKLOG.md` at the root.
  6. **Raw** — `process-raw.sh --dry-run`: assets waiting in `.icm/raw/`, and which need a
     local tool that is missing; the pointer stubs it would park.
  7. **Runs** — a merged run still in `runs/` (the archive alarm); a live run whose PR is closed;
     `usage.md` pairs with a `start` and no `end`.
  8. **Knowledge** — `validate-knowledge-map.sh`.
  9. **Reporting** — which kinds map to which channels; which channel variables are unset;
     `announce_from` consistent with whether the reference workflow exists.
  10. **Workflows** — the reference `release.yaml`/`labels.yaml` present or declared absent in
      `project-rules.md`; `type:hotfix` in `.github/labels.yml`.
- **The skill** runs the script, then asks — `AskUserQuestion`, in rounds of at most four —
  exactly what the report left open: "no Slack or email is configured; `github-release` is on.
  Add one?" · "deploy block: is `web` the product project and `docs` quiet?" · "complexity:
  `standard` or `micro`?" · "personas?". It writes the P files, re-runs `setup.sh` until `OK`,
  and stops with the changes on a `claude/` branch for the operator to merge (a bare repo's first
  run is one PR; a maintenance run that changed nothing is a valid outcome and says so).
- **Template source for a bare repo.** `setup.sh` has **no default source**. `--template
  <path|url>` names one (a path or a tarball URL), or `ICM_TEMPLATE` in the shell does; the
  `/setup` skill run from Jamie's machine passes icm-board's checkout explicitly
  (`~/Apps/_system/template`). Nothing in a repo reaches for `../../_system` on its own — a
  relative default would be exactly the silent dependency on icm-board's layout that flag 1
  forbids, and it would resolve to nothing, or to something else, everywhere but one machine.
  A repo the dashboard created already carries the baseline, so
  "bare" is an adopted external repo, which is adopted from Jamie's machine anyway. If cloud-side
  bare setup is ever wanted, the template can be mirrored to a public `k0d0minio/icm-template` by
  icm-board CI on merge — T files carry no identity by construction (D20), so the mirror leaks the
  method and no client fact; whether the method is public is Jamie's call, and nothing here
  depends on it. Without a source, `setup.sh` reports `SKIP template (no source)` and still runs
  every in-repo check.
- **What moves.** `/project` loses § 1c and gains one precondition: "`/setup` reports `OK` (or
  the gaps are named in the run)". `start/06_repo` and `07_kickoff` say `/setup` where they said
  `icm-check.sh --fix` and `/project § 1c`. `/icm-check` stays the estate loop and, once every
  repo carries `setup.sh`, runs each repo's `setup.sh --report` instead of re-deriving the checks
  — one implementation, two callers. The dashboard's `createClientRepo` should scaffold from the
  same template (a jamienisbet ticket, outside this session).

### 4.8 Environment variables across five surfaces (flag 4)

**Evidence.** The estate env manager exists and is good: `_system/scripts/vercel-env.sh` owns
three one-way flows over one registry — notes (`.env.example` → Vercel comments), values (Vercel →
a generated `.env.local`), docs (notes interleaved into that file) — with `link`, `init`,
`push-notes`, `pull` and a read-only `audit`, and a `.env.example` convention (a `#` note directly
above a key is its note; an optional `[production|preview|development]` suffix scopes it; values
never). It runs from icm-board, over `vercel-env-registry.json`, on Jamie's machine only. The
cloud half is `vercel-env-hydrate.sh`: one repo, `pull` only, keyed on plain `VERCEL_TOKEN`. The
pipeline itself checks environment in two thin places: `env-check.sh` (are `required_env`
variables set in *this shell*) and the `production-readiness` skill (a human reads whether every
new `process.env` is in `turbo.json` `globalEnv` and in Vercel). GitHub Actions secrets and
variables, and the Claude cloud environment panel, are managed by hand and checked by nobody.

**The five surfaces a key can need to exist on**, and who can read each:

| Surface | Holds | Readable by a script | Writable by a script |
|---|---|---|---|
| Local `.env.local` | development values | yes (presence) | `vercel env pull` |
| Claude cloud environment panel | session variables (`VERCEL_TOKEN`, `GH_TOKEN`, …) | no — only its effect inside a cloud session | no (dashboard) |
| GitHub Actions secrets / variables | what the reference workflows need | names: `gh secret list`, `gh variable list` | `gh secret set`, `gh variable set` (stdin) |
| Vercel preview / production / development | the app's runtime | names, targets, comments: `GET /v9/projects/{id}/env` | `vercel env add NAME <target> [--sensitive] < file` (value on stdin) |
| The pipeline's own `required_env` | what `.icm/scripts` need | `env-check.sh` | — |

**Recommendation — `scripts/env.sh` (T), the per-repo generalisation of `vercel-env.sh`, driven by
the deploy block.** Same convention, same one-way flows, no registry: the Vercel projects and
paths come from `deploy.projects[]`, the token from `deploy.token_env` (or `VERCEL_TOKEN`), GitHub
from `lib/gh.sh` and the `gh` CLI. Verbs:

- **`audit [--changed]`** — names only, never values. Reads `.env.example` as the manifest and
  reports, per key and per surface it is scoped to: declared-but-missing and present-but-undeclared
  on Vercel (per project, per target), on GitHub (secrets and variables), locally (`.env.local`
  present and ignored), and in `required_env`. Adds the code's own reads: every `process.env.X`
  the tree reads (and `turbo.json` `globalEnv` where present) that `.env.example` does not
  declare. `--changed` limits it to keys the branch added — Build's pre-push check and Release's
  stop class 3 ("a new env var missing from wherever the repo declares its environment or from
  Vercel") become this one deterministic call. Surfaces it cannot read (the cloud panel) are
  listed as a checklist line, not a gap. `RESULT: OK | GAPS n`.
- **`init`** — seeds `.env.example` with Vercel's key names for every project in the deploy
  block, `# TODO: note` placeholders, `[targets]` from Vercel's own scoping; never overwrites,
  reorders or writes a value (the `vercel-env.sh init` rules, unchanged).
- **`pull`** — `vercel env pull` per project path into `.env.local` with the notes interleaved,
  refusing before the pull when `.env.local` is not ignored, and restoring the `.gitignore` line
  the CLI appends. The cloud hook `vercel-env-hydrate.sh` becomes a caller of this verb, so the
  local and cloud flows are one implementation. A key Vercel holds as `type: sensitive` cannot be
  read back by anyone — 248 of the estate's 464 documented keys at the epic's last count
  (`intake/vercel-env-system/breakdown.md`) — so the CLI leaves it out, `pull` writes it as
  `KEY=` under its note with one `# sensitive — paste locally` line, and `audit` reports it as
  *present on Vercel, not pullable*, never as missing. The value stays with the human; no
  pipeline script ever needs it.
- **`push-notes`** — `.env.example` notes → Vercel comments (REST, the `comment` field and
  nothing else; `TODO` placeholders skipped; the 500-character cap named, never truncated).
- **`add <KEY> [--targets production,preview,development] [--sensitive] [--github secret|variable]
  [--ci] [--note "<one sentence>"]`** — creates the variable where the flags say, **with the
  value read from stdin only** (`printf '%s' "$VALUE" | .icm/scripts/env.sh add KEY …` or
  `< file`), never from an argument, so it can never land in a transcript, a shell history or
  a log; `vercel env add KEY <target> [--sensitive]` per target per project (the documented
  `< [file]` form), `gh secret set KEY` / `gh variable set KEY` from the same stdin, then the key
  and its note appended to `.env.example` with the right suffix. No value on stdin → it prints the
  exact commands for the human and `RESULT: SKIP (no value on stdin)`. It never prints the value,
  never echoes stdin, and runs with tracing off.
- **`doc`** — the documentation half of flag 4 for a session that must not create anything:
  prints the `.env.example` block a new key needs (key, note, suffix) and the `audit` lines it
  would clear, so the agent's output is a diff to `.env.example` and a checklist for the
  dashboards, and the value stays with the human. *Documenting a variable means its key, its
  note and the surfaces it must exist on — never its value. That is the one place flag 4's
  wording is read narrowly, and deliberately: `.env.example` is committed, and the standing rule
  (§9, Secrets) admits no exception for it.*

**The `.env.example` convention grows two additive suffix tokens**: `[ci]` (the key must exist as
a GitHub Actions secret or variable — the reference release workflow's `RESEND_API_KEY`,
`SLACK_BOT_TOKEN`) and `[cloud]` (the key must be set in the Claude cloud environment panel —
`VERCEL_TOKEN`, `GH_TOKEN`). `audit` uses them to know which surface to check; the older three
tokens keep their meaning. A key with no suffix means all three Vercel targets, as today.

**Where it plugs in.** `/setup` runs `env.sh audit` (§4.7 section 4). Build's verify runs
`env.sh audit --changed` before the ready flip. Release step 4's readiness question becomes the
same call. `report.sh`'s `SKIPPED <channel>: <VAR> unset` names the `env.sh add … --ci` that
fixes it. icm-board's `vercel-env.sh` keeps its verbs and becomes the estate loop —
`for repo in registry: projects/<repo>/.icm/scripts/env.sh <verb>` — so one parser and one set of
rules exist, in the template, and the registry itself is regenerated from the repos' deploy
blocks (`vercel-env.sh registry`, read-only).

**Rules restated, all already the estate's:** values never in git, never in argv, never printed;
`.env.example` is the only committed file and carries keys and prose; a value moves Vercel →
`.env.local` and stdin → Vercel/GitHub, never the other way; `audit` is read-only in the strong
sense (`GET` only, no CLI); a plaintext credential found anywhere is a P0 to flag, not to commit
around.

### 4.9 Repo self-sufficiency — nothing calls icm-board at runtime (flag 1)

| Component | Runs in | Reads | Needs icm-board |
|---|---|---|---|
| `report.sh` | the repo (session or CI) | `project.json`, `lib/gh.sh`, the repo's own variables | never |
| `usage-snapshot.sh` + `lib/model-prices.json` | the repo (any harness) | the harness's own session store, the synced price table | never |
| `deploy-status.sh`, `rollback.sh`, `lib/vercel.sh` | the repo | `project.json → deploy`, the repo's Vercel token | never |
| `env.sh` | the repo | `.env.example`, `deploy`, the repo's Vercel and GitHub credentials | never |
| `setup.sh` | the repo | `.icm/MANIFEST`, `.icm/template-version`, everything above | only to **seed or sync T files**, via `--template`, and only then; every check runs without it |
| the reference workflows | the repo's CI | the repo's secrets | never (seeded once) |
| `icm-session-env.js` | Jamie's machine / the repo's `.opencode/` | nothing | never |
| `run-economics.sh`, `vercel-env.sh registry`, `icm-check.sh`, `icm-sync.sh` | **icm-board, Jamie's machine** | `projects/*` | by design — these are the estate's cross-repo tools, and a repo never calls them |

### 4.10 The local-shell ⇄ cloud-platform gap, in one table

| Platform | Template today | Gap | Closed by |
|---|---|---|---|
| GitHub | `lib/gh.sh`: curl with token → `gh` CLI fallback; `env-check.sh` verifies the route | none | — |
| Vercel (reads) | via GitHub commit statuses only; `vercel-env.sh` is estate-local; hydrate hook cloud-only | no transport, no project ids, no route check | `deploy` block · `lib/vercel.sh` · `env-check.sh` |
| Vercel (writes) | none | rollback/promote unnamed; env vars by hand | `rollback.sh` prints them; `env.sh add` creates variables from stdin |
| GitHub Actions secrets/variables | none | unchecked, hand-managed | `env.sh audit` / `env.sh add --ci` |
| Slack | a commented example in `notify.sh` | one kind, one channel | `report.sh` `slack` |
| Resend | none in the template (remi-ai precedent) | — | `report.sh` `email` |
| GitHub Releases | none | — | `report.sh` `github-release`, on by default |
| Usage / cost — Claude Code | none | no line, no reader, no price | `usage-snapshot.sh` transcript reader + `model-prices.json` |
| Usage / cost — OpenCode | none | no session id in the shell, no reader | the `shell.env` plugin + the SQLite reader |
| Setup and maintenance | from icm-board only | a repo cannot self-check | `/setup` + `setup.sh` + `.icm/MANIFEST` + `.icm/template-version` |
| Docker / AWS / Cloudflare | none | out of scope by decision 2 | — |

## 5. Recommended template changes — consolidated

| Path (relative to `.icm/` unless noted) | Owner | New / changed | What |
|---|---|---|---|
| `project.json` | P | changed | `deploy`, `reporting` (default `announce: ["github-release"]`, `announce_from: "session"`), `migrations` (§6) |
| `_shared/project-rules.md` (stub) | P | changed | *Announcing* → *Reporting*: kinds → channels, "none = a red job + Vercel's email"; *People* gains the client contact by variable name; *The factory* gains the migrations line and the env surfaces |
| `scripts/report.sh` | P | new, replaces `notify.sh` | kinds, channels, `--dry-run`, `SKIPPED` semantics (§4.0) |
| `scripts/notify.sh` | — | retired | MANIFEST line removed; reported for `git rm` |
| `MANIFEST` → `.icm/MANIFEST` | T | changed | seeded and synced into every repo; `.icm/template-version` written by `icm-sync.sh --apply` and `setup.sh --fix` |
| `scripts/lib/vercel.sh` | T | new | the one Vercel transport, read verbs incl. `vercel_env_list`, `--check` |
| `scripts/lib/model-prices.json` | T | new | the dated price table (§4.4) |
| `scripts/deploy-status.sh` | T | new | production state per project, previous READY id |
| `scripts/rollback.sh` | T | new | prepares revert PR and/or names the Vercel rollback; warns on migrations; never executes |
| `scripts/usage-snapshot.sh` | T | new | the `- usage:` line into `runs/<slug>/usage.md`, two readers, in-repo pricing, `--report` |
| `scripts/env.sh` | T | new | `audit · init · pull · push-notes · add · doc` over the deploy block (§4.8) |
| `scripts/setup.sh` | T | new | the idempotent house-cleaning report and `--fix` (§4.7) |
| `scripts/env-check.sh` | T | changed | Vercel route when `deploy` present; reporting variables as `[WARN]`; `python3`/`sqlite3` recommended |
| `scripts/ci-status.sh` | T | changed | expected-product-preview notice from `deploy.projects[]` |
| `scripts/new-run.sh` | T | changed | `--lane hotfix`; `--ready` opens the PR non-draft; `type:hotfix` label |
| `scripts/resolve-run.sh`, `project-labels.sh`, `close-out.sh` | T | changed | hotfix lane recognised; `usage.md` travels with the archive |
| `lanes/hotfix/CONTEXT.md` | T | new | §4.5 |
| `stages/01–04`, `lanes/*` | T | changed | usage-snapshot first/last act; `report.sh announce` (or `deferred to CI`); Build verify runs `env.sh audit --changed`; Release step 4 readiness → `env.sh audit --changed`, step 9 adds `deploy-status.sh` + the `- production:` line |
| `_shared/ci.md`, `lanes/chore`, `04_release` stop class 3 | T | changed | the revert wording; stop class 3 scoped to `migrations.reversible: true` and measured by `env.sh audit --changed` |
| `_shared/github.md` | T | changed | lane list gains hotfix; a hotfix PR opens ready; `type:hotfix` in the label vocabulary |
| `_system/template/claude-pipeline/skills/setup/SKILL.md` | canonical asset | new | the `/setup` command, seeded beside the router (§4.7) |
| `_system/template/root/.opencode/plugins/icm-session-env.js` | canonical root asset (optional) | new | the `shell.env` bridge (§4.4a) |
| `_system/template/github-pipeline/workflows/{release,labels}.yaml` | reference | new | seeded once by `/setup` (`announce_from: ci` repos). Under `github-pipeline/`, the folder `icm-check.sh --fix` already copies to `.github/` beside the PR template (`template/README.md`), so `.github` has one source — and **not** in its `PIPELINE_GITHUB` list, so the estate walk never seeds a workflow uninvited |
| `_system/template/claude/hooks/vercel-env-hydrate.sh` | canonical asset | changed | calls `.icm/scripts/env.sh pull` where the repo has it; keeps its own path otherwise |
| `_system/scripts/vercel-env.sh` | icm-board | changed | the estate loop over each repo's `env.sh`; `registry` verb regenerates `vercel-env-registry.json` from the repos' deploy blocks |
| `_system/scripts/run-economics.sh` | icm-board | new | per-client roll-up → `workspaces/deals/<slug>/economics.md` (§4.4) |
| `workspaces/deals/*/DEAL.md` | icm-board | changed | `- repo: <owner/name>` header line as the join key |
| `workspaces/deliver/stages/project/CONTEXT.md` | icm-board | changed | § 1c removed; precondition "`/setup` reports OK"; § 3's "pipeline setup" rounds and § 6's P-file writing move to the `/setup` skill |
| `workspaces/deliver/stages/conformance/CONTEXT.md` | icm-board | changed | `/icm-check` runs each repo's `setup.sh --report` where present |
| `workspaces/start/stages/{06_repo,07_kickoff}/CONTEXT.md`, `references/kickoff-checklist.md` | icm-board | changed | `/setup` replaces `icm-check.sh --fix` and `/project § 1c` |
| `_system/contracts/PIPELINE.md`, `_system/README.md` | icm-board | changed | `pipeline-full` row → "reporting kinds and the reference workflows"; the file table gains the new scripts and the in-repo MANIFEST |
| `.icm/project.md` | icm-board | changed | decision **D23** recording all of the above |
| sustentus `.github/workflows/release.yaml`, `.icm/project.json`, `project-rules.md` | repo (a separate session, Jamie's PR) | changed | calls `report.sh`; channel ids into `project.json`, `announce_from: ci`; `notify.sh` removed — the first sync target, as for D20 |
| jamienisbet `createClientRepo` | repo (a ticket there) | changed | scaffolds the baseline from the same template — outside this session |

Every T addition is a one-job script under D11 (reports, prepares, never advances); every P
addition is configuration a repo owns. No new gate; no script crosses an existing one; no script a
repo carries reads anything outside the repo.

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
    "announce_from": "session",
    "announce":  ["github-release"],
    "alert":     [],
    "economics": [],
    "channels": {
      "github-release": { "tag_prefix": "release/" },
      "slack":          { "token_env": "SLACK_BOT_TOKEN", "announce_channel_env": "SLACK_ANNOUNCE_CHANNEL_ID", "alert_channel_env": "SLACK_ALERTS_CHANNEL_ID" },
      "email":          { "api_key_env": "RESEND_API_KEY", "from_env": "REPORT_EMAIL_FROM", "to_env": "REPORT_EMAIL_TO" }
    }
  },

  "migrations": { "path": "packages/services/migrations", "reversible": false }
}
```

The seeded stub ships exactly the `reporting` block above minus the `slack`/`email` entries'
variables being set anywhere — `github-release` works from the first merge, and adding Slack or
email is editing two arrays. Variable *names* only, never values; a missing block reads as "not
declared", never an error (`lib/project.sh` defaults; the old `migrations_path` string is still
read as `migrations.path`); `alert: []` is a decision `/setup` asks about and records, and it
means a red job. Sustentus's block reads `announce_from: "ci"`, `announce: ["slack",
"github-release"]`, `alert: ["slack"]`, `migrations.reversible: false`, with `smoke_check`
unchanged beside it.

## 7. Build order — one session, dependency-ordered

Not stubs. Work packages for one implementation session in this repo, on one `claude/` branch,
one PR. Each package ends with the proof in §8 that applies to it.

1. **Reporting hook.** `report.sh` (three channels, `github-release` default, `announce_from`,
   `--dry-run`) + the `reporting` block + the `project-rules.md` stub rewrite; `notify.sh` retired
   from the MANIFEST; Release step 9 and the lanes call `report.sh`.
2. **Deploy block and the Vercel library.** `deploy` and `migrations` in `project.json`,
   `lib/vercel.sh`, `env-check.sh` and `ci-status.sh` reading them; `lib/project.sh` defaults.
3. **Environment.** `env.sh` with all six verbs, the two new `.env.example` suffix tokens, the
   Build/Release calls; `vercel-env-hydrate.sh` delegating to it; `vercel-env.sh` looping over
   repos and gaining `registry`. *Depends on 2.*
4. **Production read at Release.** `deploy-status.sh` + the `- production:` line. *Depends on 2.*
5. **Hotfix lane and prepared rollback.** `lanes/hotfix/`, `new-run.sh --lane hotfix --ready`,
   `resolve-run.sh` / `project-labels.sh`, `rollback.sh`, the revert-wording sweep, stop class 3
   scoped to `migrations.reversible`. *Depends on 2 and 4.*
6. **Usage on the run.** `usage-snapshot.sh` with both readers and in-repo pricing,
   `lib/model-prices.json` from the `claude-api` skill, the two calls in every stage and lane,
   `usage.md` in the archive path, `icm-session-env.js` as a canonical root asset. *Independent.*
7. **Economics roll-up.** `run-economics.sh`, the `- repo:` line in every `DEAL.md`,
   `economics.md` shape. *Depends on 6.*
8. **`/setup`.** `.icm/MANIFEST` as a T file, `.icm/template-version`, `setup.sh` with the ten
   sections, the `setup` skill beside the router, `/project` § 1c removed and its questions
   re-homed, `start/06`, `07` and the kickoff checklist pointing at `/setup`, `/icm-check`
   calling `setup.sh --report`. *Depends on 1–3 and 6 (it checks all of them).*
9. **Reference workflows.** `_system/template/github-pipeline/workflows/{release,labels}.yaml`
   seeded by `/setup` for `announce_from: ci` repos. *Depends on 1, 8.*
10. **Contracts, PIPELINE.md, D23.** The wording sweep across `PIPELINE.md`, `_system/README.md`,
    `github.md`, `ci.md`, the chore lane, and the D23 row in `.icm/project.md`; the parked
    `profile-wording-sweep` stub's files may be touched where the same sentence is being edited
    anyway. *Last.*

Sustentus adoption (its `release.yaml` → `report.sh`, ids into `project.json`, `notify.sh`
removed, `icm-sync.sh --apply`) and the dashboard's `createClientRepo` are **separate sessions in
those repos** — never from this one.

## 8. Definition of done — what the session proves before its PR opens

- `_system/scripts/self-check.sh` passes, and every new script has a header in the house shape:
  what it does, what it never does, `Usage:`, `Verdict:`.
- `icm-sync.sh projects/sustentus` (dry run) lists exactly the new and changed T files and nothing
  else; `icm-check.sh --repo projects/sustentus` reports the expected drift and no missing P file
  once the stubs are seeded. Neither is applied. **Sustentus's `main` on disk is still pre-D20**
  (no `.icm/project.json`, no `env-check.sh` — checked 2026-09-22); the D20/D22 sync lives on its
  local, unpushed branch `claude/icm-pipeline-file-ownership` (four commits, `189a3e7` →
  `3532e30`). Both proofs run with that branch checked out, and its `project.json` is the one the
  §6 sustentus block extends — pushing and merging it is Jamie's, in that repo, before adoption.
- **Self-sufficiency:** every new script under `.icm/scripts/` runs to a `RESULT:` line inside a
  scratch clone of this repo made *outside* `~/Apps` with `HOME` pointed at an empty directory
  and no `_system/` in reach — `report.sh --dry-run`, `env.sh audit`, `usage-snapshot.sh`,
  `deploy-status.sh` (with no `deploy` block: `not declared`), `setup.sh` (no template source:
  `SKIP template`). Nothing in that run reads a path outside the clone.
- `setup.sh --fix --template <icm-board's template>` on a scratch bare repo (`git init` in the
  scratchpad) seeds the baseline and a second run prints `RESULT: OK`; on this repo, `setup.sh`
  prints `OK` or a named `GAPS` list, and `setup.sh --report` is byte-identical on two consecutive
  runs.
- `env-check.sh` on this repo: `PASS`, with the Vercel route line present when `deploy` is
  declared and `[INFO] deploy not declared` when it is not.
- `env.sh audit` on a scratch copy of sustentus's `deploy` block (read-only, not committed there)
  prints names-only rows per project and target and a `RESULT:`; `env.sh add TEST_KEY --targets
  preview` with empty stdin prints the two exact commands and `RESULT: SKIP (no value on stdin)`
  and creates nothing; `env.sh doc TEST_KEY --note "x" --ci` prints a valid `.env.example` block.
- `usage-snapshot.sh icm-self-test scope start` then `… end`, run inside the implementing session,
  writes two lines with `harness=claude` (or `claude-cloud`), `source=transcript`, a non-zero
  `cache_read`, a numeric `cost_usd`, and `session=$CLAUDE_CODE_SESSION_ID`; the same pair under
  `opencode run` on Jamie's machine writes `harness=opencode source=sqlite` with the plugin
  installed and `source=skip` with `--pure`. The test run folder is deleted before the commit.
- `run-economics.sh --repo icm-board` renders a table from those lines and names the price
  table's `as_of` date.
- `report.sh announce "x" --dry-run` with the seeded default prints the GitHub Release payload
  (tag `release/<today>-x`) and sends nothing; with `announce: ["email"]` and `RESEND_API_KEY`
  unset prints `SKIPPED email: RESEND_API_KEY unset`; with `announce: []` prints
  `SKIPPED (no channel for announce)`; all exit 0.
- `deploy-status.sh --sha <a recent sustentus main sha>` against the scratch deploy block prints
  one line per product project and a `RESULT:`; `rollback.sh --sha <that sha> --vercel` prints the
  rollback call and `RESULT: PREPARED` without opening anything.
- `new-run.sh <slug> --lane hotfix --summary "x" --dry-run` prints a lane body with no gate
  anchors and the `type:hotfix` label named.
- `validate-decisions.sh`, `validate-spec.sh` and `validate-intake.sh` are untouched and still
  `RESULT: OK` on this repo's own intake.
- CI on the PR is green. **No local `build`, `lint`, `typecheck` or `test` was run** — CI is the
  verdict.

## 9. Constraints for the session

- **Repo boundary.** Everything lands in icm-board, on one `claude/` branch, one PR. Nothing under
  `projects/` is modified — sustentus is proven against read-only, and adopts in its own session.
- **Self-sufficiency is a hard rule.** No script, hook, skill or default a repo carries may read
  or call anything outside that repo at runtime; the one exception is `setup.sh --template`, which
  is explicit, optional, and reports `SKIP` when absent.
- **Ownership.** T files carry no identity (no owner name, channel, team, path, address). P files
  are stubs the repo fills. New T files are added to the MANIFEST; nothing else can be synced.
- **Secrets.** A value enters a script only on stdin and leaves it only toward Vercel or GitHub;
  never argv, never stdout, never git, never a transcript. `.env.example` carries keys and prose.
- **Doctrine.** No orchestrator (D3, D11): every script reports or prepares; nothing watches,
  retries, or crosses a gate. Gates stay two and stay human. Fix-forward stays the default.
  `report.sh` exits 0 always. Nothing is sent from the implementing session.
- **Harness facts are verified, not assumed.** Where the report cites a hook signature or an
  environment variable, the session confirms it on the installed binary before relying on it.
- **Prices come from the `claude-api` skill**, never from memory, and the table is dated.
- **No stubs.** The session does not cut tickets from this document; findings it cannot finish
  become one triage stub each, in the ordinary way, named in the PR.

## 10. Settled by research — the former open points, and the four flags

| Point | Resolution | Evidence |
|---|---|---|
| **Runtime dependence on icm-board (flag 1)** | None, by rule (§4.9, §9). Prices are synced as a T file so a repo prices its own lines; `setup.sh` needs a template source only to seed or sync, and says `SKIP` otherwise; the cross-repo tools stay in icm-board and are never called by a repo. | The registry is invisible to a cloud session (`vercel-env-hydrate.sh` header); a fine-grained token for a client repo cannot read icm-board. |
| **Default announce channel (flag 2)** | `github-release`, on in the seeded stub; Slack and email are additive; `announce_from` decides the one caller. | A Release needs only the GitHub route every repo has (`lib/gh.sh`); idempotent by tag. |
| **Setup command (flag 3)** | `/setup` + `setup.sh` seeded into every repo; `/project` § 1c removed; `.icm/MANIFEST` and `.icm/template-version` make completeness and currency answerable offline. | `/project` § 1c is four steps whose first is empty after D22 (parked stub `profile-wording-sweep`); the MANIFEST "stays in the template" today. |
| **Template source for a bare repo** | Named explicitly every time — `--template <path\|url>` or `ICM_TEMPLATE`, no default; the `/setup` skill passes icm-board's checkout on Jamie's machine; the dashboard scaffolds the baseline for repos it creates; a public mirror only if cloud-side bare setup is ever wanted, and that is Jamie's call. | Flag 1 (§9): a relative default is a hidden reach outside the repo; D19: `createClientRepo` scaffolds the baseline; D20: T files carry no identity. |
| **Env management (flag 4)** | `env.sh` in the template, driven by the deploy block, six verbs, `[ci]` and `[cloud]` suffixes; values on stdin only; `vercel-env.sh` becomes the estate loop. | `vercel-env.sh` header (three one-way flows, the convention); `vercel env add [name] [environment] < [file]` and `--sensitive` in the Vercel CLI docs; `gh secret set` reads stdin. |
| **OpenCode usage source** | SQLite read, keyed by `OPENCODE_SESSION_ID` from a `shell.env` plugin; children by `parent_id`; cost as recorded. | `opencode.db` schema and rows; `@opencode-ai/plugin` 1.18.25 `index.d.ts` lines 235–248; `OPENCODE_DB` in the binary and the docs; `export` and `session list --format json` shapes; `stats` is human-only. |
| **Claude Code local source** | Transcript by `CLAUDE_CODE_SESSION_ID`; dedupe by `requestId`; subagents under `<session>/subagents/`. No `CLAUDE_ENV_FILE`. | `env` in this session; this session's transcript (113 lines / 18 requests); claude-code issues #15840, #11649. |
| **Claude Code cloud source** | Same transcript reader (`/root/.claude/projects/…`); the session record is a cross-check. | sustentus `docs/token-metrics.md` → "What was verified". |
| **Where the usage line lives** | `runs/<slug>/usage.md`, not `run.md`. | Scope has no `run.md` at entry; `run.md` is parsed by three scripts. |
| **Registry vs `deploy` block** | The repo's `deploy` block is authoritative; the registry is regenerated from it. | A cloud session cannot see `projects/` or the registry; the block is the only copy every session can read. |
| **GitHub Release tag and audience** | `release/<YYYY-MM-DD>-<slug>`; one per merge, audience `public` by default; `audience: internal` or `announce: none` on the run is the only opt-out. | Unique per run, sortable, no counter; flag 2 says "always on", so the changelog index's `internal` rule is kept as the opt-out, not the gate. |
| **Client email recipients** | Variable names (`REPORT_EMAIL_TO`, `REPORT_EMAIL_FROM`) in the repo's environment, `[ci]`-scoped in `.env.example`. | T files carry no identity (D12/D20); a client-owned repo must not carry Jamie's routing. |
| **Hotfix cadence on sustentus** | Opens ready; the first ready push builds all three product apps and that cost is accepted on an incident. | sustentus `project-rules.md` → "the first ready push always builds all three"; decision 4. |
| **Forward-only migrations vs stop class 3** | `migrations.reversible` in `project.json`; stop class 3 scoped to reversible repos; `rollback.sh` warns when not. | `db-migrate.yaml` ("forward-only and idempotent") against `04_release` stop class 3. |
| **`economics` as a kind** | Kept; maps to no channel by default; no digest templated. | The daily digest is sustentus-only. |
| **Alert channel** | Abstracted (§4.0); "none" is a red job plus Vercel's email. | Jamie's correction, 2026-09-22. |

**Operator actions the session cannot do**, listed so nothing is left implicit: paste
`VERCEL_TOKEN` (and per-team tokens) into the cloud environment panels and GitHub secrets where
`deploy-status.sh`, `env.sh` or a reference workflow will run; set `REPORT_EMAIL_*`,
`RESEND_API_KEY` and the Slack variables per repo (`env.sh add … --ci` does the mechanics once
the value is on stdin); install `icm-session-env.js` into `~/.config/opencode/plugins/`; add
`type:hotfix` to each repo's `.github/labels.yml` on adoption; decide whether the template is
ever mirrored publicly.

## 11. What this deliberately does not change

- **Never build an orchestrator.** Every new script reports or prepares: `deploy-status.sh` looks
  once, `rollback.sh` writes a PR and a command, `usage-snapshot.sh` appends a line, `env.sh`
  creates only what a human handed it on stdin, `setup.sh` seeds only what is missing,
  `report.sh` sends what a human-authorised merge produced. Nothing watches, nothing retries,
  nothing crosses a gate (D3, D11).
- **Gates stay human, and stay two.** Decision 1 keeps the business out of the PR; the hotfix
  lane's gate is the merge button like every lane.
- **Fix-forward stays the default.** A revert becomes *available*, prepared and named, and is
  still the operator's click.
- **T files carry no identity, and no repo reaches outside itself.** Channels, teams, tokens and
  addresses are variable names in P files; the contracts say "see `_shared/project-rules.md` →
  Reporting" (D12, D20); the cross-repo tools stay in icm-board and are never called from a repo.
- **CI is the verdict; reporting is never a gate.** `report.sh` exits 0 always; the red job is the
  alert, not a blocker.
- **Drift is reported, never repaired**, except the one human-invoked sync (D20) — `setup.sh
  --fix` seeds and never overwrites, exactly as `icm-check.sh --fix` does.
- **Sustentus stays the reference and the first sync target**, exactly as D20 did it.
