# Estate audit — 2026-09-26

*Read-only audit of icm-board, all 27 repos under `projects/`, and every open intake stub (321),
run 2026-09-25/26 on Jamie's request: discrepancies, visible drift, triage validity against the
code, and template improvements. Nothing was modified: no ticket moved, no file edited outside
this report. Evidence is a path, a commit or a command output; where the auditors could not
verify, the item says UNCLEAR and carries the question. Method: `icm-check.sh`, `icm-sync.sh`
(dry), `ticket-hygiene.sh`, `tickets-board.sh`, `self-check.sh`, `validate-deal.sh --all`,
`run-economics.sh --print`, each pipeline repo's own `setup.sh --report`, `gh` for PRs / CI /
visibility, then eight read-only agents (one per repo group) verifying every stub against
`main`, plus one online research pass (sources in § 6).*

| Measure | Value |
|---|---|
| Repos walked | 28 (icm-board + 27) · 9 pipeline · 18 dormant · 1 no-pipeline active (dungeons-dragons) |
| Open stubs examined | 321 (191 triage · 130 epic) |
| Verdicts | VALID 284 · RETIRE 13 · DUPLICATE 7 · LIKELY-SHIPPED 3 · IN-FLIGHT 8 · UNCLEAR 6 |
| Triage only | 191 → VALID 169 · RETIRE 13 · DUPLICATE 7 · UNCLEAR 2 |
| Template-owned files | 9/9 repos in sync (`icm-sync.sh` dry-run 0 changes) |
| Canonical `.claude/` assets | 27/28 repos GAP on `agents/project-lens.md` + `ticket-scout.md` (#91 today, no fan-out stub) |
| Baseline copies | 52 drift warnings (parked: `triage/refresh-baseline-copies`) |

---

## 0. Act first

### P0 — icm-board is a public repository

`gh api repos/k0d0minio/icm-board` → `"private": false`; an unauthenticated `GET
https://github.com/k0d0minio/icm-board` returns 200. The repo's own doctrine says the
opposite: [`AGENTS.md:67`](../../AGENTS.md) ("`workspaces/deals/` is committed (private repo…"),
[`workspaces/deals/README.md:4`](../../workspaces/deals/README.md), decision D5, and the
constraint "this repo is private and `_system/AUDIT.md` is one reason why".

What is tracked and therefore public today:

- eleven `DEAL.md` files — client first names, deal shapes, agreed sums (berceo €7,500 fixed,
  casey-hebbel €800, the REMI equity partnership, the sustentus retainer, the miriamfridman
  barter, the lost barzinho deal);
- `berceo/04-devis-berceo.pdf`, `berceo-platform/{03-quote,04-devis-berceo,05-agreement}.md`,
  `casey-hebbel/opening-night/{02-discovery-notes,03-quote,04-proposal}.md`;
- five files under `private/`: `cafe-jardim` and `little-grass-shack` `private/pricing.md`
  (each with a € figure), `remi-ai`, `sustentus` and `miriamfridman` `private/terms-sheet.md`
  (skeletons, headings and `[LAWYER]` slots);
- `_system/AUDIT.md`, which names an unrevoked API key in a client repo and a history scrub not
  done;
- `run-economics.sh` writes `private/economics.md` (token cost per client) into these folders.

How long it has been public is not knowable from the API. **Action (Jamie's, account
setting):** flip the repo to private; then decide whether the `private/` content that was
exposed changes anything with those clients. If it must stay public for any reason, the deal
workspace cannot live here (D5/D24 would need superseding) and `workspaces/deals/**/private/`
must at least be ignored.

### P0 — client documents in public client repos

Twenty of the 27 client repos are public (only barzinho, casey-hebbel, lourenco-botelho,
messy-play, serviflow, sustentus and the-library are private). D43 reads as if that is a
deliberate cost choice (free Actions minutes). But several public repos track client-supplied
documents under `.icm/docs/`:

| Repo (public) | Tracked under `.icm/docs/` |
|---|---|
| remi-ai | 62 files, including `braindump/journal-du-createur/registre-des-actionnaires.pdf` (a shareholder register — the very thing the REMI memory says must stay out of the public repo), `collaboration/fagron-meeting-playbook.docx`, `call-summary.pdf` |
| agorasim | `2026-07-23-agorasim-proposal-platform-booking-commission.pdf`, `agorasim-commission-and-payments-agreement.pdf`, `agorasim-info.pdf`, `prices.pdf`, the process guide |
| berceo | `berceo-answers.pdf` (the 40-page answers document declared the source of truth), `cahier-des-charges.md` |

**Action (Jamie's):** per repo, either flip to private (Free plan: 2,000 Actions minutes/month,
Linux $0.006/min — see § 6) or purge the documents and their history. A `.gitignore` rule
alone does not remove what is already pushed.

### P0 — kau-american-bbq: the seeded admin password is still tracked

`triage/rotate-seeded-admin-password` (P0, cut 2026-08-31, no activity since) is still true:
`drizzle/0006_kau_accounts_and_settings.sql:9` carries the plaintext seed (`#17` stripped only
`0001`), the stub itself repeats the password on lines 14 and 28 and carries two real client
e-mail addresses. The repo is public. Rotation is unconfirmed.

### P1 — sustentus: every release announcement has failed since 2026-09-25

`release.yaml` → "Announce and verify" fails on every run (the last 20 checked; e.g. run
36223475725, 2026-09-26): `report.sh announce` and `report.sh alert` both end
`SKIPPED slack: Slack rejected the post: invalid_json`. Consequences: `health-check.sh` alerts
reach nobody, and the job's "#alerts has been told" line is false. No stub records
`invalid_json`; `triage/slack-reporting-unproven` should be re-cut as a `bug`.

The likely mechanism is in the **template**, not only in sustentus's copy:
[`_system/template/icm-pipeline/scripts/report.sh:162-163`](../../_system/template/icm-pipeline/scripts/report.sh)
pipes a curl config containing `data = @-` (read the body from stdin) into `curl --config -`
(which has already consumed stdin) **and** passes `--data-binary "$payload"`; curl joins
multiple data parts with `&`, so Slack receives `&{…}` or `{…}&`. The Resend branch at
`:183-184` has the identical shape, so e-mail reporting is presumed broken everywhere too.
`report.sh` is project-owned (`P`), so each repo fixes its own copy; the template stub must be
fixed for future seeds. Verify with `report.sh --dry-run` plus one real post.

### P1 — serviflow: a customer-visible data exposure has no ticket

`ops-events-staff-only` release notes (`.icm/runs/_done/…/release.md:34`) record that customer
sockets still receive `chat:new_request` events carrying other customers' problem descriptions.
The only carrier is draft PR #90 (spec only, 2026-09-21, no stub on `main`). Cut a `bug` stub.

### P1 — sustentus: two open PRs claim the same migration stamp

`#1199` adds `1790900000006-invoice-id-index.ts`; `#1201` adds
`1790900000006-brd-release-role-templates.ts` (+ `…007`). Whichever merges second must
re-stamp. Five of the six open PRs also edit `apps/web/components/workspace/aggregate.ts`,
`lib/queries/workspace.ts` and `lib/workspace/levers.test.ts` — expect conflicts after the
first merge.

### P1 — casey-hebbel `triage/react-patch`

`package.json` still pins `next 16.0.10`, `react`/`react-dom 19.2.0` past the RSC advisories
the stub cites (P1, 2026-09-25).

### P2 — AUDIT.md records a fix that never landed

`_system/AUDIT.md` § Done says garmani's `.env` was untracked on `claude/untrack-env`
(2026-09-03). `git -C projects/garmani ls-files` still lists `.env` (content:
`NEXT_PUBLIC_SITE_URL` only, so not a secret); there is no such branch or PR on
`k0d0minio/garmani`.

---

## 1. icm-board against its own rules

### 1.1 The register (`.icm/project.md`)

- **Duplicate decision ID.** Two rows are numbered D45 (line 117 "`/setup` absorbs `/project`",
  line 119 "baseline micro-copies drift-reported"), with D44 between them.
  [`PROJECT.md`](../../_system/contracts/PROJECT.md) says "stable IDs, never reused". The second
  D45 should become D46, and every reference to it (`icm-check.sh` comments, the
  `refresh-baseline-copies` stub, memory) follows.
- The header still says "Not yet a `/project` run — the empty sections below are real gaps"
  above 45 decisions and 40 run-log rows.
- Open question 1 (roster from the org listing or from Neon) is answered by code:
  `estate-conformance.sh:72` walks `/user/repos?affiliation=owner` — 33 repos, seven of which
  are not on disk (ericeirafishing, gui-demo, houseoftherisingmojo, maja-grunzner,
  sell-my-stuff, shake-easy, website-starter; three others archived). Record it or change it.

### 1.2 Documents that no longer say what the system does

| File | Stale statement | Truth |
|---|---|---|
| [`_system/AUDIT.md`](../../_system/AUDIT.md) | header: control layer lives in the `k0d0minio/jamienisbet` monorepo | D1 (2026-08-26): icm-board is its own repo |
| `_system/AUDIT.md` § generations | sustentus "exempt / source"; remi-ai "0 runs"; tenderdesk and learn-with-jake-van-clief listed | D44; remi-ai has 20+ archived runs; neither repo is on disk or in the org |
| `_system/AUDIT.md` § broken config | remi-ai `route-request.sh` unregistered | registered (`.claude/settings.json:145`) — fixed |
| `_system/AUDIT.md` § broken config | sustentus dead `impeccable` hook | still dead: `.claude/settings.local.json:57` points at a `hook.mjs` that does not exist (local file, not tracked) |
| `_system/AUDIT.md` § broken config | courseday `caveman-mode` skill | still wrong: `AGENTS.md:77` names `caveman-mode`, the folder is `caveman` (repo dormant) |
| `_system/AUDIT.md` § decisions needed | #8 scheduled routines "none exist"; #9 tenderdesk/courseday | the `estate-housekeeping` routine and the daily `estate-conformance` cron exist; tenderdesk is gone, courseday is dormant — both answerable; #5 (`gh` CLI) and #6 (≤50-line rule) genuinely open |
| `_system/AUDIT.md` § security | P2 remi-ai `Bash(cat > *)`, home-wide `Read()` | gone; what remains is `Bash(git push:*)` on allow in agorasim, remi-ai, sustentus |
| [`_system/contracts/PIPELINE.md:4`](../../_system/contracts/PIPELINE.md) | sustentus's `.icm/` "stays exempt from the estate baseline" | D44 |
| [`workspaces/deals/sustentus/DEAL.md:14`](../../workspaces/deals/sustentus/DEAL.md) | "exempt from the estate baseline" | D44 |
| [`_system/README.md:18`](../../_system/README.md) | "scripts/ ← the seven executables" | 13 scripts; `env-audit-stability.sh` and `icm-sync-branch-guard.sh` (both run by CI) are absent from the table |
| [`_system/template/README.md:134`](../../_system/template/README.md) | `workflows/{release,labels}.yaml` | no `labels.yaml`; `quality.yaml`, `db-migrate.yml`, `uat-deploy.yaml`, `{neon,mongodb}-cleanup.yaml` exist |
| `_system/template/README.md`, `PIPELINE.md` | — | `_shared/output.md` (D40, a `T` file) is documented in neither |
| [`workspaces/deals/berceo`](../../workspaces/deals/berceo/berceo-platform/) | `validate-deal.sh --all`: `agreement tier 'full-build' is not a tier the quote offers` | `03-quote.md` has no tier table; `05-agreement.md` says `- tier: full-build` — either name the tier in the quote or add `- deviation:` |

### 1.3 The contract and the template disagree

`_system/contracts/TICKETS.md` (the estate spec, the dashboard's contract) and
`_system/template/icm-pipeline/intake/CONTEXT.md` (the `T` file every pipeline repo carries)
describe two different stubs. Every pipeline repo follows the template; the tooling is split.

| Point | TICKETS.md | template `intake/CONTEXT.md` | Who reads what |
|---|---|---|---|
| Epic field | `- epic:` / breakdown `- epic-slug:` | `- scope:` / `- scope-slug:` (+ `personas`, `initiative`, `complexity`, `recommended-model`) | dashboard `tickets.ts` reads `epic:` ×10, never `scope:`; `validate-intake.sh` reads `scope-slug` |
| `## Prompt` | "required in every stub" | absent from both stub shapes (only the template-change stub has one) | `ticket-hygiene.sh` `no-prompt` fires only where there is no `/pipeline` (D26) |
| Priority | `- priority: P0..P2` (the board ranks on it) | not listed; sustentus stubs carry `- severity:` | `tickets-board.sh` ranks on `priority` |
| Dropped work | "nothing is deleted … `> Dropped:`" | "an entry nobody will ever pick up is deleted, not hoarded" | — |
| Archive | `intake/_done/<epic>/` | `project.json → intake_archive` (sustentus: `apps/docs/archive/pipeline-intake`, 30+ epics; its `intake/_done/` is empty) | `close-out.sh` uses the archive path |
| Triage cap | none | 60 active stubs, a stop-message line | sustentus holds 87 |

Consequence in the numbers: 0/44 + 0/43 sustentus triage stubs, 62/78 sustentus epic stubs,
21/21 serviflow, 14/25 remi-ai, 6/11 jamienisbet, 4/23 agorasim and 2/24 berceo have no
`## Prompt`. That is the template's park step doing exactly what it says, not 100+ bad stubs.
One document must change (question 2 and 3 in § 5).

### 1.4 Scripts and CI

- **`estate-conformance.sh` no longer mirrors `icm-check.sh`.** It checks only
  `session-start.sh`, `wrap-reminder.sh`, `ticket-craft`, `pr-conventions` and `opencode.jsonc`
  (lines 143-171); not `install-deps.sh`, `route-request.sh`, `vercel-env-hydrate.sh`, any
  `agents/*`, nor the MANIFEST. Yesterday's cron said "26 conformant · 0 with gaps" while
  `icm-check.sh` says 27 with gaps. The header's "mirrors icm-check.sh's severity model
  exactly" is false since D44.
- **`ticket-hygiene.sh` `off-ticket` counts plumbing as work.** barzinho, dungeons-dragons and
  escondidinho are flagged, but their only commits in 14 days are the 2026-09-24 `.claude/`
  fan-out. Exclude `.claude/`, `CLAUDE.md`, `AGENTS.md`, `opencode.jsonc` and `.icm/` from the
  "work" filter, or mark barzinho and escondidinho dormant.
- **`run-economics.sh` is blind for Opus 5.5.** `usage-snapshot.sh` records
  `model=anthropic/claude-opus-5-5`; [`model-prices.json`](../../_system/template/icm-pipeline/scripts/lib/model-prices.json)
  (`as_of 2026-06-24`) has no `claude-opus-5-5` row, so 29 of sustentus's 30 priced runs read
  `unknown` and the deal economics D23 depends on say "3.31 USD + unknown". Add the row
  ($4/$20 per MTok, § 6), refresh the table (Sonnet 5's $2/$10 is now permanent), and make the
  roll-up name the unpriced model instead of printing `unknown`.
- **`setup.sh` warns unconditionally.** All nine pipeline repos get `required_checks is empty`
  although D43 made the deploy status the verdict; six get `database.isolation: none — does
  this repo have a database?` although sustentus declares `provider: mongodb` and jamienisbet
  Neon, both with `none` chosen deliberately (D36, memory). serviflow's `env.sh audit` reports
  **128 gaps** because the template has zero Railway awareness (`deploy.provider: ""`,
  `project-rules.md:43` says Railway). Real rows in the same reports: remi-ai `FAIL run
  september-sources` (closed out on GitHub by #132 at 20:19Z yesterday — the local clone is one
  commit behind, so the hygiene finding is stale by one `pull-all`), sustentus env gaps 17,
  lourenco-botelho `health_endpoint` empty.
- **icm-board's own `session-start.sh` drifts from the template** (the template gained the
  cloud-rsync step and the skills registry; the board's copy is older). The one drift line
  `icm-check.sh` reports for `Apps` is real.
- `.claude/settings.local.json` (machine-local, ignored) still allows `pnpm build/lint/
  typecheck`, `next dev` kills and `./scripts/new-project.sh` — pre-split jamienisbet cruft that
  contradicts "never run local checks". Its `pull-all.sh` SessionStart entry runs from
  `$CLAUDE_PROJECT_DIR`, so in a worktree it pulls nothing ("1 skipped").
- `self-check` (links + tickets) is clean; the two failures 4 h before this audit were fixed on
  the next push. `estate-conformance` cron is green daily — for the wrong reason (above).

### 1.5 Loops that are open

- **D33 has never closed.** Twelve `found-by: template-change` stubs sit in five repos; icm-board's
  triage holds one stub, unrelated. Two of the twelve were fixed upstream and synced back
  without the stub retiring (sustentus `…mongodb-database-isolation`, `…session-start-rsync`).
  The eight distinct template faults still owed here:
  1. `close-out.sh:219` — `git mv` with no prior `git add -A` / `usage.md` never staged
     (agorasim `template-change-close-out-usage-end-line`, sustentus
     `template-change-close-out-stages-usage-end`);
  2. `env.sh:239/415` — `IFS=$'\t' read -r key targets note` loses the note when `targets` is
     empty (agorasim `…env-audit-empty-targets`, sustentus `…env-audit-count-unstable` fault 2);
  3. `ci-status.sh:385` — GREEN settles before the ready head's checks post (sustentus
     `…ci-status-green-before-previews-post` + its duplicate `…premature-full-gate-green`);
  4. `deploy-status.sh:23,50,173` — a CANCELED deployment not caused by the ignore step stays
     ERROR (sustentus `…deploy-status-superseded-cancel`);
  5. `skills/database-migration/SKILL.md:108` — still says every preview reads its own database
     (sustentus `…preview-db-migration-gate`);
  6. `stages/03_build/CONTEXT.md:184` — the `--allow-empty` ready flip builds no preview
     (sustentus `build-ready-flip-empty-commit-builds-no-preview`, half done);
  7. `select-model.sh:104` — `-not -path '*/_done/*'` misses archived runs (jamienisbet
     `template-change-select-model-run-slug`);
  8. `route-request.sh:192` — the router/skill prompt shapes (berceo
     `template-change-router-skill-prompts`).
- **#91's fan-out is nobody's stub.** `sync-lens-and-scout-agents` closed on template + dry-run
  acceptance; 27 repos still lack the two agents. `retire-project-command-and-rollout` (stub 5)
  is the natural owner — say so, or cut a rollout stub.
- **`today.md` has never been written since D10** (last change 3223c7d, 2026-08-28). The
  `estate-housekeeping` routine (09:30 daily) has run once (2026-09-25 19:58, succeeded) and
  stops at the gate by design, so this is a gate waiting on Jamie, not a fault — but the ≤10
  cap, the SessionStart "Today" group and the board's `today` flag have been dead weight for
  four weeks.
- jamienisbet `.icm/intake/tickets-board/` is an untracked local leftover (only an empty
  `_done/`) beside the archived `tickets-master-detail` epic — `rmdir`.

---

## 2. The template — improvements, with the research behind them

Numbered so the questions in § 5 and any stubs can point at them.

1. **Reconcile TICKETS.md with `intake/CONTEXT.md`** (§ 1.3): pick the template's field set as
   canonical (six repos already follow it), teach `tickets.ts` to read `scope:` as `epic:`,
   decide `## Prompt` once, delete the "deleted, not hoarded" sentence or the "nothing is
   deleted" one, and write the archive path rule as it is coded. Then `ticket-hygiene.sh` can
   lint the real shape estate-wide (today it lints neither `epic:` nor `scope:`).
2. **Fix `report.sh`'s curl** in the template stub (§ 0): one body, one channel, and a
   `--dry-run` that prints the exact bytes; a `report.sh selftest` step in `release.yaml`
   would have caught this in one run instead of twenty.
3. **Price table as a checked input**: refresh `model-prices.json`, add Opus 5.5 and any model
   `usage-snapshot.sh` sees, and have `self-check.sh` fail when a `usage.md` line names a model
   the table lacks.
4. **`setup.sh` warnings that can be settled**: `required_checks` empty is `ok` when
   `deploy.projects[].status_context` is declared (D43); `database.isolation: none` is `ok`
   when `database.provider` is set; a `deploy.provider: railway | none` that silences the
   Vercel-shaped `env.sh` audit and `deploy-status.sh` (serviflow: 128 false gaps, and
   `promote.sh` has no Railway path either — its `promote-main-to-production` stub is
   manual-only today).
5. **One canonical-asset list** read by both `icm-check.sh` and `estate-conformance.sh`
   (§ 1.4), so the daily cron cannot be green while the disk walk is red.
6. **Close the D33 loop mechanically**: `ticket-hygiene.sh` (or `icm-check.sh`) lists every
   `found-by: template-change` stub across the estate and reports the ones with no icm-board
   counterpart; `icm-sync.sh --apply` prints the repo's open template-change stubs so the sync
   commit retires them as the contract says. `/day` step 2 gains "template changes owed".
7. **Agents and the dual harness**: OpenCode reads agents only from `.opencode/agents/` and
   `~/.config/opencode/agents/`, never `.claude/agents/` (opencode.ai/docs/agents); the
   estate's three "canonical" agents have never been visible to it. Either seed
   `.opencode/agents/` twins from the template or declare them Claude-only in
   `_system/template/README.md`. Pin OpenCode to the v1.18 line until v2 is GA: v2 renames
   `permission` → `permissions[]` (still last-match-wins) and `bash` → `shell`, which is one
   template change to `opencode.jsonc` when the time comes.
8. **`.claude/commands/` is deprecated in favour of skills** (code.claude.com/docs/en/skills):
   icm-board's four commands (`/client`, `/project`, `/day`, `/icm-check`) should become
   `.claude/skills/<name>/SKILL.md` — the same move the template already made for `/pipeline`
   and `/setup`. The `triggers:` field the capability skills use is not a Claude Code field
   (unrecognised fields are ignored); it works only because `list-skills.sh` prints it into the
   session — say so in `skills/README.md` and mirror the phrases into `description`, which the
   harness does read.
9. **Layer 0 size**: Claude Code reads `AGENTS.md` natively since v2.1.277 (2026-09-18) when no
   `CLAUDE.md` exists; the one-line importer is still right for this estate (OpenCode, older
   clients). Long per-area guidance belongs in `.claude/rules/*.md` with `paths:` (loaded on
   file match) rather than in a 140-line (remi-ai), 109-line (serviflow) or 371-line
   (courseday) `AGENTS.md`; the conformance contract's 30–90 guidance should say that.
10. **Do not adopt copier/cruft-style 3-way merge for `icm-sync.sh`.** The research confirms
    that is what a MANIFEST + byte-diff lacks, but the estate's T/P split deliberately avoids
    merges: `T` files are identical by design, `P` files are never synced. What is missing is
    smaller — `icm-sync.sh` should refuse (not just warn) when a `T` file changed in the repo
    since the stamp, printing the diff as a template change request (D33) instead of
    overwriting it.
11. **Neon preview branches never expire under the Vercel integration** (neon.com
    vercel-branch-cleanup): agorasim's `neon-uat-branch-limit-blocks-previews` is that fact
    on the Free plan's 10-branch cap. `neon-cleanup.yaml` deletes on PR close; add
    `expires_at` (max 30 days) at creation for the branches the integration makes, or move
    the non-prod project off Free.
12. **Wording that has aged**: D37 and `db-name.mjs` say "shared tier" — M2/M5 support ended
    2026-01-22; the 38-byte cap holds on Free and Flex. GitHub Actions Linux minutes are $0.006
    since 2026-01-01 (check any constant). Vercel made "Marketplace resource → custom
    environment only" first-class on 2026-09-17 (`vercel integration resource connect <db>
    --environment uat`) — D41's hand-wired pattern now has an official command.
13. **Container epics**: `services-backlog-cleanup` (44 stubs, `story: none`, ~25 modules,
    "every item independently shippable") and `web-app-hardening` (25) are contract-legal
    batches but archive only when the last stub merges, so one dropped stub keeps them open
    forever and `/pipeline new` walks an advisory order as if it were real. Let a `batch` epic
    archive per stub, or cut them by module.
14. **Cross-epic dependencies are prose only** (guided-demo ↔ guided-demo-platform, D-57):
    `depends-on:` is in-epic by contract, so `/pipeline new guided-demo` offers seq 4 while
    6 of 11 platform stubs are unstarted. Allow `depends-on: <epic>/<slug>` and let
    `validate-intake.sh` resolve it.
15. **`private/` needs a rule that survives visibility**: while icm-board is public, ignore
    `workspaces/deals/**/private/`; once private, keep D24 as written.
16. **The triage cap is real**: the template's own 60-stub cap is exceeded by sustentus (87 →
    72 after the retire/duplicate moves below); the cap's stop-message line has not been
    firing, or has been ignored — `triage-report.sh` should say which.

---

## 3. The estate, repo by repo

| Repo | Visibility | Pipeline | Open (triage / epic) | PRs | Notable |
|---|---|---|---|---|---|
| agorasim | public | ✓ | 23 / 4 | 0 | client PDFs tracked; runbook pre-D39; Neon 10-branch cap |
| berceo | public | ✓ | 24 / 2 | 0 | client answers PDF tracked; scope run stale; bare commit 5877c2e "update" (+11k lockfile) |
| casey-hebbel | private | ✓ | 4 / 7 | 0 | react-patch P1; README teaches CASEY-NNN; no workflows |
| jamienisbet | public | ✓ | 11 / 0 | 0 | no `release.yaml`/`quality.yaml`; empty `tickets-board/` dir |
| lourenco-botelho | private | ✓ | 0 / 1 | 0 | no workflows; bare commits on main 2026-09-25; epic 7/8 done |
| remi-ai | public | ✓ | 25 / 14 | 1 (#115 superseded) | shareholder register + 62 docs tracked; local clone 1 behind; ~50 stale `claude/*` branches; README carries D-1…D-24 |
| serviflow | private | on PR #91 | 10 / 11 | 13 | no CI; `origin/production` 20 behind; #90 exposure; tracked `node_modules` symlink; README/rules keep retired uat model |
| sustentus | private | ✓ | 87 / 78 | 4 (2 merged this morning) | Slack dead; stamp collision; 87 > cap 60; local clone behind |
| vinecliff | public | ✓ | 4 / 0 | 0 | only `db-migrate.yml`; previews on prod DB; old `uat_branch` project.json shape |
| dungeons-dragons | public | — | 0 / 0 | 1 (#96, 18 d) | off-ticket by hygiene (plumbing only); has `project.md` |
| barzinho, escondidinho | private / public | — | 0 | 0 | off-ticket false positives; barzinho P&L PDFs still in history (commit 8b0c605) |
| cafe-jardim, kau-american-bbq | public | — | 1 / 0 · 1 / 2 | 0 | cafe: dormant *and* a stub; kau: P0 password |
| courseday, pierpont + 14 others | public (messy-play, the-library private) | — | 0 | 0 | dormant; courseday AGENTS.md 371 lines |

Also: casey-hebbel, lourenco-botelho and serviflow carry no GitHub workflow at all; jamienisbet
carries `ci.yml` + `db-migrations.yml` but neither the D43 `quality.yaml` nor `release.yaml`;
serviflow's and vinecliff's `project.json` are still in the pre-D39 shape (`uat.branch`,
`neon.uat_branch`, no `nonprod_project_id`) — `/setup` has not been re-run there since D39/D41.
Open questions in `project.md` and `setup.sh` reports agree on that.

---

## 4. Ticket verification — what to retire, merge, re-cut, or ask

Every open stub was read and checked against `main` (agorasim, berceo, remi-ai, serviflow,
jamienisbet, casey-hebbel, lourenco-botelho, vinecliff, cafe-jardim, kau-american-bbq,
sustentus) by a read-only agent; icm-board's own 12 (all cut 2026-09-25) were read by the
session and are current. **No stub was moved.** Full per-stub tables with file:line evidence
are in the agents' hand-backs (session transcript); this section is the action list.

### 4.1 Retire — the code says it is done (13)

| Repo · stub | Evidence |
|---|---|
| agorasim · `backup-registry-rate-limit-windows` | `web/src/lib/backup.ts:95` registers the table (6054226, #157); the privacy sub-question was never decided — re-cut only if wanted |
| agorasim · `deploy-after-migrate` | superseded by D39/D43: `release.yaml:282` promote needs migrate; `ci.yml` no longer runs on push to main (#128, #133) |
| agorasim · `stripe-webhook-secret-development` | `web/.env.example:143` `[production,preview]` (ccfc7d4, #142) |
| berceo · `knowledge-map-site-as-built` | fixed 99f1fcf (#37, after the stub); no `holding` left |
| vinecliff · `settings-deny-blocks-env-example` | 7654127: deny by name, `.env.example` readable |
| remi-ai · `context-md-format-drift` | 4204a7b (#131) formatted `.icm/CONTEXT.md` |
| jamienisbet · `reader-share-stub-parsing` | `ticket-detail.tsx` deleted by 01f7e35 (#179); parsing lives once in `ticket-reader.tsx` |
| sustentus · `close-out-skips-the-epic-when-the-run-is-already-archived` | template sync #1139 (c057cdad4): `close-out.sh:54,161` |
| sustentus · `embed-form-turnstile-roundtrip-unbounded-per-address` | shipped as #1058 (WAF rule per address); the fail-closed decision was not taken — optional one-liner |
| sustentus · `env-example-missing-the-e2e-tier-keys` | #1162 (d39e83355): `apps/web/.env.example:2-3,72,235` |
| sustentus · `preview-environment-missing-clerk-keys` | `preview` env holds both keys; smoke retired by D43 (#1160) |
| sustentus · `template-change-mongodb-database-isolation` | superseded by D35–D37; `db-branch.sh:2,31` |
| sustentus · `template-change-session-start-rsync` | icm-board #60 added step 0; synced e7a99bb |

### 4.2 Duplicates — fold with `- superseded-by:` (7)

| Keep | Retire |
|---|---|
| remi-ai `previews-migrate-the-shared-database` | `env-preview-migrations-row-is-stale` (its AC 4) |
| sustentus `gitignore-drops-every-run-error-log` (earliest) | `gitignore-drops-run-error-logs`, `run-error-logs-gitignored` |
| sustentus `preview-db-copy-cap-check-races` | `preview-db-copy-leaves-partial-database` |
| sustentus `build-ready-flip-empty-commit-builds-no-preview` | `ready-flip-empty-push-fallout` |
| sustentus `template-change-ci-status-green-before-previews-post` | `template-change-ci-status-premature-full-gate-green` |
| sustentus `_done/converge-bridge-shapes` | `two-bridge-vocabularies-in-one-batch` (its two siblings were moved, it was not) |

Overlaps the agents flagged but did not call duplicates (one should name the other):
sustentus triage ↔ epic pairs `lead-form-dead-form-disabled-reason` ↔
`dead-catalogue-form-unpublishes`, `bare-role-view-as-reads-full-scope-lists` ↔
`viewer-resolution-one-rule`, `no-dated-delivery-stage-transitions` ↔ `engagement-as-at-view`,
`aggregations-bypass-the-soft-delete-plugin` ↔ `soft-delete-keeps-the-callers-or`; agorasim
`cron-job-and-crypto-helpers-dedupe` ↔ `booking-logistics-facts-shared` (both claim the
`shiftDays` move); remi-ai's preview-database cluster (three stubs, one root cause: settle D32
for remi-ai).

### 4.3 Likely shipped — confirm after a `pull-all` (3)

sustentus `lead-source-product-trial` (#1195 merged 06:20Z today), `delivery-and-sign-off-polish`
(#1193, 06:19Z), `milestone-billing-docs-match-the-model` (#1012, `isPaid` gone from docs).

### 4.4 In flight, with a note (8)

serviflow #77/#75/#74 (spec-only drafts, 2026-09-15) and #20 (`ai-acceptance-tracking`, **81
days** stale, nothing on main, its dependant shipped without it → rebase or re-cut);
sustentus #1198 `walk-seat-sessions`, #1199 `invoice-tax-status-handoff`, #1200
`quote-margin-breakdown` (**its declared `depends-on` `tenant-markup-console-setting` has no run
and #1200 touches no markup file** — drop the dependency or hold the PR), #1201
`brd-review-states`.

### 4.5 Re-cut — the stub is right but its plan is wrong

- agorasim `superseded-quote-open-payments`: "unreachable today" is false (`quote-checkout.ts`
  mints sessions, `:466` only alerts); its fold-in target is archived; needs a new Proposed
  change and a priority.
- agorasim `email-keys-development-target`: 1 of 4 done (#152); names a retired sibling.
- vinecliff `ci-on-pull-requests`: the proposal predates D43 — the answer is the advisory
  `quality.yaml`, no `push: main`, no required check.
- remi-ai `patient-home-today-release-incomplete`: run archived by #116; only the changelog page
  remains.
- serviflow `sms-connector-missing`: investigation answered — the folder was removed
  deliberately (249a060, 2026-02-27); drop the `require` at `entry.js:17` and the
  `environments.md:18` line.
- sustentus `slack-reporting-unproven` → `bug` (§ 0); `csat-submit-holder-locked-out-of-their-survey`
  is now actionable (its named blocker is gone); `one-definition-popover-for-every-persona-card`
  is the only home for that work (its "already owned" claim is stale);
  `brd-revision-does-not-notify-bidders` re-read after #1201.
- Stale citations (cosmetic, fix when picked up): agorasim ×4 line refs; sustentus
  `view-as-never-writes-preferences` (file deleted d181d2592; defect now at
  `lib/actions/list-filters.ts:58`), `levers-match-their-permissions`,
  `csm-blocker-inbox-hardening`, `vendor-order-book-payload-ceiling`; casey-hebbel
  `landing-page/landing-page`.

### 4.6 Shape violations worth fixing at the source, not per stub

- No `## Prompt` (§ 1.3): ~150 stubs across seven repos — a template decision.
- Legacy-shaped stubs (pre-2026-08-28 copy): cafe-jardim `lint-red-on-main`, kau
  `rotate-seeded-admin-password` and both `admin-first-login-password` stubs (`- lane: feature`,
  no `- epic:`), casey-hebbel `detach-unused-neon`; sustentus `visual-verdict-parked`,
  `active-project-flag-never-cleared`, `csm-snapshot-retention`,
  `demo-vendor-revenue-at-risk-zero`, `docs-describe-retired-preview-smoke`,
  `overdue-customer-action-labelled-upcoming` (`## What`, no `## Problem`).
- Missing `## Proposed change`: berceo `template-change-router-skill-prompts`, agorasim
  `template-change-env-audit-empty-targets`, six sustentus first-half stubs.
- Parked without `- blocked:`: berceo `famille-changement-email`.
- `_done` stubs with `- superseded-by:` but no `> Dropped:`: six berceo process-raw stubs.
- serviflow: the agentic-work-inbox epic is split — 27 shipped stubs already in
  `intake/_done/agentic-work-inbox/_done/` while three live stubs remain in the live folder;
  legacy `EPIC-12`/`SFP-12xx` IDs in `- initiative:`/`- source:` lines.
- Retired concepts survive only in no-pipeline repos: cafe-jardim and kau `CONTEXT.md`
  `- profile: intake`, READMEs teaching `CAFE-NNN`/`KAU-NNN`/`CASEY-NNN`; agorasim
  `README.md:20-25` "Profile: pipeline" and `CONTEXT.md:3` — all inside the D45 drift set.
- Secrets-looking strings in intake: only kau (§ 0). Estate-wide credential grep over tracked
  files: clean apart from a serviflow `sk_test_placeholder`.

### 4.7 Run and PR hygiene

- remi-ai: PR #115 superseded by #125 → close and delete the branch; stale branches for #113,
  #114, #103 and ~50 older `claude/*`; local clone one commit behind.
- serviflow: close #84 (superseded by #91), #22 (docs, 80 days), #21 (spec-only, the gate lives
  in #89); #83 is a real fix not on main (`pool-ranking-service.js:53`) — stub or merge; #89 code
  + tests without a stub; #17 (29 files, 81 days) — still wanted?
- berceo: `recherche-et-fiches-publiques` is Define-done on `origin/claude/intelligent-pascal-ivo3n0`
  with no PR; the Scope run `runs/plateforme-v1` has stale `status.md`/`handoff.md`.
- sustentus: `runs/guided-demo/run.md:8` says `stubs: 10` (now 7 + 11); `status.md` "blocked on
  the review PR" while four Build PRs are open; `agentic-dashboard/answer-actions-platform-links`
  was built on `origin/claude/gallant-ride-x6ytd1` but PR #1136 closed unmerged (CI died in 2 s).
- agorasim: `go-live/breakdown.md` and `domain-transfer-tonight` credit PR #100 (closed unmerged
  2026-09-18) with work that never landed; `go-live/breakdown` "Out of scope" lists shipped work;
  `.icm/docs/launch-runbook.md:30-31,39` describes pre-D39 gating.
- lourenco-botelho: `about-portrait-restore` stub slug ≠ its run `fix-about-portrait`.

---

## 5. Questions for Jamie

Answers change what the next session does; none blocks the retire/duplicate moves above.

1. **Visibility.** Was icm-board ever meant to be public? If not: flip it now, and say whether
   the exposed `private/` pricing and terms skeletons need any client conversation. For
   remi-ai, agorasim and berceo: private repos (Actions cost) or purge the client documents
   from history?
2. **The stub shape.** Adopt the template's fields (`scope:`, `complexity:`) as the estate
   contract and teach the dashboard to read them — or rename in the template back to `epic:`?
3. **`## Prompt`.** Required everywhere (then the template's park step must write one) or
   optional in pipeline repos (then TICKETS.md and `ticket-craft` change)?
4. **Dropped work.** "Deleted, not hoarded" (template) or "nothing is deleted" (TICKETS.md)?
5. **Scope runs.** Does a front run (berceo `runs/plateforme-v1`) close out when its batch
   merges, or live until the epic archives? The template README says both.
6. **cafe-jardim.** Dormant with a red `main` and one stub: fix the 13 Biome errors, disable
   `ci.yml`, or drop the stub and stay dormant?
7. **agorasim.** Did the registrar transfer and titular change run, or only the NS switch?
   Is `uat-agorasim` still on Neon's Free plan (pay, shorter TTL, or fewer concurrent runs)?
8. **serviflow.** #17 still wanted? #20: rebase or re-cut? `intake-sentiment-language`: is
   the scope only language + `pool_ranking` boost + the VIP event?
9. **sustentus.** `demo-storyline-realism` / `demo-reset-time-measured` — kept, or superseded
   by the orrery storyline replacement? `quote-margin-breakdown`: drop its dependency or hold
   #1200? Should I cut the eight owed template-change stubs here now?
10. **remi-ai.** Preview database policy: D32 (a Neon branch per preview) or the opt-out —
    this settles three stubs.
11. **Off-ticket.** Mark barzinho and escondidinho dormant, or fix the hygiene filter?
12. **AUDIT.md #5 and #6** (`gh` CLI banned vs granted; the ≤50-line Layer 0 rule): decide or
    delete the rows. #8 and #9 can be closed.
13. **Roster.** Owner listing (as coded, 33 repos incl. seven not on disk) or Neon — close the
    open question and align `estate-conformance.sh`.
14. **Next step.** Shall I apply § 4.1–4.2 as `Wrap:` commits per repo (sustentus via a PR),
    cut the § 0/§ 1.5 stubs here, and open the D46 renumbering + doc fixes as one PR — or do
    you want to rule on each first?

---

## 6. Research notes (2026-09-26, sources)

- agents.md spec (Linux Foundation AAF): plain Markdown, closest file wins — https://agents.md/
- Claude Code reads AGENTS.md natively since v2.1.277; `.claude/rules/` with `paths:`; `@import`
  4 hops; <200-line warning — https://code.claude.com/docs/en/memory · /changelog
- Skills front matter (no `triggers`); `.claude/commands/` deprecated — https://code.claude.com/docs/en/skills ·
  https://agentskills.io/specification; hooks (33 events) — https://code.claude.com/docs/en/hooks;
  subagents — https://code.claude.com/docs/en/sub-agents; marketplaces — https://code.claude.com/docs/en/plugin-marketplaces
- OpenCode v1.18.32 config + last-match-wins permissions; agents from `.opencode/agents/` only;
  v2 renames — https://opencode.ai/docs/config/ · /permissions/ · /agents/ · https://opencode.ai/v2/docs/migrate-v1/
- copier `update` 3-way merge; cruft `check` — https://copier.readthedocs.io/en/stable/updating/ · https://cruft.github.io/cruft/
- GitHub Actions: per-job rounding, Free 2,000 min, Linux $0.006/min since 2026-01-01 —
  https://docs.github.com/en/billing/concepts/product-billing/github-actions ·
  https://github.com/resources/insights/2026-pricing-changes-for-github-actions
- Vercel custom environments (Pro: 1 included), `vercel promote`, protection bypass, Marketplace
  → custom env (2026-09-17) — https://vercel.com/docs/deployments/environments · /docs/cli/promote ·
  https://vercel.com/changelog/custom-environments-support-for-marketplace-integrations
- Neon: Free 10 branches/project; `expires_at` ≤ 30 days; Vercel-managed branches get no TTL —
  https://neon.com/docs/introduction/plans · /docs/guides/branch-expiration · /docs/guides/vercel-branch-cleanup
- MongoDB Atlas: 38-byte name cap on Free and Flex; M2/M5 ended 2026-01-22 —
  https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/ · /docs/atlas/flex-migration/
- Anthropic pricing (per MTok in/out): Fable 5.1 $10/$50 · Opus 5.5 $4/$20 · Opus 5/4.x $5/$25 ·
  Sonnet 5 $2/$10 (permanent) · Haiku 4.5 $1/$5 — https://platform.claude.com/docs/en/about-claude/pricing

---

## 7. Outcome — Jamie's rulings and what landed (2026-09-26, same day)

Rulings: icm-board private at month end (public was a deliberate Actions-minutes move); the
template's stub fields are the contract; `## Prompt` optional, the board sends verb + slug; dropped
work deleted or archived; a front run archives with its scope; cafe-jardim and kau-american-bbq
dormant altogether; agorasim.pt still on the old site by choice; serviflow hands-off; remi-ai one
database, preview + production, no UAT; barzinho and escondidinho dormant; every owned remote on
disk; rule per item before acting. All 33 items of the ledger were ruled; 32 yes, one deferred
(item 6, `setup.sh` warnings — the `unify-setup-project` scope owns that surface).

Landed: icm-board [#92](https://github.com/k0d0minio/icm-board/pull/92) (this document's branch);
`Wrap:` commits on `main` in agorasim (683f4e8), berceo (d924a5f), vinecliff (469f617), remi-ai
(4729e98, a825a74), jamienisbet (dde140f), cafe-jardim (f577894), kau-american-bbq (d1cfb1e),
barzinho (dormant, history rewritten without the P&L PDFs and force-pushed), escondidinho (dormant),
and the seven freshly cloned repos (baseline seeded, dormant); PRs vinecliff #24 (project.json
shape), casey-hebbel #19 (react-patch), sustentus #1210 (report.sh fix, selftest, triage sweep).
remi-ai PR #115 closed and 41 stale branches deleted (six with unmerged commits kept for Jamie).
serviflow moved to `~/Consulting/`, the three archived clones to `~/Archive/`. Not done: the
`.agents/` folder Jamie believed both harnesses read — neither documents it, so the twins live in
`.opencode/agents/` (ruling 13, adjusted).
