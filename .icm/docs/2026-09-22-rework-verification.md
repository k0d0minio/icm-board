# Rework Verification — the deal workspace, the agency layer, intake, positioning (master directive, 2026-09-22)

*Executed against `.icm/docs/2026-09-22-rework-master-directive.md` (Jamie, saved here in Phase F)
and `.icm/docs/Agency_DevOps_Brainstorm.md` (r3, on main). The design brief the directive names,
`2026-09-22-icm-board-rework-brief.md`, was **absent from both checkouts** (`~/Apps` and this
worktree); as the directive instructs, the session proceeded on the directive alone. Session
boundary honoured: `icm-board` (branch `claude/rework-deal-workspace-2026-09-22`,
[k0d0minio/icm-board#46](https://github.com/k0d0minio/icm-board/pull/46)) and `jamienisbet`
(branch `claude/rework-intake-and-deals-2026-09-22`,
[k0d0minio/jamienisbet#133](https://github.com/k0d0minio/jamienisbet/pull/133)). No other repo
under `projects/` was read for writing, synced or edited; `git -C projects/sustentus status` and
`git -C projects/remi-ai status` are clean and their heads unchanged. Nothing merged; nothing
applied; no local build, lint, typecheck, test or format ran in either repo. Decisions recorded:
D23 (Phase A), D24–D26 (Phase F) in `.icm/project.md`.*

## 1. Outcome in one paragraph

One home per fact. Relationship **state** stays in Neon; every deal **document** now lives in
icm-board at `workspaces/deals/<client>/<engagement>/` with dash-field `DEAL.md`s and no mirror of
any Neon column; the ten adopted folders were re-cut by `git mv` with a provenance line on every
moved file, and `remi/` and `sustentus/` were added. The sell workspace is five stages
(01_intake → 05_agreement) and start is two (06_onboarding, 07_kickoff), each a ≤80-line
five-part contract, with the free look, the diagnostic bands, the four shapes and the €500 floor
written into `positioning.md`, `pricing.md`, `services.md` and `terms.md`. The agency layer from
the DevOps brief (r3) is in the template: `report.sh` kinds→channels with a GitHub Release by
default, the `deploy` block and `lib/vercel.sh`, `env.sh`, `deploy-status.sh`, `rollback.sh`
(prepares only), `usage-snapshot.sh` + `run-economics.sh`, the `hotfix` and `handover` lanes,
`setup.sh` with eleven sections and the `/setup` skill, the `MANIFEST` as a T file. The template
also carries D26's disjoint cuts and early merge, the Support checks and the transcription kind.
The dashboard reads the deal folder live (read-only), gains `deal_slug` and `support_minor`,
lists the house forms from icm-board and snapshots answers back into the deal folder on request,
serves the public `/start` intake, and sends the pipeline verb where a repo carries the router.
Every proof the directive asked for is recorded below with its `RESULT:` line; the tools the
machine lacks (pandoc, whisper.cpp, a Vercel token) are recorded as `SKIP`, not worked around.

## 2. What changed where

| Phase | Commit | Where |
|---|---|---|
| A — agency layer | `783e9e7` | `_system/template/icm-pipeline/`: `project.json` stub (`deploy`, `reporting`, `migrations`, `support`), `scripts/lib/{project,vercel}.sh`, `lib/model-prices.json`, `report.sh` (P; `notify.sh` retired), `deploy-status.sh`, `rollback.sh`, `env.sh`, `usage-snapshot.sh`, `setup.sh`, `new-run.sh` (lane vocabulary, `--ready`, D26 overlap warning), `env-check.sh`, `ci-status.sh`, `project-labels.sh`, `close-out.sh`; `lanes/hotfix/`; stages 01–04 (usage lines, Build step 9 `env.sh audit --changed`, Release step 9 (a)(b)(c), stop class 3 scoped); `_shared/{github,ci,project-rules}.md`; `MANIFEST` (T itself); `claude-pipeline/skills/{pipeline,setup}`; `github-pipeline/workflows/{release,labels}.yaml`; `root/.opencode/plugins/icm-session-env.js`; the cloud hydrate hook (delegates to `env.sh pull`); `_system/scripts/{icm-sync,icm-check,vercel-env,run-economics}.sh`; D23 |
| B — knowledge and contracts | `1838faf` | `_system/knowledge/positioning.md` (new), `pricing.md` (rewritten), `services.md`, `terms.md`, `voice.md`, `stack.md`, `README.md`; `_system/setup/questionnaire.md` Q22–Q24; `_system/contracts/{WORKSPACES,CLIENTS,TICKETS,PIPELINE}.md`; canonical `ticket-craft/SKILL.md` and `intake/README.md` (template + this repo's copies) |
| C — the deal workspace | `b7d8123` | `workspaces/sell/` (CONTEXT + 01_intake · 02_look · 03_quote · 04_proposal · 05_agreement; references incl. `forms/{intake-diagnostic,onboarding,content-and-brand}.md`, `agreement-template.{en,fr,pt}.md`), `workspaces/start/` (06_onboarding, 07_kickoff), `workspaces/deals/` (README, ten folders re-cut, `remi/`, `sustentus/`), `.gitignore` (`out/`, raw media), `.claude/commands/client.md`, `_system/scripts/{validate-deal,render-deal}.sh`, root routing (`AGENTS.md`, `CONTEXT.md`, `README.md`, `_system/README.md`), deliver contracts (project § 1c → `/setup`, conformance, day) |
| D — template additions | `3d71e11` | `intake/CONTEXT.md` + Scope step 6 (`## Parallelizable` derived from `touches:`), Build merge-before-flip, `new-run.sh` `[WARN] overlaps`, `github.md` doctrine; `lanes/handover/`; `setup.sh` section 11 / Release stop class 3 / project-rules Support slot; `process-raw.sh` audio + video kinds (ffmpeg → whisper-cli); `MANIFEST`, `PIPELINE.md`, `template/README.md`, `icm-check.md` |
| E — jamienisbet | `e143574`…`a9a3b94` (E1–E7) | see [k0d0minio/jamienisbet#133](https://github.com/k0d0minio/jamienisbet/pull/133): schema + migration 0024, `lib/deals.ts`, stage chip, Deal folder block, forms from icm-board + `forms-parse.ts` in services, answers snapshot to the deal folder, `/start` + `app/actions/intake.ts`, the pick-up verb, portfolio copy, referral site at €500 |
| F — sweep, decisions, wrap | this commit | profile wording swept (`deliver/{project,conformance,day}`, `ticket-scout.md`, `pr-conventions/SKILL.md` canonical + copy, `estate-conformance.sh` header, this repo's `.icm/CONTEXT.md` — the `- profile: intake` line gone); `triage/profile-wording-sweep.md` → `_done/`; `.icm/project.md` D24–D26, Features rows, run-log row; this report; the directive saved |

## 3. The proofs — the run log

### Phase A (agency brief §8)

| Proof | Command | Result |
|---|---|---|
| Fresh repo seeded from an explicit template | scratch bare repo · `setup.sh --fix --template <path>` (from the template's copy, `--repo`) · then `setup.sh` from the repo's own `.icm/scripts` | first run seeds and reports; second run **`RESULT: OK (3 warnings)`** |
| Report is a pure read | `setup.sh --report` twice | byte-identical |
| Self-sufficiency (flag 1) | `env -i HOME=<empty> …` in the scratch repo | `report.sh --dry-run` → `RESULT: DRY-RUN` · `env.sh audit` → `OK` · `usage-snapshot.sh` → `SKIP` (no harness) · `deploy-status.sh` → `SKIP` · `setup.sh` → `OK` |
| No identity in T files | `grep -rn "~/Apps\|_system/" report.sh setup.sh vercel.sh` | hits are prose (comments/usage) only |
| sustentus dry-run, twice | `icm-sync.sh --dry-run projects/sustentus` (against the D20-branch export; the main checkout there predates D20 and reports `DRY-RUN 40/41`) | **`RESULT: DRY-RUN 25`** after A, **`DRY-RUN 29`** after D — exactly the new/changed T files; `notify.sh` reported retired; two consecutive runs identical; nothing applied |
| `report.sh` three cases | announce dry-run · alert with no channel · economics | `RESULT: DRY-RUN` · `SKIPPED` with the `env.sh add` hint · `RESULT: DRY-RUN`; exit 0 each |
| `env.sh` | `audit` on a sustentus-shaped `deploy` block (no token) · `add TEST_KEY --targets preview </dev/null` · `doc TEST_KEY --note x --ci` | `WARN` no token, `RESULT: OK` · prints the commands, `SKIP` (no value on stdin) · `DOC` line written |
| Usage — Claude | `usage-snapshot.sh` with `CLAUDE_CODE_SESSION_ID` | `- usage: … harness=claude session=b8dfde80-… source=transcript model=anthropic/claude-fable-5-1 … cost_usd=23.3272 turns=1` |
| Usage — OpenCode | with / without `OPENCODE_SESSION_ID` (real id from `opencode.db`) | `source=sqlite model=vercel/zai/glm-5.3-flash cost_usd=0.0027` · `source=skip` |
| Economics | `run-economics.sh --repo icm-board` (usage.md copied under `.icm/runs/` for the test, then removed) | one table, `RESULT:` line |
| env-check | scratch repo | `RESULT: PASS`, `[INFO] deploy not declared` |
| Validators untouched | `validate-intake.sh` on `triage/`, `vercel-env-system/` | `OK` |
| hotfix lane | `new-run.sh … --lane hotfix --dry-run` | body READY, label `type:hotfix`, `RESULT: DRY-RUN` |
| rollback | `rollback.sh --revert` in `icm-clone` (real origin) · `--vercel` | `RESULT: DRY-RUN revert branch claude/hotfix-revert-1264c71` · `SKIP` (no token) |

### Phase C

| Proof | Result |
|---|---|
| `validate-deal.sh --all` | `alix-hahusseau/berceo-platform` **OK** · `billy-carlson/vinecliff-site` **OK** · `casey-hebbel/opening-night` **OK** · `diogo-rita/agorasim-v1` **OK** · `magali/collabimmo-followon` **OK** · `alex-valexo`, `dragon`, `jerome`, `karen`, `remi`, `rui-matias`, `sustentus`: `RESULT: SKIP (no engagement)`. No DRIFT on any adopted artefact |
| `render-deal.sh alix-hahusseau/berceo-platform` | `RESULT: SKIP (pandoc not found)` — install hint printed; exit 0 |
| `render-deal.sh` on an engagement with no `04-` file | exit 2 with the missing-artefact line |
| The three forms under the dashboard's grammar | scratchpad node script over the parser (`node --experimental-strip-types`, not committed): `intake-diagnostic` 8 questions · `onboarding` 8 · `content-and-brand` 11 — all parse |
| Dead-link scan over the moved files | clean (alix's relative links re-pointed one level deeper) |

### Phase D

| Proof | Result |
|---|---|
| `process-raw.sh` on a 2 s ffmpeg sine `.wav` | `skipped … needs ffmpeg and whisper.cpp (whisper-cli) — missing: whisper-cli` · `RESULT: PROCESSED 0 (skipped 1)` |
| same, with a `whisper-cli` shim and a fake model file | processed; manifest `{"kind":"audio","extractor":"whisper.cpp","model":"ggml-base.bin","language":"en","chars":20}` — valid JSON |
| `new-run.sh --dry-run` on a synthetic spec overlapping a live run | `[WARN] overlaps live-one on apps/web/app/x/page.tsx …` and still `RESULT: DRY-RUN` |
| sustentus dry-run after D | `RESULT: DRY-RUN 29` — the new/changed T files only, twice identical |

### Phase E — by reading only

CI on [#133](https://github.com/k0d0minio/jamienisbet/pull/133) is the verdict. Verified by
reading: every new fetch opts in with `cache: "force-cache"` + `next.revalidate` and no reading
route exports `force-dynamic`; `commitRepoFiles` only creates, so the snapshot cannot overwrite;
the `/start` action re-reads the snapshot server-side; no `.env*` file was read or edited; no
secret in the diff. The dashboard token's **Contents: write** on icm-board could not be verified
from this session — an operator step in that PR.

### Phase F — definition of done

| Check | Result |
|---|---|
| `grep -rn "profile" workspaces _system/contracts .claude AGENTS.md .icm/CONTEXT.md` | remaining hits: the lead *profile page* in `start/` and `CLIENTS.md`, `PIPELINE.md`'s sentence that an old `- profile:` line is **ignored** — none asks for a profile to be declared, chosen or checked |
| sustentus / remi-ai | `status` clean, heads `52af3f8ff` / `5815bcd`, unchanged |
| The €120 anchor | `_system/knowledge/pricing.md` and the deal folders' `private/` — **and** alix's historic `berceo-platform/03-quote.md` + `04-devis-berceo.md`, documents as sent to the client (see § 5) |
| No T file carries a secret, token, address, channel id or rate | grep clean (prose mentions of variable *names* only) |
| self-check | runs in CI on #46 |

## 4. The cold read — twelve folders, as `/client` would state them

| Folder | `- repo:` | `- language:` | `- engagement:` | Highest `NN-` artefact → stage |
|---|---|---|---|---|
| alex-valexo | none yet | en | none | — (no engagement; 01 intake would open one) |
| alix-hahusseau | k0d0minio/berceo | fr | berceo-platform | `04-devis-berceo.md` → **04 proposal** (PDF beside it) |
| billy-carlson | k0d0minio/vinecliff | en | vinecliff-site | `02-discovery-prep.md` → **02 look** |
| casey-hebbel | k0d0minio/casey-hebbel | en | opening-night | `04-proposal.md` → **04 proposal** |
| diogo-rita | k0d0minio/agorasim | pt | agorasim-v1 | none yet (`open-questions.md`) → **01 intake** |
| dragon | none yet | en | none | — |
| jerome | none yet | fr | none | — (row lost; Notes keep the history) |
| karen | none yet | en | none (`barzinho-management` ended; `private/negotiation.md`) | — |
| magali | k0d0minio/collabimmo | fr | collabimmo-followon | none yet (`.gitkeep`) → **01 intake** |
| remi | k0d0minio/remi-ai | en | none | — (equity relationship; `private/terms-sheet.md` to write — operator) |
| rui-matias | k0d0minio/kau-american-bbq | en | none | — |
| sustentus | sustentus/sustentus | en | none | — (running client; Stripe is the record) |

## 5. Where the directive's text was not followed literally, and why

| Directive | Done instead | Reason |
|---|---|---|
| Grounding: the design brief at `.icm/docs/2026-09-22-icm-board-rework-brief.md` | absent from both checkouts; proceeded on the directive | the directive's own instruction for that case |
| Phase A: "`- repo:` line in every DEAL.md" | skipped in A; Phase C's dash-field schema carries it | the directive's own amendment table |
| `new-run.sh --dry-run` prints `RESULT: DRY-RUN` | on **stderr**; stdout stays the PR body | the script's header reason — dry-run stdout is pipeable into `gh pr create --body-file -`; the header wins (§ 5 rule) |
| Phase D bookkeeping: `setup.sh` section 11, `icm-check.md`'s D7 note | written in A and C respectively, where the files were open | same bytes, earlier commit |
| Agency brief §8: an OpenCode run with the shell.env plugin | the reader proven against the SQLite store with a real session id; no `opencode run` launched; the plugin not installed on this machine | "do not install software"; operator step |
| `deploy-status.sh` / `rollback.sh --vercel` live | proven to `SKIP` only | no Vercel token in the session; nothing configured |
| env-check "on this repo" | on the scratch repo | icm-board carries no pipeline of its own |
| DEAL.md `- repo:` for jerome, karen | `none yet` (the directive's value) though repos exist in the org; the history kept in Notes | the directive names the value; the fact is preserved |
| `- language:` for magali, diogo-rita | inferred `fr`, `pt` from the artefacts | no explicit source; noted for Jamie |
| `- contacts:` | names and roles only, no phones or emails | "never a credential or identity document"; Neon holds contact data |
| The €120 anchor "only in pricing.md and private/" | also in alix's `03-quote.md` and `04-devis-berceo.md` | those are the quote and devis **as sent** to the client, moved by `git mv` with provenance; "nothing in a deal folder is edited or deleted" outranks the grep line |
| E3: remove the two questionnaires from `jamienisbet/.icm/onboarding/` | only `README.md` existed there (`project-intake.md` deleted in `998f38c`); the three forms were authored fresh in icm-board in Phase C, under the dashboard's grammar, and the README removed | nothing to move; the grammar proof covers the new files |
| E4: `lib/icm-board.ts` with one `readIcmBoardFile()` | `lib/icm-board.ts` with one `loadIntakeForm()` returning the parsed snapshot | one file, one form; the parser is shared with the dashboard, so the helper returns what the page needs |
| E8: "ConvertFlow's missing-repo gap" | `components/convert-flow.tsx` does not exist; the lead page's comment says the "Finish conversion" row is gone and an unlit repo glyph in `LeadLinks` is the nudge | said as found, in the PR body |
| E1: `clientSlug()` proposes `deal_slug` | `clientSlug(name)` with `_` → `-` | repos are snake_case, deal folders kebab-case (`workspaces/deals/README.md`) |
| Stub Done line `…, <commit>` | `…, k0d0minio/icm-board#46 — Phase F commit` | a commit cannot carry its own SHA; the PR is the stable pointer |
| not in the directive | Features row "intake epics + tiered profiles" reworded to the one pipeline (D22) | the row described the retired profiles; wording only |
| not in the directive | this repo's `.icm/CONTEXT.md` prose rewritten around the removed line, not just the line removed | the surrounding paragraph explained the line |

## 6. Operator steps (collected from both PR bodies)

icm-board: install `pandoc` (DOCX rendering), `whisper.cpp` (`whisper-cli`; ffmpeg is present) if
transcripts are wanted; answer Q22–Q24 in `_system/setup/questionnaire.md`; place `house.docx`
(the reference document for `render-deal.sh`); name the Drive parent folder for D25 placements;
write `workspaces/deals/remi/private/terms-sheet.md`; the estate rollout of the A/D template
additions (`icm-sync.sh --apply` per repo, each its own PR) — not done here by design; every repo
will drift-report `ticket-craft/SKILL.md`, `intake/README.md` and `pr-conventions/SKILL.md` until
its own PR carries the new bytes (the D7 rule working). Pre-existing, not fixed: epic
`opencode-executor` says `of 5` where six stubs exist (`validate-intake.sh` INVALID).

jamienisbet: Contents: write on icm-board for the dashboard's `GITHUB_TOKEN`; `GITHUB_TOKEN` on
the portfolio deployment for `/start`; migration 0024 applies on merge; set `deal_slug` on the
rows with a folder (the twelve mappings in #133); the referral-schema value change needs no
data migration.

## 7. Open for the next session

- Proving the sell and start workspaces on a live deal — every contract is "rewritten
  2026-09-22, unproven" until `/client` runs one forward and `render-deal.sh` renders a DOCX.
- The estate rollout of Phase A/D (sustentus first, from its D20 branch; then remi-ai).
- The Vercel read verbs, live: `deploy-status.sh` and `rollback.sh --vercel` against a repo
  with `VERCEL_TOKEN` set.
- Jerome's lost row and Karen's ended engagement: whether either relationship reopens is a
  `/client` question, not a folder one.
- Whether `/start` should also offer the free look in the site header (the header CTA still
  points at the contact form).
