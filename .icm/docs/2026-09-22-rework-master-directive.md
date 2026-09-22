Agent Directive — icm-board rework: the deal workspace, the agency layer, intake, positioning, and the jamienisbet surfaces (2026-09-22, master)
Target agent: Claude Code, local, at ~/Apps (the icm-board checkout) with ~/Apps/projects/jamienisbet on disk. Operator: Jamie Nisbet. He merges every PR from GitHub. CI is the verdict. Session shape: one direct working session — not a pipeline run. Do not invoke /pipeline, /project, /client, /day or /icm-check, do not cut stubs or open runs, do not create anything under .icm/runs/ or .icm/intake/. This directive changes the pipeline's own contracts and scripts; running it through the pipeline would have the pipeline edit itself mid-flight. Grounding: the design brief .icm/docs/2026-09-22-icm-board-rework-brief.md (r2; Jamie places it there before this session — if it is absent, proceed on this directive alone, which is self-contained, and say so in the run log) and the agency DevOps brief .icm/docs/Agency_DevOps_Brainstorm.md (r3, on main). Decisions of record are in .icm/project.md D1–D22 and in §1 below.

0. Boundaries — read before anything else
Repositories touched: two. ~/Apps (icm-board) on a new branch claude/rework-deal-workspace-2026-09-22 from main, one PR. ~/Apps/projects/jamienisbet on a new branch claude/rework-intake-and-deals-2026-09-22 from main, one PR. Nothing else under projects/ is read for writing, synced, or edited — not sustentus, not remi-ai, not any client repo. The estate rollout of template additions is a later session (icm-sync.sh --apply, repo by repo).

Standing rules, all of them in force:

Never build an orchestrator (D3, D11). Every script you write reports, renders or prepares; nothing sends, signs, invoices, syncs, watches, retries or crosses a human gate.
Gates are human checkboxes. Read, never tick.
No outbound action leaves this session: no email, no Slack, no Drive upload, no Neon write, no Vercel change, no invoice. The Drive step you will write into a stage contract is for future deal sessions (D25), not for this one.
CI is the source of truth. No local build, lint, typecheck, test, format, tsc, next build, pnpm dev, drizzle-kit push — in either repo. Generating a migration file is allowed; applying one is not.
No secrets in git. A plaintext credential found anywhere is flagged in the PR body, never committed around.
Stage paths explicitly — never git add -A. Never force-push. Never git stash bare.
Nothing is deleted from a deal folder: git mv only, with a provenance line at the top of every moved file.
T files carry no identity; nothing a repo runs depends on icm-board (agency brief flag 1). The deal workspace is icm-board's own and is not seeded into repos.
Do not install software. Where a tool is missing (pandoc, ffmpeg, whisper.cpp), the script reports SKIP with the install hint and you note it in the run log.
Harness facts are verified on the installed binary before a script relies on them (agency brief §9).
Resume protocol. Commit at the end of each phase with the message prefix given in that phase. If this session is restarted, run git log --oneline main..HEAD in each repo and continue at the first phase whose commit is absent; re-run that phase's proof before moving on.

1. Decisions this directive implements (Jamie, 2026-09-22 — record as D24–D26 in Phase F)
D23 is the agency brief's own decision row; Phase A records it as that brief specifies.

D24 — One home per fact; the deal workspace lives in icm-board. Relationship state (rung, next action, stripe_customer_id, github_repo, work_started_at, the agreed value and shape) lives in Neon and is never mirrored into git — the Ladder, Stage and Value rows leave DEAL.md. Every deal document, private reasoning included, lives in icm-board at workspaces/deals/<client>/<engagement>/, committed straight to main with a Deal: prefix. A client repo receives only immutable, provenance-stamped snapshots at kickoff (.icm/docs/proposal-<date>.md, scope-<date>.md) and never anything under private/. The dashboard reads the deal folder live (read-only, D13) and shows a rung-versus-stage badge; nothing syncs. A copy is allowed only when immutable and provenance-stamped. Rejected: Neon as the document store (breaks the four ticket-storage constraints of 2026-08-30 and regrows the machinery the dashboard retired in August); a .icm/client/ workspace per repo (splits one engagement across two repos, scatters precedent, and puts the relationship on a repo meant to be handed over). remi-ai and sustentus get tracked deal folders here. The client repo is created at signature by default; earlier on Jamie's request (supersedes the first-round "at first reply", whose reason moved).

D25 — Documents to Jamie's own Drive; sending stays human. A deal session may render a proposal or agreement to DOCX and place it in Google Drive under a folder named after the client (creating the folder when absent) using the Drive connector, and log the link in DEAL.md. Sending for signature, and every message to the client, remain Jamie's. This narrows "no outbound action" the way D11 narrowed D3: a write to the operator's own storage is not an outbound action.

D26 — Pick-up is the pipeline verb; runs are cut for disjointness. The board's copy-prompt and deep links send /pipeline new <epic>/<slug> (or the lane verb for a triage stub) wherever the repo carries the /pipeline router, and the ## Prompt body only where it does not. Scope groups stubs into ## Parallelizable only when their touches: do not overlap; Build merges origin/main before the ready flip; new-run.sh warns on overlap with a live run. Report, never refuse.

Facts decided and used throughout: floor €500 everywhere (the referral site's €200 line goes) · €120/hour is the internal anchor, never public · diagnostic bands local €100–€900 (100% credit, build signed within 30 days) · SME €2,500–€5,000 (30 days) · enterprise €7,500–€15,000 (90 days) · tiers Foundation · Full Build · Partnership: tiers are scope, Partnership a qualified shape, the ladder is the What happens next narrative · the method's public name is the paper's v2 name, Model Workspace Protocol; internal vocabulary stays ICM · landing pages carry no ongoing cost whatsoever; a monthly support line exists only for builds with state and is priced by the build's complexity (euro figures: "— to set", the first quote fills them) · basic support = crash fixes on call; it requires a fail-safe page and Sentry · DOCX only; Google Docs/Slides and Google eSignature; English mostly, some French and Portuguese · the free look happens after the first call · no proof-of-concept rule.

2. Where you are starting from (verified 2026-09-22)
icm-board main = 7fb18e5. The agency brief r3 is on main and not implemented: _system/template/icm-pipeline/scripts/ holds the fourteen D20/D22 scripts + lib/; lanes are bug tweak chore knowledge; no setup.sh, report.sh, env.sh, deploy-status.sh, rollback.sh, usage-snapshot.sh, no hotfix lane, no deploy/reporting/migrations keys in project.json, no .icm/MANIFEST in repos.
icm-board's own .icm/CONTEXT.md still carries - profile: intake (ignored since D22); the parked stub .icm/intake/triage/profile-wording-sweep.md lists every file that still speaks of profiles. Its sweep is folded into this directive (Phase F); the stub is moved to _done/ only if every file it names has been swept.
workspaces/sell/ (01_intake · 02_discovery · 03_quote · 04_proposal + six references) and workspaces/start/ (05_onboarding · 06_repo · 07_kickoff + two references) exist as first written on 2026-08-26 and have never run a deal forward. workspaces/deals/ holds ten adopted folders (alex-valexo, alix-hahusseau, billy-carlson, casey-hebbel, diogo-rita, dragon, jerome, karen, magali, rui-matias); every DEAL.md is a borderless table with Ladder, Stage, Shape, Value, Source plus undocumented Adopted, Company, Repo (and once Contacts) rows and free-text Stage values.
_system/knowledge/pricing.md says "no day or hourly rate", floor €500, websites €1,000–€2,500, retainers €200–€4,000/month, no audit or diagnostic offer. terms.md says support after handover is "not yet established". voice.md has no identity statement. There is no positioning.md.
jamienisbet main = 16b8744, clean. Relevant files: packages/services/src/schema/index.ts (biz.clients, form_links), packages/services/src/deal.ts, packages/services/src/forms.ts, packages/services/drizzle/ (migrations to 0023), websites/admin-dashboard/lib/tickets.ts (board reader; claudeSessionUrl line ~272, claudeTerminalUrl ~291, HOUSE_REPOS, TODAY_REPO), websites/admin-dashboard/app/(app)/actions.ts (createClientRepo ~1477, writeFormAnswersToRepo ~1604), websites/admin-dashboard/lib/icm-scaffold.ts, websites/admin-dashboard/lib/leads.ts, components/convert-flow.tsx, components/deal-badges.tsx, websites/portfolio/messages/{en,fr,pt}.json, websites/portfolio/lib/{services,problems,site}.ts, websites/portfolio/app/[locale]/tech/page.tsx, websites/portfolio/app/f/[token]/page.tsx, websites/portfolio/app/actions/form.ts, websites/sellers-site/messages/{en,fr,pt}.json, websites/sellers-site/lib/referral-schema.ts, .icm/onboarding/*.md (the two questionnaires the Forms card sends today).
The dashboard already reads icm-board over the GitHub API (.icm/today.md; icm-board is in HOUSE_REPOS) with cache: "force-cache" + 60-second revalidate; read those header comments in lib/tickets.ts before writing any new reader — the two cache hazards there apply to every fetch you add.
createClientRepo scaffolds _system/template/{icm,claude,root} from icm-board at call time. It does not change in this directive (no per-repo deal workspace); ConvertFlow already flags a missing repo on an active row, which is the "create at signature" nudge.
3. The target, in one page
icm-board/
  workspaces/
    sell/      01_intake → 02_look → 03_quote → 04_proposal → 05_agreement      (contracts + references; runs from here, cloud or local)
    start/     06_onboarding → 07_kickoff                                       (07 needs the client repo on disk)
    deliver/   project · day · conformance                                      (unchanged in role; wording swept)
    deals/<client>/
      DEAL.md                       dash-fields; no mirror of any Neon column
      <engagement>/                 one per deal, sequential, never two live
        01-intake.md … 08-handover.md     the artefacts, as sent / as signed
        answers/<form>.md                 immutable snapshots of Neon's form answers
        raw/                              client material; media ignored, transcripts tracked
        private/ pricing.md · negotiation.md · terms-sheet.md · economics.md
      out/                          rendered DOCX — gitignored
  _system/knowledge/   positioning.md (new) · pricing · services · terms · voice · stack (amended)
  _system/scripts/     + render-deal.sh · validate-deal.sh · run-economics.sh (agency brief) · vercel-env.sh loop (agency brief)
  _system/template/icm-pipeline/   + agency brief §5 · lanes/handover · support block · transcription kind · parallelism fixes
  .claude/commands/client.md       positional stage; the two locations; the Drive step
A client repo gains nothing new from this directive except what the template rollout later syncs (agency layer, handover lane, support block, transcription). jamienisbet gains the readers, the forms source switch, the intake form, the verb, two columns, and the copy.

Phase A — the agency layer (prerequisite; icm-board)
Implement .icm/docs/Agency_DevOps_Brainstorm.md §5, §6, §7 items 1–10, proven by §8, under §9, exactly as written there, with these amendments only:

Brief says	Do instead	Why
§3 decision 7 / §4.4: run-economics.sh writes workspaces/deals/<slug>/economics.md; DEAL.md gains - repo:	writes workspaces/deals/<client>/<engagement>/private/economics.md, resolving <client> by the - repo: dash-field of each DEAL.md and <engagement> by its - engagement: field; RESULT: SKIP <repo>: no deal folder names it when none does. The - repo: line is part of Phase C's schema; write the script against dash-fields now, prove it after Phase C	D24
§6 project.json schema	add "support": { "tier": "none", "failsafe_page": "", "monitoring": { "sentry_dsn_env": "SENTRY_DSN" } } to the stub beside deploy, reporting, migrations; lib/project.sh defaults it; Phase D adds the checks	§8.3 of the design brief
§4.5 new-run.sh --lane hotfix	accept hotfix now and handover in Phase D — one lane vocabulary list in lib/project.sh or new-run.sh, read by resolve-run.sh, project-labels.sh, close-out.sh	two new lanes, one edit
§4.7 /setup ten sections	leave room for an eleventh, Support (Phase D)	—
§7 item 10 "D23"	write D23 as the brief specifies; D24–D26 are Phase F's	numbering
§7 item 7 "the - repo: line in every DEAL.md"	skip here; Phase C rewrites every DEAL.md	avoid touching the folders twice
Everything else in that brief stands, including its §8 definition of done (the scratch-clone self-sufficiency proof, the sustentus dry-run listing exactly the new T files, setup.sh --fix --template on a scratch bare repo, the report.sh --dry-run cases, the two usage-snapshot.sh lines inside this session, env.sh add with empty stdin, deploy-status.sh "not declared", new-run.sh --lane hotfix --dry-run). Sustentus is proven against read-only, on whatever branch its local checkout is on; nothing there is edited, synced or pushed.

Commit: Rework A: agency layer — report.sh, deploy block, env.sh, deploy-status, hotfix lane, usage, economics, /setup, reference workflows (agency brief r3, D23).

Phase B — knowledge and contracts (icm-board)
B1 _system/knowledge/positioning.md — new (Layer 3; cited by sell 01/04, the site, the referral site, outreach)
Sections, in this order, each filled from §1 of this directive where it decides the content and left as — not yet established where Jamie's own words are needed:

The offer in one sentence — draft one from the facts (a senior engineer who looks at how a business runs, sorts which parts belong to software, an assistant, a person or nothing, builds what makes sense at a fixed price, and hands over a repository that carries its own method); mark — draft, Jamie to confirm (Q22).
The three verbs — Look, then sort · Build what makes sense · Hand it over, governed — one paragraph each; the third says plainly that the repo carries its own interpretable pipeline (gates, release records, an environment declared once and checked) and that their team or any developer can run it.
The method — built on the Model Workspace Protocol (Van Clief & McDermott, 2026, arXiv 2603.16021): an open method, cited; no affiliation with eduba or its authors is claimed or implied; the paper's current title and the method's name are re-checked against arXiv before any public copy ships. The estate's internal vocabulary stays ICM.
Three registers — one table: local operating business · SME with a process worth automating · enterprise — columns: vocabulary · the proof they need · the entry offer (a free look · a free look, then a diagnostic · a diagnostic or a workshop) · price posture (a number on the page · a range on the call · never on the page) · words never used. Fill what the facts decide; leave the two example-sentence cells per register — not yet established (Q23).
What never appears publicly — the hourly anchor, the floor, the bands, the retainer range, the diagnostic bands.
Channels — referrals and the Mafra network (from target-profile.md); the referral site, aimed at professionals with the free look as the referable thing; the AI-SME channel still — not yet established.
B2 _system/knowledge/pricing.md
Replace "no day or hourly rate" with The internal anchor: €120/hour — used for scope-to-number and for the rare client who asks; never a billing basis, never on any public surface, revised with demand. Note that the Berceo deviation of 2026-08-27 is now policy.
The floor is €500, everywhere — including the referral site's landing page; there is no loss-leader below it.
The four shapes (replacing the three): one-off · one-off + support · retainer · partnership — with the recurring line for one-off + support priced by the build's complexity: micro (a landing page) → no ongoing cost whatsoever; standard → a monthly support line, euro figure — to set at the first quote under this rule; retainer and partnership unchanged in band (€200–€4,000/month stays until re-scoped).
The paid diagnostic — the three bands and credit windows from §1, verbatim; credited 100% against the build signed within the window; no proof-of-concept rule (a POC is a Foundation tier with a named outcome).
Tiers — Foundation and Full Build are scope tiers with their own numbers; Partnership is a shape shown only when the look qualifies the business for it; the What happens next section tells the ladder.
Keep every existing rule (quote from the card, deviate by name; scope drives price; discounts are decisions; in-kind valued in EUR).
B3 _system/knowledge/services.md
Add three services in the existing table shape: The free look (free, after the first call; what the client gets: one page — what I saw, where each part of the work belongs, three things I'd do first, how I'd start); The diagnostic (the paid one: the detailed report on implementing and improving current processes and workflows efficiently; the 52-question bank as the instrument; two weeks; bands per pricing.md); Hosting & basic support (Vercel Pro in Jamie's team, Supabase or Neon, crash fixes on call; requires the fail-safe page and Sentry; included at no cost for landing pages; a monthly line for builds with state). Amend the three existing services' "always in scope" lists to include the fail-safe page and Sentry for anything with state.

B4 _system/knowledge/terms.md
Support after handover — replaces "not yet established": basic support defined as above; the Jamie-hosted pattern is its home; the client-owned pattern has no support line (retainer only); landing pages: no ongoing cost.
Paper — the agreement is a DOCX signed through Google eSignature; the signed copy lives in Google Drive in a folder named after the client (parent folder — to set (Q24), Drive root until then); "a reply saying agreed" remains enough for a free look and for a house-deal re-quote, never for an agreement.
Partnerships — the term sheet (equity, commission, revenue share) lives only in the deal's private/terms-sheet.md; the agreement references it by name and date and never restates a percentage; no client repo ever carries it (REMI, 2026-08).
Languages — English by default, French or Portuguese where the client leads in it, recorded on DEAL.md.
Keep the three red lines.
B5 _system/knowledge/voice.md, stack.md, README.md
voice.md: add French beside Portuguese; add one line pointing at positioning.md § registers for vocabulary per register.
stack.md: the invisible scope every build with state ships with gains the fail-safe technical difficulties page and Sentry; local tools the pipeline may use: pandoc (DOCX), ffmpeg + whisper.cpp (transcription) — installed by Jamie, never by a script.
README.md: add positioning.md to the index with what cites it.
B6 _system/setup/questionnaire.md
Append Q22 (the offer in one sentence and the three verbs, in Jamie's words) · Q23 (per register: one real sentence he would say to them, and one word he would never use) · Q24 (the Drive parent folder for client documents; the house DOCX look — a reference .docx or "plain"). Add a Done-log row for this session naming them as open.

B7 Contracts
_system/contracts/WORKSPACES.md: the "Rules" section gains One home per fact (state in Neon, documents here, copies only when immutable and provenance-stamped); the deal folder shape of §3 with private/; stage is positional (the highest NN- artefact in the live engagement); deal commits go straight to main with a Deal: prefix (words, not code — the same standing as Plan:/Wrap:); the snapshot rule for what enters a client repo. Update the stage list (sell 01–05, start 06–07; 06_repo retired into 07's gate).
_system/contracts/CLIENTS.md: delete every sentence that has a deal folder mirror the rung; add the two new columns Phase E creates (deal_slug, support_minor) to the flags table with their cues; state the badge rule (rung and folder stage shown side by side; active with no 05-agreement.md, not_won with an open engagement, discussing with a signed agreement → badge); repo creation at signature by default, earlier on Jamie's request — ConvertFlow's missing-repo gap is the nudge.
_system/contracts/TICKETS.md § Prompt: the board sends the pipeline verb where the repo carries the router, the ## Prompt body otherwise; the ## Prompt remains the brief Define reads and is still required in a stub (D26). Sweep "intake-profile" wording here (the parked stub's list).
_system/contracts/PIPELINE.md: the file table gains the agency brief's additions (Phase A) and Phase D's (handover lane, support, transcription); sweep profile wording.
_system/template/claude/skills/ticket-craft/SKILL.md and _system/template/icm/intake/README.md: the same one-sentence pick-up change. These are canonical assets — every repo will drift-report until its own PR carries the new bytes; that is the D7 rule working, say so in the PR body. Update icm-board's own .claude/skills/ticket-craft/SKILL.md and .icm/intake/README.md to the same bytes (icm-board is held to its baseline).
Commit: Rework B: knowledge and contracts — positioning, the anchor and the floor, the diagnostic, support, the four shapes, one home per fact, the pick-up verb.

Phase C — the deal workspace (icm-board)
C1 workspaces/sell/ — rewrite in place
CONTEXT.md: five stages, the Layer-3 references, "runs from any session that has icm-board in view — the knowledge layer is here — except where a stage says it needs the client repo on disk"; a deal is one engagement folder; the rung is read from the dashboard when a stage needs it and never written down; inbound and outbound share the front door.

Stage contracts, each ≤80 lines, the five-part shape (Inputs · Process · Gate — Jamie · Outputs · Audit), gates as unticked checkboxes in prose:

Stage	Job	Reads	Writes	Gate
01_intake	qualify; draft the reply that asks for the call	qualification.md, positioning.md, services.md, voice.md, the lead's words (from the Neon row or the intake form answers)	deals/<client>/DEAL.md (created), <engagement>/01-intake.md: verdict one line per criterion + the reply	Jamie sends; sets the rung; a decline is drafted kindly
02_look	the free look, after the first call	call-crib.md (what the call settled), look-template.md, the public presence, answers/intake-diagnostic.md, raw/ transcripts, read-only access only where offered (password manager; never a value here)	02-look.md (≤400 words: what I saw · where the work belongs · three things first · how I'd start)	Jamie edits and sends
03_quote	scope · tiers · shapes · numbers	the look, pricing.md, services.md, terms.md, precedent in deals/	03-quote.md (scope as outcomes · not included · the tier table · terms deltas · [LAWYER] · the support line) and private/pricing.md (how the number was reached); where spec-shaped, the Foundation tier is the diagnostic	Jamie approves scope, tiers, numbers
04_proposal	the document	proposal-template.md, the quote verbatim, voice.md	04-proposal.md; render-deal.sh → out/04-proposal.docx; then, per D25, place the DOCX in Drive under the client's folder with the Drive connector (create the folder when absent) and log the link in DEAL.md	Jamie reads, edits the markdown, re-renders, sends
05_agreement	the paper	agreement-template.<lang>.md, the proposal, the chosen tier, terms.md, private/terms-sheet.md by reference only	05-agreement.md with a dash-field header (- tier:, - shape:, - agreed: <EUR>, - recurring: <EUR/month or none>, - signed: <date or pending>, - drive: <link>); DOCX rendered and placed in Drive as in 04	Jamie sends for eSignature; on signature: logs it, enters the agreed value and shape on the Neon row, raises the deposit draft, moves the rung to active; creates the repo now by default (or earlier, on his say)
02_discovery/ is retired (git mv its contract's useful lines into 02_look and call-crib.md; the folder goes).

References — references/:

qualification.md: keep; add that the intake form answers are the first evidence.
call-crib.md (new, distilled from discovery-interview.md § Before / The craft / The arc, first four beats only): 20–30 minutes; their story · the job to be done · what done looks like · the two or three [BLOCKER]s; no number in the room; the closing ask for links and a screen recording. discovery-interview.md stays as the diagnostic's full arc.
look-template.md (new): the four sections, the word cap, the sort vocabulary (could run itself · keep a person on it · worth an assistant · don't build this).
discovery-questions.md: keep; its header says it is the diagnostic's instrument and the crib's source.
diagnostic-report-template.md (new): every process seen, sorted four ways, in order, what each needs, what it costs to build and to run, what to leave alone; a one-page summary first.
proposal-template.md: rewrite — header dash-fields (- language:, - tiers: foundation, full-build[, partnership]), the five sections, the three-column price table, What happens next as the ladder; no name, address or rate in the file (identity comes from DEAL.md and the render's reference document).
agreement-template.en.md, .fr.md, .pt.md (new): parties · scope by reference to the proposal of <date> · price and schedule (50% deposit / 50% at handover as terms.md says, or the deal's delta) · ownership pattern · hosting and support line · revisions (two rounds) · timeline clock · termination · [LAWYER] clause slots for partnership terms "per the separate agreement of <date>" · signature block for Google eSignature. Plain house practice, [LAWYER]-tagged where it resembles drafting; no legal text invented beyond what terms.md already states.
outreach.md, target-profile.md: keep; point at positioning.md; target-profile names the three registers.
forms/ (new): intake-diagnostic.md (6–8 questions: what the business does · what eats the week · the tools used today · what done would look like · links · an optional walkthrough-recording link · budget shape using the referral form's five bands with ~€500 — landing page · language), onboarding.md and content-and-brand.md — the last two are jamienisbet's .icm/onboarding/*.md questionnaires moved here (git mv across repos is a copy + provenance line here and a removal in Phase E) and trimmed. Read projects/jamienisbet/packages/services/src/forms.ts first: the markdown grammar those files use is what form_snapshot parses, and every form here must parse under it unchanged.
C2 workspaces/start/ — rewrite in place
06_onboarding (was 05): the checklist as a needed/asked/received table; the two onboarding forms sent from the dashboard (source: this repo's sell/references/forms/); access recorded as existing; the deposit paid; terms confirmed = the signed agreement. 07_kickoff (absorbs 06_repo): the repo — created via the dashboard at signature or adopted if it exists, never by hand; icm-check.sh --fix then icm-sync.sh --apply (until /setup is seeded, then /setup); the snapshots into .icm/docs/ with the provenance line (proposal-<date>.md, scope-<date>.md — the quote's scope section only, never its numbers, never private/); /project first run; 07-kickoff.md; the flags. references/onboarding-checklist.md and kickoff-checklist.md updated to match; the "prefix registered" wording removed everywhere (there is no prefix).

C3 workspaces/deals/ — the folders
README.md rewritten to §3's shape, the DEAL.md schema below, the rules (never a secret · nothing deleted · Jamie's edits win · one home per fact · Deal: commits straight to main · media under raw/ never committed · out/ never committed · private/ never leaves this repo · a lost deal keeps its folder · a returning client gets a new engagement, never a new folder).

DEAL.md schema (dash-fields; the estate's header grammar):

# <Company or name> — client

- client: <slug>                 ← this folder; the dashboard's deal_slug
- company: <name>
- contacts: <first names and roles — never an email or phone>
- repo: <owner/name | none yet>
- language: en | fr | pt
- engagement: <slug | none>      ← the live one; stage is positional under it
- source: portfolio-form | referral (<who>) | outbound | adopted

## Engagements
| slug | shape | started | ended | outcome |

## Log
- <date> — <event>
Re-cut the ten folders, nothing deleted, git mv only, a provenance line at the top of every moved file:

Folder	DEAL.md conversion	Engagement folder	Moves
all ten	table → dash-fields; Ladder, Stage, Value rows dropped (the value survives in the quote; the rung is Neon's); Adopted → a log line; Company, Repo, Contacts → fields; Source kept; every existing section below the table kept verbatim under a ## Notes (adopted) heading	one engagement per folder that has artefacts, slug from the deal's subject (e.g. berceo-platform, vinecliff-site, opening-night, agorasim-v1, barzinho-management, pavillon-vert-landing, collabimmo-followon); folders with only DEAL.md get - engagement: none and no subfolder	numbered artefacts move into the engagement folder keeping their names (02-discovery-* stays — the 02- prefix is the look's position); clearly private analyses move to private/ (karen's 04-counter-analysis.md → private/negotiation.md; any pricing reasoning found inside a quote is left in place — adopted files are not split); 04-devis-berceo.pdf stays where it is (nothing deleted) with a line in the log that binaries are no longer committed
alix-hahusseau	- repo: from its Repo row; - language: fr	berceo-platform	as above
diogo-rita	- repo: k0d0minio/agorasim (or as its row says)	agorasim-v1; open-questions.md moves in	—
karen, jerome, alex-valexo	- repo: none yet; the outcome row on the engagement table says lost	as above	—
magali	the follow-on at intake: - engagement: collabimmo-followon with only 01-intake.md to be written later	folder created empty with .gitkeep	—
Add two new folders with a DEAL.md each and - source: adopted: remi/ (- repo: k0d0minio/remi-ai, - engagement: none; the equity is not written here in this session — Jamie fills private/terms-sheet.md himself) and sustentus/ (- repo: sustentus/sustentus). Both tracked.

.gitignore additions: workspaces/deals/**/out/, workspaces/deals/**/raw/*.{mp4,mov,m4a,mp3,wav,webm,mkv,aac,ogg} (expand the list as sensible); transcripts (*.txt, *.md) under raw/ stay tracked.

C4 .claude/commands/client.md — rewrite
Argument: a person, company or client slug; resolve with Jamie when ambiguous. Steps: find workspaces/deals/<client>/; if none and the relationship is new, enter sell/01_intake (which creates it); if none and the relationship predates the system, adopt at its true stage (README § adopted); if it exists, read DEAL.md → engagement, list that folder, state the stage as the highest NN- artefact present and the next stage, and enter that contract; a folder with - engagement: none and a repo is a returning client — ask whether to open a new engagement. Where the stage needs the client repo (07_kickoff, and the handover lane's record step), resolve projects/<repo> and STOP if it is not on disk. Travelling rules: writes stay inside workspaces/deals/ and, in 07, the client repo's .icm/; drafts are drafted, Jamie sends; the rung is never written down here; no secrets; D25's Drive step is the only write outside these two places and only for a rendered DOCX.

C5 Scripts (icm-board, _system/scripts/, house header, one RESULT: line)
validate-deal.sh <client>[/<engagement>] — read-only. For the live engagement (or the one named): every bullet under What you'll get in 04-proposal.md appears as a scope line in 03-quote.md; every number in the proposal's price table equals the quote's per tier; 05-agreement.md's - tier: names a tier the quote offered and its - agreed: equals that tier's number (or a - deviation: line explains); every [LAWYER] tag in the quote survives into the proposal and agreement; - language: agrees across the three; no client-facing file references a path under private/; no string matching the estate's credential patterns (reuse icm-check.sh's or write one: sk_live_, sk_test_, whsec_, ghp_, -----BEGIN, password=, token=) anywhere in the folder. RESULT: OK | DRIFT n | SKIP (no engagement). Exit 0 on DRIFT (a report), 2 on an unreadable folder. --all walks every client.
render-deal.sh <client>/<engagement> <NN-artefact> — pandoc markdown → out/<artefact>.docx, with --reference-doc from _system/knowledge/house.docx when present (Q24; plain pandoc default otherwise); never uploads, never commits; RESULT: RENDERED <path> | SKIP (pandoc not found — install hint).
Both are added to self-check.sh's shellcheck scope by being in _system/scripts/.
C6 Root routing
AGENTS.md, CONTEXT.md, README.md, _system/README.md: the "I want to" table (rows for the free look and the agreement; the repo row folded into kickoff), the tree, the standing rule One home per fact added beside "Deals are tracked; secrets are not", the Deal: commit note, no profile wording anywhere.

Proof for Phase C: validate-deal.sh --all prints one line per client and a RESULT: per engagement (adopted engagements may report DRIFT — list each in the PR body; do not edit adopted artefacts to make them pass); render-deal.sh on any engagement with a 04- file renders or reports SKIP correctly; reading each DEAL.md cold, state the ten stages out loud in the run log the way /client would; every form under sell/references/forms/ parses with the grammar forms.ts implements (write a five-line node script in the scratchpad that imports the parser and runs it over the three files; do not add it to either repo).

Commit: Rework C: the deal workspace — five sell stages, two start stages, forms, agreement templates, ten folders re-cut, remi and sustentus folders, /client on positional stage, render-deal.sh, validate-deal.sh (D24, D25).

Phase D — template additions (icm-board, _system/template/icm-pipeline/)
D1 Parallelism (D26)
intake/CONTEXT.md and stages/01_scope/CONTEXT.md step 6: ## Parallelizable is derived — a parallel set contains only stubs whose optional - touches: guesses do not overlap; stubs that share a surface are sequenced; the shared-file stubs (schema and migrations, message catalogues, layouts, dependency manifests) go first in the build order. Ten lines, no script.
stages/03_build/CONTEXT.md: one new step before the draft→ready flip — merge origin/main into the run branch (a merge commit, never a rebase; the preamble's run-folder rule applies), resolve there, on the cheap tier; Release step 7(a) stays as the final merge and is usually a no-op. Say why: the conflict surfaces before the full gate and the previews.
scripts/new-run.sh: after resolving the stub/spec, read - touches: from every live run's 02_define/output/spec.md (resolve-run.sh knows the live runs) and print [WARN] overlaps <slug> on <path> per hit; never refuses; --dry-run shows it.
_shared/github.md: one live run per touched surface in the doctrine list. workspaces/deliver/stages/day/CONTEXT.md step 3: warn when two of today's picks name overlapping touches:.
Before writing the new-run.sh change, spend at most an hour reading real conflict history: git log --merges --grep=conflict and git log -p --diff-filter=M -- pnpm-lock.yaml messages/ 'packages/**/schema*' in projects/sustentus and projects/remi-ai (read-only), and note in the run log which files conflicted most; let that list lead the "shared-file stubs go first" sentence.
D2 lanes/handover/CONTEXT.md (T, new) + MANIFEST line
Human-invoked; the bug lane's economy (draft, cheap tier, one PR, the operator merges). Steps: accounts per the ownership pattern (recorded as existing) · env.sh doc for every key the app reads · setup.sh reports OK · the final invoice draft or the retainer start (the dashboard; a checklist line, not a call) · notes.md carries - handover: <date> and - support: none | basic | retainer · the record step, local only: write 08-handover.md into the deal's engagement folder in icm-board and STOP with the pointer where icm-board is not on disk (the one place a lane names icm-board, and only as "where the operator's deal folder lives", never as a path). new-run.sh --lane handover, resolve-run.sh, project-labels.sh (type:handover), close-out.sh recognise it; the router skill gains the row.

D3 Support
project.json stub: the support block (Phase A added it; confirm shape).
scripts/setup.sh: section 11 Support — when support.tier is basic or retainer: the fail-safe page exists at support.failsafe_page ([FAIL] when declared and absent; [WARN] when undeclared), the Sentry key named by monitoring.sentry_dsn_env is declared in .env.example with [production], and report.sh alert maps to a channel or project-rules.md records the red-job default. complexity: micro → the section prints [INFO] micro: no support line and passes.
stages/04_release/CONTEXT.md step 4 readiness: one line — support tier basic or retainer with no fail-safe page or no Sentry key → stop class 3. Report, never repair.
_shared/project-rules.md stub: a Support slot beside Reporting.
D4 Transcription kind in scripts/process-raw.sh
Kinds audio and video (.mp3 .m4a .wav .aac .ogg .mp4 .mov .webm .mkv): ffmpeg -i <file> -ar 16000 -ac 1 <tmp>.wav then whisper-cli (whisper.cpp; accept WHISPER_BIN and WHISPER_MODEL from the environment, default binary name whisper-cli, default model path ~/.local/share/whisper/ggml-base.bin) → processed/<id>.txt; manifest.json records extractor: whisper.cpp, the model file's basename, the language flag if any. Either binary absent → SKIP <id>: needs ffmpeg and whisper.cpp (whisper-cli) — install hints and exit 0. Nothing is uploaded; nothing is installed. Prove with a two-second ffmpeg -f lavfi -i sine wav in the scratchpad: with the tools absent the SKIP line prints; with them present a (possibly empty) transcript and a manifest entry appear. raw/README.md documents the kind and that media is never committed (the seeded .gitignore line for .icm/raw/ media is added to _system/template/root/'s gitignore fragment if one exists; otherwise to raw/README.md as the rule and to setup.sh's Raw section as a [WARN] when a media file is tracked).

D5 Bookkeeping
MANIFEST (T lines for the new lane and any new file), _system/contracts/PIPELINE.md file table, _system/template/README.md, .claude/commands/icm-check.md wording. icm-sync.sh --dry-run projects/sustentus lists exactly the new and changed T files and nothing else; nothing is applied.

Commit: Rework D: template — disjoint cuts and an early merge (D26), handover lane, support checks, transcription kind.

Phase E — jamienisbet (~/Apps/projects/jamienisbet, branch claude/rework-intake-and-deals-2026-09-22, one PR)
Read AGENTS.md, CLAUDE.md, .icm/CONTEXT.md and websites/admin-dashboard/README.md there first; that repo's conventions win inside it (no local builds; its CI is the verdict; stage paths explicitly).

E1 Schema — packages/services/src/schema/index.ts + one migration
biz.clients gains deal_slug varchar(80) (nullable; the icm-board folder name; unique when set) and support_minor integer NOT NULL DEFAULT 0 (the monthly support line beside a one-off value; 0 = none). Generate packages/services/drizzle/0024_deal_slug_and_support.sql the way 0014 and 0018 were generated (drizzle-kit generate; never push/migrate locally). packages/services/src/deal.ts: DealTerms gains supportMinor; dealComponents() emits a support component ({ kind: "support", valueMinor }) when non-zero; dealHeadline() shows €N + €M/mo support; hasDeal() counts it. lib/leads.ts totals: / month includes support_minor of active rows. The deal card form and components/deal-badges.tsx gain the field and badge. clientSlug() (already exists for suggestedRepoName) proposes deal_slug in the form; Jamie confirms.

E2 The deal reader — websites/admin-dashboard/lib/deals.ts (new) + UI
Read-only, same caching discipline as lib/tickets.ts (cache: "force-cache", next.revalidate: 60, the cache tag, no force-dynamic on any route that calls it). For a row with deal_slug: GET /repos/k0d0minio/icm-board/contents/workspaces/deals/<slug>/DEAL.md → parse dash-fields (client, repo, language, engagement); list workspaces/deals/<slug>/<engagement>/ → stage = the highest NN- prefix present, mapped to its name (01 intake · 02 look · 03 quote · 04 proposal · 05 agreement · 06 onboarding · 07 kickoff · 08 handover); read 05-agreement.md's dash-fields when present (agreed, recurring, shape, signed, drive). Surface: a stage chip on the leads list; on the lead page a Deal block with stage, engagement, language, the Drive link when present, and the badge when rung and folder cannot both be true (active with no 05-agreement.md · not_won with an engagement whose table row has no ended · discussing with - signed: a date). Prefill, never write: when 05-agreement.md carries agreed/recurring/shape and the row's value_minor is 0, show them beside the deal card with a Use these button that fills the form fields for Jamie to save.

E3 Forms from icm-board — actions.ts, the Forms card, lib/forms*
The Forms card lists forms from k0d0minio/icm-board:workspaces/sell/references/forms/*.md instead of this repo's .icm/onboarding/; form_snapshot.sourceRepo records that path. writeFormAnswersToRepo now writes to icm-board at workspaces/deals/<deal_slug>/<engagement>/answers/<form-slug>.md (or workspaces/deals/<deal_slug>/answers/ when DEAL.md → engagement is none), using the existing commitRepoFiles path, one commit, message Deal: <slug> — <form-slug> answers, with a provenance header (snapshot of form_links <id>, completed <date>; Neon is canonical; do not edit). It refuses with a plain sentence when deal_slug is unset. Remove this repo's .icm/onboarding/*.md (they now live in icm-board — Phase C copied them) and every reference to that path (README, .icm/CONTEXT.md, JN-021 mentions). Verify the icm-board write needs no new token scope: the dashboard's GitHub token must have Contents: write on k0d0minio/icm-board; if it does not, say so in the PR body as an operator step — do not change any token.

E4 The public intake form — websites/portfolio/app/[locale]/start/page.tsx (new) + app/actions/intake.ts (new)
Renders intake-diagnostic.md fetched server-side from icm-board (same token and cache rules as the dashboard readers; the portfolio already has a server-side GitHub route for /f/<token> — reuse its helper if one exists, otherwise add lib/icm-board.ts with one readIcmBoardFile() and keep it there). On submit: honeypot as the contact form; create a biz.clients row (source: portfolio, status: lead, name, email, phone, intake_message = the "what eats your week" answer, service mapped from the "what done would look like" choice where the form offers the three problem ids, budget, language), then a completed form_links row (form_slug: intake-diagnostic, snapshot, answers, completed_at: now) so the answers reach the Forms history. Locales en/fr/pt. The existing contact form stays; the hero and the problems cards' calls to action point at /start (§E6).

E5 The pick-up verb — websites/admin-dashboard/lib/tickets.ts
claudeSessionUrl, claudeTerminalUrl and the copy button send the verb when the repo carries .claude/skills/pipeline/SKILL.md (probe once per repo, cached like the .icm/intake probe): /pipeline new <epic>/<slug> for an epic stub, /pipeline <lane> .icm/intake/triage/<slug>.md for a triage stub (lane from its - lane: line), /pipeline build <slug> / /pipeline release <slug> for an in-flight run by its stage; otherwise the ## Prompt body as today. The ticket detail shows the exact string it will send. recutSessionUrl, estateCheckSessionUrl and the maintenance launchers are unchanged.

E6 Portfolio copy — websites/portfolio/messages/{en,fr,pt}.json (+ /tech)
Derived from icm-board's _system/knowledge/positioning.md (Phase B); Jamie edits after. Do not touch lib/services.ts ids, lib/problems.ts ids, or the contact action's service field — they are load-bearing into biz.clients.service.

hero: keep the headline; sub-headline gains the free look ("Every project starts with a free look at how you work today. No pitch, no invoice."); primary button Get a free look → /start; secondary unchanged.
problems.aiAside: "Not sure AI is even worth it for you? Get a free look — I'll tell you what belongs to software, what belongs to a person, and what isn't worth building."
howItWorks: three steps — Look, then sort (a call, then a one-page look at how you work: what could run itself, what needs a person, what's worth an assistant, what not to build) · Build what makes sense (fixed scope, fixed price, three options, the person who builds it on the call) · Hand it over, governed (you own the code, the accounts and the repository — with its own way of working inside it, so your team or any developer can carry on).
faq: "What will it cost?" → no rate: "Most work is a fixed price for the scope, with three options so you pick what fits. It starts with a free look, and for larger or messier systems a short paid diagnostic first — credited against the build."; remove contact.rateLead/rateAmount/rateTrail and the rate box in components/sections/contact-section.tsx; the meta description loses nothing it needs.
tech: principles gain a fifth — A method you can read: "Built on the Model Workspace Protocol (Van Clief & McDermott, 2026): the repository carries its own stages, gates and records as plain files, so the process is auditable and yours." Name and reference exactly as positioning.md states them.
outcomes (unrendered today): leave. All three locales; French and Portuguese in the same register as their existing copy.
E7 Referral site — websites/sellers-site/messages/{en,fr,pt}.json, lib/referral-schema.ts
Every €200 becomes €500 (packages.landing.price "from €500", howItWorks step 3, whatYouSell intro, objections "too expensive", faq "what can I quote", earningExamples first row €500 / €50, pitch where it names a price); referral-schema.ts budgetOptions second value → "~€500 — landing page" (keep the old string accepted on read for rows already stored — a one-line map where the value is displayed). whatYouSell leads with the free look as the thing to refer ("Know a business drowning in admin? Send them for a free look — no cost to them, no sell from you; if it turns into work, your 10% applies"), then the landing page at the floor, then "anything bigger, introduce me". pitch page: the first step becomes the free look. Three locales.

E8 createClientRepo
No code change. Confirm in the PR body that ConvertFlow's missing-repo gap already nudges at active (§2); the kickoff contract in icm-board is where "at signature by default, earlier on request" is written.

Proof for Phase E: the PR opens against main with the checklist below in its body; CI is green; no local build, lint, typecheck or test was run. In the PR body: the operator steps (token scope for icm-board writes if needed; setting deal_slug on the existing rows that have a folder — list the ten mappings from Phase C; the referral-schema value change; that 0024 applies on merge). Note what you verified by reading only.

Commit(s) on that branch: Rework E1: deal_slug and support_minor · E2: deal reader, stage chip, badge, prefill · E3: forms from icm-board, answers snapshot to the deal folder · E4: /start intake form · E5: pick-up verb · E6: portfolio copy from positioning.md · E7: referral site at the floor, the free look.

Phase F — sweep, decisions, wrap (icm-board)
The profile-wording sweep: read .icm/intake/triage/profile-wording-sweep.md; every file it lists is touched by Phases A–D — confirm none of them still asks anyone to declare, choose or check a profile; remove - profile: intake from this repo's .icm/CONTEXT.md; then git mv the stub to .icm/intake/triage/_done/ with a line > Done in the 2026-09-22 rework (D24–D26), <commit>. If any listed file is untouched, leave the stub open and say which.
.icm/project.md: D23 (from Phase A, as the agency brief specifies) and D24, D25, D26 verbatim from §1 of this directive, each with Supersedes filled (D24 supersedes D5's "deal artifacts … copy into the client repo at kickoff" only in what may be copied, and the first-round "repo at first reply"; D26 supersedes TICKETS.md's "## Prompt alone is the pick-up contract"); the Features table rows for the sell/start workspaces updated ("rewritten 2026-09-22, unproven"); a run-log row for this session naming both PRs and every SKIP (missing tools, absent brief).
.icm/docs/: confirm the design brief is at .icm/docs/2026-09-22-icm-board-rework-brief.md (Jamie placed it; commit it if untracked); this directive is saved beside it as .icm/docs/2026-09-22-rework-master-directive.md; write .icm/docs/2026-09-22-rework-verification.md in the shape of 2026-09-18-icm-refactoring-verification.md: what changed where, every proof's RESULT: line, where the directive's text was not followed literally and why, what is open.
Untouched, by design: .icm/today.md; every repo under projects/ except jamienisbet; sustentus's local branch; remi-ai #105; any token, panel or Vercel setting; the estate rollout of Phase A/D additions.
Open the icm-board PR from claude/rework-deal-workspace-2026-09-22 to main with a body that lists: the phases and their commits, the validate-deal.sh --all results per engagement, the sustentus dry-run line, the operator steps (install pandoc / ffmpeg / whisper.cpp if absent; Q22–Q24; house.docx; the Drive parent folder; fill remi/private/terms-sheet.md), and the canonical-asset drift every repo will now report (ticket-craft, intake/README.md) as the D7 rule working. Never enable auto-merge. Do not subscribe to PR activity.
Commit: Rework F: profile wording swept, D23–D26, verification report.

4. Definition of done — the whole directive
Both PRs open, CI green on each, nothing merged by you.
_system/scripts/self-check.sh passes in CI; every new script has the house header (what it does, what it never does, Usage:, Verdict:) and ends in one RESULT: line.
Phase A's §8 proofs from the agency brief all recorded; two consecutive icm-sync.sh --dry-run projects/sustentus runs list the same files; nothing applied anywhere.
validate-deal.sh --all runs clean to a RESULT: per engagement; /client's cold read of all twelve folders is written out in the run log.
The three forms parse under forms.ts's grammar (scratchpad proof, not committed).
process-raw.sh handles the synthetic wav (SKIP or a transcript) and the manifest is valid JSON.
new-run.sh --dry-run on a synthetic overlapping spec prints the [WARN] overlaps line and still ends RESULT: DRY-RUN.
grep -rn "profile" workspaces _system/contracts .claude AGENTS.md .icm/CONTEXT.md returns no line that asks for a profile to be declared, chosen or checked.
No file under projects/ other than projects/jamienisbet differs from its main; git -C projects/sustentus status and git -C projects/remi-ai status are exactly what they were at the start.
No secret, token, address, channel id or rate appears in any T file; the €120 anchor appears only in _system/knowledge/pricing.md and the deal folders' private/.
No local build, lint, typecheck, test or format ran in either repo.
5. Where this directive may be departed from
Where a file you open contradicts this directive with a reason recorded in it (a decision row, a Why line, a header comment), stop and weigh it: the repo's own recorded reason wins for that file, and the departure is written into the verification report with the two texts side by side. Where the directive is silent, the estate's contracts decide. Where neither says, the smallest change that keeps every proof passing is the right one, noted for Jamie.

End of master directive — ready for a local session at ~/Apps.