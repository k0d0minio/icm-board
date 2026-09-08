# icm-board — project register

> Seeded 2026-08-26 at the split from `k0d0minio/jamienisbet`, from intent Jamie stated
> directly in that session. **Not yet a `/project` run** — the empty sections below are
> real gaps, not omissions. Run `/project icm-board` to interrogate and fill them.
> Maintained by `/project`. Amend by re-running it, not by hand-editing during a session.

## What this is

The second brain of Jamie Nisbet's business, written as an ICM system: three workspaces
(`sell`, `start`, `deliver`) that carry the whole client lifecycle as stage contracts
with human gates; the knowledge layer they cite (services, pricing, voice, terms,
stack); the contracts every repo is measured against; the scripts that measure them; and
the canonical Claude assets seeded across the estate. It holds no application code and
ships no product. Its one user is Jamie; its jobs are that every deal moves through a
defined, improvable process, and every repo in the estate stays aligned.

## Intent

- **For whom** — Jamie, and every Claude session opened at `~/Apps` or in any estate repo.
- **The job** — two, and the first wins when they conflict: (1) the business's processes
  and knowledge live here, versioned and improvable, so no deal reinvents them;
  (2) the estate stays conformant, with drift visible before it compounds.
- **Done looks like** — a lead can be taken from first contact to a running project by
  walking folders anyone could read; a repo can be adopted, analysed and ticketed
  without anyone remembering how; and both say so when they drift.
- **Explicitly not** — a pipeline driver. The folders are the orchestration; stages run
  when Jamie enters them, and no outbound action leaves a session. The house rule
  "never build an orchestrator" survives the return of the business workspaces, and
  outranks everything here.

## Business logic

- **The repo wins.** Where a repo's own contracts conflict with the estate baseline, the
  repo is authoritative. Sustentus is the standing example and is exempt outright.
- **Tickets live next to the logic they describe.** A ticket about `_system/scripts/` lives
  here; a ticket about the dashboard lives in `jamienisbet`. This is why the `JN-*` series
  was split at the 2026-08-26 separation.
- **Gates are human checkboxes.** Read, never tick. Anything that cannot be verified from
  the repo (a Vercel setting, a token, a secret) is a human ticket that says so in its
  Prompt.
- **Conformance reports, it does not repair.** `icm-check.sh --fix` seeds only what is
  missing and never overwrites; the scheduled workflow reports and never writes.

## Features
| Feature | State | Tickets |
|---|---|---|
| Four commands — `/client`, `/project`, `/day`, `/icm-check` (thin routers) | shipped | — |
| Sell workspace — intake → discovery → quote → proposal | shipped, unproven | — |
| Start workspace — onboarding → repo → kickoff | shipped, unproven | — |
| Deliver workspace — the three rituals as stage contracts | shipped | — |
| Knowledge layer — services, pricing, voice, terms, stack | shipped | — |
| Canonical Claude asset library + drift report | shipped | — |
| Four estate scripts — icm-check, tickets-board, ticket-hygiene, pull-all | shipped | — |
| Self-check CI — shellcheck, contract links, ticket lint | shipped | — |
| Remote conformance CI over the `k0d0minio` org | shipped | — |
| Estate pipeline — intake epics + tiered profiles, extracted from sustentus | shipped | — (rollout banked: _done/estate-migration/) |
| Estate heartbeat — scheduled digest | out | — dropped 2026-08-28 (fresh-footing sweep); AUDIT #8 keeps the want |
| `/day` run log — folded into the heartbeat | out | — dropped with the heartbeat |

## Constraints

- **The estate is half-invisible to CI.** Client repos are gitignored and live only on this
  machine, so anything running in Actions must reach them over the GitHub API and is
  limited to what a read-only token can see.
- **Legal / data** — client repo names and business state are not public; this repo is
  private and `_system/AUDIT.md` is one reason why.
- **Commercial** — solo operator. Every rule here has to earn its maintenance cost.

## Decisions
| ID | Decision | Date | Supersedes |
|---|---|---|---|
| D1 | The control layer gets its own repo, `icm-board`; `jamienisbet` becomes a normal repo under `projects/` and keeps its remote, CI and tickets | 2026-08-26 | the 2026-08-12 consolidation |
| D2 | Ticketing and workflows live next to the code whose logic they describe, not centrally | 2026-08-26 | — |
| D3 | The business processes return as **full ICM workspaces** (Van Clief grammar: numbered stages, CONTEXT.md contracts, review gates) — contracts + human gates, never a driver | 2026-08-26 | the 2026-08-12 factory retirement, narrowly |
| D4 | The whole repo is one five-layer tree: `sell`/`start`/`deliver` under `workspaces/`; the three rituals become deliver's stage contracts; slash commands survive as thin routers. **The stage contracts are the process** | 2026-08-26 | "the commands are the process" (2026-08-14 consolidation), in wording only |
| D5 | Deal artifacts are **tracked in git** at `workspaces/deals/<slug>/` (private repo; cloud sessions must run the pipelines; past deals are precedent). Durable docs copy into the client repo at kickoff; never a secret in a deal folder | 2026-08-26 | — |
| D6 | This repo holds the business **knowledge layer** (`_system/knowledge/`): services, pricing (fixed-price · retainer · in-kind; no day rate), voice, terms, stack — filled via `_system/setup/questionnaire.md`, honest gaps until then | 2026-08-26 | — |
| D7 | Estate Claude assets: **canonical library** in `_system/template/claude/` (session-start + wrap-reminder hooks, ticket-craft + pr-conventions skills); `icm-check.sh` seeds what's missing and reports drift, never overwrites — the repo's copy wins | 2026-08-26 | AUDIT open decisions #1 (skills layering) and #3 (hook strategy) |
| D8 | Client acquisition covers **inbound + outbound** (qualification, target profile, outreach playbook) — marketing/content stays with `jamienisbet` | 2026-08-26 | — |
| D9 | Proposals are **markdown → PDF** in the deal folder; markdown canonical, PDF a build artifact | 2026-08-26 | — |
| D10 | Tickets re-founded on the sustentus intake model: **epics + stubs + triage**, path identity (`epic/slug`), positional status. The `PREFIX-NNN` series and its dual registry are retired (legacy IDs live on in the archives); the today flag moves to `.icm/today.md` here, ≤10 entries estate-wide | 2026-08-28 | the 2026-08-12 TICKETS.md shape |
| D11 | D3 narrowed: a *project repo's own* deterministic one-job scripts, and CI acting only after a human-authorised merge, are **factory, not orchestrator**. The line that never moves: nothing advances work across a human gate, and icm-board itself drives nothing | 2026-08-28 | D3, narrowly |
| D12 | Gen-3 **is** a template product: the estate pipeline is extracted from sustentus into `_system/template/` as tiered profiles (`intake` default · `pipeline` · `pipeline-full` deliberately unextracted). Sustentus stays exempt as the source; remi-ai's zero-run `pipeline/` tree is superseded pending its migration decision. Answers AUDIT open question 2 | 2026-08-28 | — |
| D13 | The dashboard board stays **read-only** and reads both ticket shapes over the GitHub API, sustentus included — no sync, no second store | 2026-08-28 | — |
| D14 | **Clean slate**: every legacy `PREFIX-NNN` ticket — open and archived, estate-wide — is purged rather than re-cut ("they were getting very noisy"); fresh backlogs come from gated `/project` runs per repo, on demand. The "nothing is deleted" rule governs the new model's ongoing operation from this founding reset onward. Facts worth keeping (security lines, the hook-wiring history) were carried into AUDIT.md and the seeding stub before the purge | 2026-08-28 | the per-repo re-cut rollout in D10's plan |
| D15 | **Conformance exit codes**: gaps exit 0 (the report's content), unreachable stays exit 2 (the report lying) — in both `icm-check.sh` and `estate-conformance.sh`, commented at the exit lines. A always-red schedule teaches you to stop reading it | 2026-08-28 | the inherited `(( gaps == 0 ))` convention |
| D16 | The rails file is **`opencode.jsonc`**, not `opencode.json`. It keeps its `//` comment — the only record that bash permissions are last-match-wins, so the `claude/*` push allow must stay below the ask — and the extension declares that dialect to every other tool, so no repo needs a lint ignore **to parse it** and none is a latent break. (`cafe-jardim` still excludes it from Biome for *formatting*: that repo formats with tabs, and the canonical assets are two-space — `.claude/settings.json` is already flagged there for the same reason. A canonical asset is drift-checked byte-for-byte, so reformatting it in-repo trades a CI error for silent permanent drift.) Rejected: a baseline `!**/opencode.json` ignore (reaches into each repo's lint config), and strict JSON with the doctrine moved to `AGENTS.md` (parts the warning from the two lines it is about) | 2026-09-04 | `opencode.json` as the canonical root asset (D7's set, epic opencode-sidecar) |
| D18 | **D7 narrowed one level down**: `--fix` may merge a missing hook registration into an existing `.claude/settings.json` — appending the template's own entry for a hook the repo's file does not already name anywhere, and only that. It never rewrites an entry the repo already has, never changes a value the repo already holds, and reads both the event and the entry from the template, so registering a future hook is a template edit and nothing more. Needs `jq`; without it the merge is skipped and the inert-hook warning stands, reason attached. The line D7 still draws: this is the only file `--fix` edits that it did not create, and canonical assets stay drift-reported, never repaired. Known cost, accepted: `jq` re-emits the document, so a repo that hand-packs an array onto one line gets it reflowed — `courseday` only, whose CI format-checks `.claude/`. Rejected: a one-time hand pass across the 14 (closes the backlog, leaves the next hook to repeat it) | 2026-09-08 | D7's “existing files are never touched”, for hook entries only |
| D16 | The rails file is **`opencode.jsonc`**, not `opencode.json`. It keeps its `//` comment — the only record that bash permissions are last-match-wins, so the `claude/*` push allow must stay below the ask — and the extension declares that dialect to every other tool, so no repo needs a lint ignore **to parse it** and none is a latent break. (`cafe-jardim` still excludes it from Biome for *formatting*: that repo formats with tabs, and the canonical assets are two-space. A canonical asset is drift-checked byte-for-byte, so reformatting it in-repo trades a CI error for silent permanent drift. `.claude/settings.json` was flagged there too but is **not** drift-checked, so it was simply reformatted — see D17.) Rejected: a baseline `!**/opencode.json` ignore (reaches into each repo's lint config), and strict JSON with the doctrine moved to `AGENTS.md` (parts the warning from the two lines it is about) | 2026-09-04 | `opencode.json` as the canonical root asset (D7's set, epic opencode-sidecar) |
| D17 | A canonical asset that loses to a repo's formatter **stays a per-repo exclusion** — no estate machinery. Rejected: having `icm-check` parse each repo's lint config to report exclusions (a config-parser for a one-file problem), and seeding a template-derived ignore class into every repo (reaches into each repo's lint config, the same ground D16 rejected). The bar set in triage was a third repo or `.claude/settings.json` flagged beyond `cafe-jardim`; neither is met. The real surface is **two files** — `opencode.jsonc` and `skills/*/SKILL.md`; only the three `hooks/*.sh` are safe, being shell. (Surveyed as *one* file on the reading that the markdown passed Prettier: true of `remi-ai`'s `**/*.{ts,tsx,md}` glob, false of `prettier --check .`. Adopting `courseday` hours later put five files in scope and failed all five, `pr-conventions/SKILL.md` among them — k0d0minio/courseday#277. **Both revisit triggers this decision set have therefore fired**: the markdown assets collide, and `courseday` is the third colliding repo. The *ruling* held on contact — the peer session applied it as written and courseday went green in one commit, reaching independently for the same class-level `.icm/` + `.claude/` + rails exclusion `dungeons-dragons` wrote. Whether three repos converging on that by hand promotes it from per-repo call to seeded convention is open: `triage/canonical-assets-markdown-collision.md`.) `.claude/settings.json` is seeded but never drift-compared, so there was never a trade there — `cafe-jardim` reformatted it to tabs. The same holds for `.icm/CONTEXT.md` and `.icm/intake/README.md`: seeded when missing, never compared (`icm-check.sh` runs exactly two `cmp -s`, over `.claude/`'s `CANONICAL` and `CANONICAL_ROOT`), so a formatter may have them freely. `collabimmo` carries a tab `biome.json` its CI does not run: latent, not a hit. The rule is written where someone seeding assets reads it (`_system/template/README.md`) | 2026-09-08 | — |

## Open questions

- Does the estate roster come from the `k0d0minio` org listing, or from Neon
  (`biz.clients.github_repo`) the way the dashboard's board does? The workflow currently
  assumes the org. *Answerable by: Jamie. Blocks: nothing yet — it only affects which
  repos get checked.*
- Should `icm-board` hold the estate `.icm/docs/` research (contabilista, founder brief)
  that stayed in `jamienisbet`? *Answerable by: Jamie. Blocks: nothing.*

## Run log
| Date | Commit | What changed |
|---|---|---|
| 2026-08-26 | — | Seeded at the split. Not a `/project` run; intent taken verbatim from the session that created this repo. |
| 2026-08-26 | — | The second-brain build (cloud session, interrogation-driven — decisions D3–D9 are Jamie's answers verbatim). Three workspaces created, rituals rehoused, knowledge layer scaffolded, canonical asset library seeded into the template. ICM-006 amended; ICM-009/ICM-010 cut. |
| 2026-08-26 | — | ICM-009 done in the same session: questionnaire run conversationally, all seven sections. Knowledge layer + target-profile + outreach filled with Jamie's real answers (band €1.000–€2.500 sites, €500 floor, method-not-band for apps/AI, scoped retainers €200–€4.000/mo, 50/50 default, two revision rounds, both ownership patterns, stack confirmed as policy, profile weighted to AI). Deliberate remaining gaps: voice/outreach example pastes, app/AI standing inclusions, the AI-SME channel. |
| 2026-08-28 | — | Estate ticket audit (Jamie-directed, 27–28 Aug): every open ticket checked against its codebase; board 85 → 54 open. Here: ICM-002 folded into ICM-001 (row above updated on Jamie's instruction), ICM-004 trimmed to its two live items. New: AGORA-020 (tracked credential PDFs) and REMI-038 (patient Stripe subscriptions) cut on his answers. Not a `/project` run — a directed register correction. |
| 2026-08-28 | — | **The pipeline rework** (Jamie-directed; four-agent analysis + two interrogation rounds — decisions D10–D13 are his answers). TICKETS.md rewritten, PIPELINE.md cut, the template rebuilt with the `pipeline` profile, all five scripts reworked, `/day`/`/project`/`/icm-check` contracts redesigned, own intake migrated (9 flat tickets → 4 epics + 1 triage stub; rollout cut as the estate-migration epic). Design record: `.icm/docs/pipeline-rework-design.md`. Dashboard counterpart in jamienisbet's own PR. |
| 2026-08-28 | — | **The fresh-footing sweep** (Jamie-directed, same day): the board's last seven stubs addressed to zero — barzinho P&L PDFs untracked (scrub = AUDIT P1, his call) · D15 decided and shipped (conformance gaps exit 0) · the discovery bank distilled from berceo + messy-play (22 → 44 questions) · business-state epic and the heartbeat dropped on his rulings. All four epics banked to `intake/_done/`; the estate board is empty, sustentus its own project. |
| 2026-08-28 | — | **The D14 clean slate** (Jamie's call, same day): ~39 open + ~130 archived legacy tickets purged across the estate; this repo's recut archives removed from the rework branch and every archived-original reference swept; the estate-migration epic re-cut to the single seeding stub. `JN-036` left on jamienisbet `main` deliberately — PR #78 moves that file, so it is purged after that merge. |
