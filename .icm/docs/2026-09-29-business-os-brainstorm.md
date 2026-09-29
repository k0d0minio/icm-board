# The business above the tickets — analysis and the questions to answer first

*Brainstorm session, 2026-09-29, cloud, read-only over this repo (no `projects/` on disk).
Jamie's ask: "how do I organise and track the large-picture tasks of my business — customer
interactions, negotiations, project research, template-improvement research — and make
icm-board handle a lot more, towards an autonomous system working for the business from this
folder. Do the research, analyse the current setup, and give me a long list of questions."
Read: `AGENTS.md`, `CONTEXT.md`, `_system/README.md`, every contract, the knowledge layer,
the five skills and their stage contracts, the hooks, the register (D1–D48, run log), the
open and archived intake, every `DEAL.md`, `_system/AUDIT.md`, the 2026-08-30 estate
analysis, the 2026-09-22 master directive, the agency brief, the 2026-09-26 audit, and the
Claude Code docs on routines, memory, skills, hooks and connectors (§4). Nothing here is a
decision; §5 is the list. Answer inline under each question — the questionnaire pattern
`_system/setup/questionnaire.md` already uses — and a follow-up session distributes the
answers into contracts, decisions and stubs.*

## 1. What the system handles today, and what it does not

Three kinds of work exist in this business. Two have a home; the third is what this
session is about.

| Kind of work | Home | State of the home |
|---|---|---|
| **Code work, per repo** — a feature, a bug, a release | the repo's `.icm/` (pipeline, `/setup`, `/pipeline`, the board) | complete and converging; 48 decisions, every pipeline repo in sync on 2026-09-29 |
| **Deal work, per relationship** — intake → agreement → kickoff | `workspaces/sell/` + `start/` as stage contracts; `workspaces/deals/<repo>/` as Layer 4 | rewritten 2026-09-22; eleven folders, **all `- source: adopted`** — no deal has yet entered at `01_intake` and walked forward; the register still says "unproven" |
| **Everything else** — research, template improvement, negotiation prep, follow-ups, the operator's own professional admin | **none** | happens anyway, in three overflow places (below) |

### 1.1 Where the third kind is leaking today

The evidence that a high-level tracker is missing is that one already exists by accident, in
three places none of which was designed for it:

1. **`.icm/docs/` is the real research and directive shelf.** 23 files since 2026-08-26 —
   directives, verification reports, analyses, an audit, a brainstorm — with no index, no
   status, no expiry and no link from any ritual. The pattern of the last five weeks is
   visible in the run log: **Jamie writes a directive, one session executes it, a
   verification report lands beside it.** That is a *project* shape (a brief, a build, a
   proof), and the estate has no grammar for it; it is not a stub, not a deal, not a run.
   The register's own open question ("should icm-board hold the estate `.icm/docs/`
   research?") has been open since August.
2. **`.icm/intake/` here carries work that is not about this repo's machinery.** The
   contract says a ticket here is "about this repo's machinery"; `design-system-skills` is a
   research programme with a `complexity: research` stub squeezed into the stub format
   (eight questions, a report as the deliverable, a proposed decision as the acceptance).
   It works, but the format fights it: no place for findings-so-far, sources read, or a
   "this changed my mind" line.
3. **`DEAL.md → ## Log` is the customer-interaction tracker.** Append-only prose per client
   ("Jamie has chased a couple of times; no answer yet"). It is honest and it is the right
   *record*, but nothing reads it across clients: there is no view of "every relationship
   waiting on me", "every quote expiring this month", "every chase older than a week". D24
   puts the *next action* in Neon and the dashboard; the folder cannot say what is due, and
   the dashboard cannot say why.

Two more facts shape the design space:

- **`/day` never became a habit** (the 2026-08-30 analysis, still true: `today.md` reads
  "not yet planned"; the desktop `estate-housekeeping` routine runs only steps 1–2 and stops
  at the gate). The one planning ritual describes a terminal-first evening the operator does
  not live; he plans board-first, on the phone. Any new ritual that repeats that shape will
  meet the same fate.
- **Scheduled automation has been a want since July with no vehicle** (AUDIT #8; the
  `estate-heartbeat` stub dropped 2026-08-28). The only thing that runs unattended is
  `self-check` in CI. Meanwhile this very session has Gmail, Google Calendar, Google Drive,
  Slack, Vercel, Neon and Resend connectors attached — none of them is named by any
  contract, and the doctrine ("no outbound action leaves a session") has never had to say
  what it thinks of *reading* email.

### 1.2 The doctrine that any answer has to live inside

These are settled and this session does not reopen them; the questions in §5 ask only
where their edges are.

- **Never build an orchestrator** (D3, D11). Sessions describe, check, draft, prepare;
  Jamie drives. D11 already carved out "a repo's deterministic one-job scripts and post-merge
  CI"; D25 carved out "a write to the operator's own Drive". The next carve-outs — a
  scheduled *read*, a drafted reply, a reminder — need the same explicit treatment or they
  will be made by accident.
- **One home per fact** (D24). Relationship *state* is Neon's; *words and documents* are
  git's. A task tracker is state. The `business-state` epic that would have let sessions
  write Neon at the gate was dropped on 2026-08-28 ("not worth building the API chain right
  now; re-cut from evidence if the recording gap starts hurting").
- **Tickets live next to the logic they describe** (D2). Dashboard work goes to
  `jamienisbet`; marketing and content production stay there too (D8).
- **The folders are the orchestration; status is positional.** Whatever the new unit of
  work is, its state should be readable from where its files sit, not from a field.
- **Layer 0 ≤ 90 lines, stage contracts ≤ 80, references ≤ 200; thin routers; the stage
  contract is the process.** Adding "way more skills, commands and configuration" has to
  respect the budget the terse-sessions work (D40) just paid for.
- **Half the estate is invisible to a cloud session** (`projects/` is gitignored) and **the
  repo is public until the end of September** (AUDIT P0). Anything that puts email text,
  negotiation positions or personal admin into git is blocked on the flip.

### 1.3 Fidelity notes found in passing (not this session's work)

Parked here so they are not lost; each is a one-line fix or a stub.

- `sell/01_intake/CONTEXT.md` line 4 and `CLIENTS.md` still claim a `new` lead "mints a
  Reply-within-2-days todo". The 2026-08-30 analysis (F1) found nothing implements it; it is
  still claimed.
- The register's Features table still lists `/project` among four shipped commands;
  `deals/README.md` § Adopted deals still says "the doorway for its work is `/project`".
  Both predate D48.
- `.icm/docs/` has a `.gitkeep` and 23 files but no `README.md`; nothing says which are
  live (the agency brief is cited by contracts) and which are history (the directives).
- The questionnaire's done log and `voice.md` still carry the 2026-08-26 open slots (a real
  reply, a real proposal paragraph, a real outreach message). The next real deal that walks
  `01_intake` is the moment to fill them, and nothing reminds anyone.

## 2. The shape of the missing unit

Whatever it is called, the missing thing sits **above a ticket and beside a deal**: a piece
of business work with a goal, a brief, a duration of days to weeks, findings that
accumulate, decisions that come out of it, and stubs it spawns into whichever repo owns the
logic. Four shapes fit the existing grammar; the questions in §5.1 decide between them.

| Shape | What it is | Fits | Costs |
|---|---|---|---|
| **A. A fourth workspace** — say `workspaces/run/` (rituals) with Layer 4 at `workspaces/initiatives/<slug>/` | one folder per initiative: `brief.md`, a dated `log.md`, `findings/`, `decisions.md`, the stubs it spawned named by path; stage positional (which files exist) | the five-layer grammar exactly; deals and initiatives become siblings; research, negotiation prep and template programmes all fit one folder shape | a new workspace to write and keep under the caps; a new thing for the board to read |
| **B. Widen `.icm/intake/` here** — a `kind: research \| business \| machinery` line on scopes | cheapest; the board, hygiene and `/day` already read it | the stub format fights research; D2's spirit ("tickets about this repo's machinery") bends; no home for findings | every stub stays a unit of *work*, never a record of *learning* |
| **C. Neon-first** — initiatives and follow-ups as rows, shown in the dashboard; git holds only the documents | D24 exactly (state in Neon, words in git); phone-first by construction | needs the dashboard write path the business-state epic dropped; every new field is a migration in `jamienisbet`; cloud sessions cannot see it without an API | |
| **D. A + C** — folders for the words, Neon rows for the dated state, the dashboard reads both | the honest reading of D24 applied to this work; the board becomes the one surface | two homes to keep from mirroring each other, which is the failure D24 exists to prevent | |

**Provisional lean, to sharpen the questions, not to decide:** A for the words (an
initiative folder is a deal folder without a client), with the dated *next action* living
wherever Jamie will actually look at it on a phone — which today is the dashboard, so D. B
is the fallback if the appetite for another rework is low; it can be done this week and
migrated later.

## 3. Candidate additions, to react to

A list to say yes, no or later to — each line names the surface it would need and the
doctrine question it raises. None exists; none is proposed as a set.

| Candidate | Would do | Needs | Doctrine edge |
|---|---|---|---|
| `/inbox` | read Gmail threads and the calendar for the week; match senders to deal folders; propose log lines and next actions; draft replies into the folder | Gmail + Calendar connectors; a sender → client map | a scheduled *read* of the operator's own inbox — outbound stays human |
| `/followup` | every relationship waiting on Jamie or on the client, with age; quotes near expiry; chases due | reads every `DEAL.md` log + the dashboard rung | none — pure read; but the *due date* needs a home (folder or Neon) |
| `/negotiate <client>` | a stage-shaped ritual over `private/negotiation.md`: positions, concessions, the walk-away, precedent from other deals, the next message drafted | the repo private again; `03_quote`'s precedent rule extended | positions in git — blocked on the visibility flip |
| `/research <topic>` or `/initiative` | open an initiative folder from a one-line brief; run it as a ritual (sources pinned by URL, SHA and date; findings with the ✅ confident / ⚠️ needs-confirmation discipline from the contabilista work; a proposed decision at the end) | the §2 shape decided | none |
| `/reference add <url or file>` | the intake for Jamie's saved materials: capture, summarise, file under an initiative or the knowledge layer, or drop with a reason | a drop folder (`raw/` exists for client material; nothing for the operator's own) | none |
| `/week` | the ritual `/day` was meant to be, at the cadence Jamie keeps: what moved, what is due, the ≤10 for the week, the initiatives' one-line status | the board, the deal logs, the initiative logs | none — but it must be reachable from the phone |
| `/brief` (morning) | a read-only digest: today's calendar, open follow-ups, CI red anywhere, PRs waiting on Jamie, quotes expiring | connectors + `gh`; a Routine to run it unattended | a scheduled session that reads and posts to Jamie only |
| `/retro` for business processes | D27 gives code runs a retrospective; nothing does it for a deal that closed or was lost — what the stage contracts got wrong, folded back into Layer 3 | `08-handover.md` or an `ended` row as the trigger | none |
| `/money` | read Stripe and Neon: invoices outstanding, retainers due, the *in play* total against the deal folders | Stripe connector (not yet authorised in this session) | read-only; invoicing stays human |
| `/estate` (cloud) | the conformance walk over the GitHub API for the repos a cloud session cannot see on disk | the API walk `icm-check.sh` retired on 2026-09-26 | re-litigates the "disk is the roster" ruling |

## 4. What the harness can and cannot do for this (verified against the docs)

Filled from the Claude Code documentation read this session; each line is a constraint the
questions in §5.6 lean on.

- **Scheduled execution.** Cloud *Routines* (`code.claude.com/docs/en/routines`) run
  unattended on Anthropic's infrastructure with no permission prompts, on three triggers: a
  schedule (hourly, daily, weekly — **one hour minimum**), an HTTP endpoint (a webhook any
  service can POST to), or a GitHub event (PR opened, merged, labelled; releases; with
  filters). Each firing starts a fresh session or wakes a named one; the result is a
  session transcript, plus push or email on completion. A cloud session sees only what is
  in the repository and the connectors attached to it, so any routine over the estate reads
  GitHub, never `projects/`. *Desktop scheduled tasks* run on Jamie's machine with the disk
  in view, down to a one-minute interval, but only while the app is open (missed runs catch
  up). `/loop` repeats a prompt inside one live session and is not unattended.
- **Memory.** Auto-memory lives at `~/.claude/projects/<project>/memory/` — per repo, per
  machine; it does not travel to the cloud or between repos. Durable shared knowledge is a
  committed file — which is what this repo already is. `.claude/rules/*.md` with `paths:`
  scoping loads only when matching files are touched, which is the lever for shrinking a
  Layer 0 that is over the 90-line cap.
- **Skills.** The name and description of every skill the repo carries are listed to every
  session; the body loads on use. `allowed-tools` may name connector tools by their full
  `mcp__…` name, so a skill can be scoped to "read Gmail, nothing else". Each skill added
  here costs a line of context per session forever; the cap on count is practical, not
  documented.
- **Connectors.** Gmail, Calendar, Drive, Slack, Stripe, Notion and the infrastructure
  connectors are per account, reachable from cloud sessions and routines when attached, and
  gated by the permission list like any tool. A skill can call them; a hook can only fire
  *on* them (a `PreToolUse` matcher on `mcp__Gmail__.*` could block a send by rule).
- **Hooks.** Thirty-odd events. A hook may inject `additionalContext` on `SessionStart`,
  `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop` and `SubagentStop`, and may block
  on `PreToolUse`, `UserPromptSubmit`, `Stop` and `PreCompact`, never on `Notification` or
  `SessionEnd`. What exists here already uses the three that matter.
- **Events into a session.** A cloud session can subscribe to one PR's activity or expose
  a webhook URL that wakes it; routines add the GitHub and HTTP triggers above. The estate's
  own rule (pr-conventions) forbids PR subscriptions on principle; a webhook from Neon,
  Stripe or a form into a session would be a new kind of trigger the doctrine has not
  considered.
- **Beyond the harness.** The Agent SDK (self-hosted) and Managed Agents (Anthropic-hosted,
  beta) exist for a standalone agent with its own tools and long-lived sessions. Neither is
  warranted while every ritual is a session Jamie or a routine opens in this repo; they
  become relevant only if the dashboard itself should run an agent.

## 5. The questions

★ marks the twelve that unblock the design; answer those first if time is short. Number
your answers `Q<n>:` so a session can distribute them.

### 5.1 The unit above a ticket

- **Q1 ★** What do you call the thing between a ticket and a deal — an *initiative*, a
  *project*, a *programme*, a *thread*? Pick the word you would say out loud; it names the
  folder.
- **Q2 ★** Of the four shapes in §2, which do you want — A, B, C or D — and is another
  rework acceptable this month, or should the first version be the one that can land in a
  day (B)?
- **Q3** What must an initiative folder contain on day one for you to trust it: a
  one-paragraph brief, a "done looks like" sentence, a deadline, a budget in sessions or
  euros, the stubs it will spawn, none of these?
- **Q4** How does an initiative end — a decision recorded in a register, stubs cut into a
  repo, a knowledge file amended, "dropped with a reason"? Which of those must be true
  before the folder is archived?
- **Q5** Does an initiative get a positional stage like a deal (brief → research → decision
  → cut) or only a log? If stages, name them.
- **Q6** Where do initiatives live: beside deals under `workspaces/`, under `.icm/` here,
  or in `jamienisbet` next to the dashboard that would show them?
- **Q7** Should the 23 documents already in `.icm/docs/` be sorted retroactively into
  initiatives, or left as history with an index? Which of them are still *live* inputs to a
  contract?
- **Q8** Is an initiative allowed to span repos (a template change plus a dashboard change
  plus a deal), with stubs cut into each? If so, the folder points at them by path — is a
  pointer enough, or do you want the board to roll them up?
- **Q9** How many initiatives can be open at once before the list is a lie — 3, 5, 10?
  (The today cap is 10 stubs; this is the same question one level up.)

### 5.2 Customer interactions and follow-ups

- **Q10 ★** What does "handle customer interactions" mean to you concretely — logging what
  was said, knowing what is owed and by whom, drafting the next message, noticing silence,
  all four?
- **Q11 ★** Where should *the next action and its due date* for a relationship live: the
  Neon row (D24 as written), the deal folder (a `- next:` line in `DEAL.md`), or both with
  the dashboard reading the folder? This is the one-home-per-fact question applied to
  follow-ups; today it is nowhere you can list across clients.
- **Q12** May a session read your Gmail and Calendar? If yes: every session, only a named
  ritual (`/inbox`, `/brief`), or only a scheduled one? What must it never do with what it
  reads (quote client text into git, name third parties, store attachments)?
- **Q13** Should client emails, or summaries of them, be filed into the deal folder's `raw/`
  or `## Log`, given the repo is public until the flip and a deal folder is committed?
- **Q14** What counts as "stale" per rung — the dashboard says 7 days for `new`/`talking`.
  Is that right for a quote awaiting an answer, for a client mid-build, for a delivered
  client you want to keep warm?
- **Q15** For a returning or delivered client with `- engagement: none`, what is the
  relationship-keeping rhythm you want tracked, if any — a quarterly check-in, a birthday, a
  renewal date?
- **Q16** The 2-day reply todo that `CLIENTS.md` promises does not exist. Build it (a
  dashboard feature in `jamienisbet`), replace it with a `/followup` read over the folders,
  or delete the claim?
- **Q17** Which channels do clients actually reach you on — email, WhatsApp, phone, in
  person? For the ones no connector can read, how do you want to capture them: a one-line
  `/client <name> log "…"`, a voice note dropped into `raw/` and transcribed, nothing?
- **Q18** Should a session ever *draft* a reply into a client-facing channel's draft folder
  (a Gmail draft, never sent) rather than into the deal folder? That is one step closer to
  the line than D25's Drive write.

### 5.3 Negotiations

- **Q19 ★** What does a negotiation need tracked that `private/negotiation.md` does not
  already hold: your floor and walk-away per deal, the client's stated constraints, each
  offer and counter with dates, concessions traded, the deadline, the precedent from other
  deals? List what you actually reach for mid-negotiation.
- **Q20** Is negotiation a *stage* (between `03_quote` and `05_agreement`) or a *lane* that
  can run at any stage, including inside a retainer when scope grows?
- **Q21** Should cross-deal precedent be a computed view ("what did comparable deals settle
  at") over every `private/pricing.md`, or is reading two or three folders by hand enough?
- **Q22** Negotiation positions are the most sensitive text in the estate. Do they stay in
  git after the flip to private, or move to somewhere never tracked (Drive, a local-only
  folder), with git holding only the outcome?
- **Q23** Do you want a rule that a session never proposes a number below the floor or the
  anchor, or only that it flags when you do?

### 5.4 Research

- **Q24 ★** Three kinds of research were named: *project* research (for a client build),
  *template-improvement* research (tools, methods, the ICM template itself), and *market or
  business* research. Are they one folder shape with a `kind:`, or do they belong in three
  places (the repo's `.icm/docs/`, an initiative here, `jamienisbet`)?
- **Q25** What makes a research finding trustworthy to you: a URL and date, the upstream
  commit SHA, a quoted passage, a measured number, your own confirmation? The contabilista
  docs invented ✅ confident / ⚠️ needs confirmation; adopt that discipline for all research?
- **Q26** Does research expire? Should a finding carry a re-check date, and should a ritual
  list findings past it?
- **Q27** How does research become action — a proposed decision in the register's shape
  (the `design-system-skills` stub already asks for a "proposed D46"), a stub, an amended
  knowledge file? Must every research initiative end in one of those, or may it end in
  "learned, no action"?
- **Q28** Where do your saved materials live today — browser bookmarks, Drive, a notes app,
  screenshots, PDFs, repos you starred? Roughly how many, and do you want them imported
  once or captured going forward only?
- **Q29** Should there be a drop folder for the operator's own material — the equivalent of
  a client's `raw/` — with `process-raw.sh` extracting text and a ritual that files or
  drops each item? Where: `workspaces/inbox/`, `_system/reference/`, an initiative's
  folder?
- **Q30** Which of your reference materials should become Layer 3 (the knowledge layer, a
  sell reference, a contract) rather than staying research? Who decides — you at review, or
  the session proposes?
- **Q31** For template-improvement research specifically: should every proposal be judged
  against a written bar (token cost, maintenance cost, doctrine fit, evidence it worked on
  one repo) before it becomes an epic? Write the bar, or let the research stub carry it each
  time?

### 5.5 The template-improvement programme

- **Q32 ★** How much of your week do you want going into the system itself versus deals and
  builds? A ratio or a cap turns "template improvement" from a drift into a budget.
- **Q33** The D33 template-change flow handles *fixes* a repo asks for. Ideas (new skills,
  new plugins, new tools) have no intake. Do they enter as triage stubs here, as an
  initiative, or as reference items awaiting a research pass?
- **Q34** Should each template improvement be proven on one repo before rollout, as
  `design-system-skills` plans and `unify-setup-project` did? Make it a rule?
- **Q35** Which of the harness features in §4 do you want the template to lean on next:
  `.claude/rules/` with path scoping (to shrink Layer 0), plugins (to package the pipeline
  skills), routines, MCP connectors declared per repo?
- **Q36** Do you want a changelog for the template itself, so a repo's `template-version`
  stamp maps to "what changed since" — or is the run log enough?

### 5.6 Autonomy and the orchestrator line

- **Q37 ★** Finish the sentence for each: *A session may, without asking me, …* (read /
  draft / remind / schedule / write to my own storage / post to a channel only I read /
  send). *A session may never …*. The answers become the D49 that D3, D11 and D25 have been
  circling.
- **Q38 ★** Which of these do you want to happen while you are asleep: a morning brief in
  Slack or email; a weekly estate digest; a follow-up list; CI-red and PR-waiting alerts;
  the conformance walk; nothing until you open a session?
- **Q39** Where should unattended output reach you — Slack DM, email, a push notification,
  a file the next session opens, the dashboard? One channel or several?
- **Q40** Cloud or desktop for scheduled work? Cloud sees only GitHub and connectors; the
  desktop sees `projects/` but only when the machine is on. Which estate reads must be
  daily, and can they be answered over the GitHub API?
- **Q41** What is a scheduled session allowed to *cost* per day, in tokens or euros, and
  should it refuse to run when the estate has not changed?
- **Q42** Should a scheduled session ever *write*: a log line into a deal folder, a triage
  stub, a `today.md`? Or only files outside git and messages to you?
- **Q43** Webhooks into a session (a Stripe payment, a Neon form answer, a Vercel deploy)
  are now possible. Do you want any of them to wake a session, and to do what — or is
  "events are not a verdict" the answer here too?
- **Q44** The "no PR subscription" rule exists because Vercel bursts are noise. Does the
  same reasoning cover email — is an inbox read once a day, or on arrival?

### 5.7 Cadence and rituals

- **Q45 ★** What rhythm do you actually keep — a morning look at the phone, an evening
  wrap, a Friday review, a monthly close? Name the moments; the rituals attach to them or
  they die like `/day` did.
- **Q46** Should `/day` be retired in favour of `/week` plus a morning brief, kept as the
  reconcile engine that other rituals call, or given the board-shaped launcher the
  2026-08-30 analysis proposed?
- **Q47** Phone or terminal for planning? If phone, the dashboard is the surface and every
  ritual needs a deep link or a routine; if terminal, the skills are enough.
- **Q48** What does a weekly review need to show in under a minute: deals moved, money
  in play, follow-ups due, stubs done and cut, initiatives' one-liners, CI health, cost?
  Rank them.
- **Q49** Do you want a monthly close — invoices against agreements, retainers billed,
  economics per client, the knowledge layer's open slots — as a ritual with a checklist?

### 5.8 Skills, commands and agents to add

- **Q50 ★** From §3, mark each: **yes now**, **later**, **no**. Add any missing.
- **Q51** Should the new skills be thin routers over stage contracts (the house shape) or
  self-contained skills, given they will mostly run here and not be seeded to repos?
- **Q52** Which model tier for each: a morning brief on Haiku, research on the frontier
  model, follow-up drafting on Sonnet? `select-model.sh` routes code stages; extend it to
  business rituals?
- **Q53** Should any of these be *agents* (read-only, forked, one job — like `project-lens`)
  rather than skills: an inbox reader, a precedent reader, a reference summariser?
- **Q54** OpenCode parity: every skill here is Claude Code's. Do the business rituals need
  to run in OpenCode too, or is that only for code work on cheaper models?

### 5.9 Data homes, the dashboard and one-home-per-fact

- **Q55 ★** Would you accept a small, deliberate write path from a session into Neon
  (a task, a next-action date, an interaction stamp) if it is gated by you confirming in
  chat? The `business-state` epic was dropped for cost; the follow-up question re-raises it.
- **Q56** What should the dashboard show that it does not: initiatives, follow-ups by age,
  quotes expiring, research awaiting your decision? Each is a `jamienisbet` ticket.
- **Q57** Does the dashboard already have a task table (`createTask` exists in a manual
  form)? Should business tasks use it, or is Neon the wrong home for the operator's own
  work?
- **Q58** Any third home you use daily that the system should read — Notion, Obsidian,
  Apple Notes, Drive docs, a paper notebook? Import, integrate, or leave alone?
- **Q59** When does the repo flip to private, and does anything in this brainstorm wait for
  it? (The `private/` re-track stub is blocked on it; negotiation tracking would be too.)

### 5.10 The scope of "everything in my professional life"

- **Q60 ★** List the domains you mean: accounting and the contabilista, tax and compliance
  dates, invoicing and cash, insurance and legal, learning and certifications, speaking and
  content, tools and subscriptions, subcontractors, your own health of workload. Which are
  in, which stay out, which stay in `jamienisbet`?
- **Q61** D8 put marketing and content production in `jamienisbet`. Does "customer
  acquisition research" (the unestablished AI-SME channel) belong there or here as an
  initiative?
- **Q62** Compliance dates were once `biz.compliance_dates` rows surfaced in the dashboard.
  Is that still live, and should a ritual read it?
- **Q63** Should the operator's own recurring obligations (VAT, IRS, hosting rebills,
  domain renewals) be tracked here at all, given the 2026-08-30 finding that obligations
  are state and belong in Neon?
- **Q64** Do you want a place for professional relationships that are not clients —
  referrers, the Mafra network, the accountant, other developers? A `contacts/` workspace,
  or Neon rows with a type?
- **Q65** Learning: do you want the system to track what you are studying and propose what
  to read next from the reference shelf, or is that noise?

### 5.11 Boundaries and security

- **Q66 ★** What may never enter git, even private: client email text, phone numbers,
  negotiation positions, identity documents, your own financials, health? The deal folder
  rule covers secrets and contact details; the new work needs its own list.
- **Q67** May a cloud session hold connector access to your mailbox and calendar by
  default, or only when you attach it for a named ritual?
- **Q68** Third parties appear in email (a client's accountant, a partner). What is the rule
  for naming them in any file?
- **Q69** Should any new folder be encrypted at rest in git (git-crypt, age) rather than
  relying on the repo being private?

### 5.12 Measurement and learning

- **Q70** What would tell you in three months that this worked — deals moving faster,
  fewer dropped follow-ups, hours saved per week, research turning into shipped template
  changes, lower token cost per client? Pick the two you would actually check.
- **Q71** Should business rituals keep a `usage.md` like runs do, so `run-economics.sh` can
  say what the *business* side costs per month?
- **Q72** D27 folds a code run's fixed errors back into rules. What is the equivalent for a
  deal or an initiative — a lessons line at close that edits the reference file that caused
  the miss? Make it mandatory, as `07_kickoff` already does?
- **Q73** Do you want the system to measure its own honesty — the "aspirational docs richer
  than the running system" failure — with a recurring fidelity pass like the 2026-08-30 one?

### 5.13 Sequencing

- **Q74 ★** What is the one thing you want working in two weeks? Everything else in this
  list is ordered behind it.
- **Q75** Is there anything in the current system you want to *stop* maintaining to make
  room — a ritual, a script, a contract that has not earned its keep?
- **Q76** Who else will ever read this repo — a future employee, a subcontractor, a client
  auditing the method? The answer decides how much the new contracts explain versus route.
- **Q77** Do you want the follow-up session to produce a directive in the shape of the
  2026-09-22 master directive (one session, phases, commits per phase), or a normal epic of
  stubs walked over several sessions?

## 6. What happens with the answers

A follow-up session reads this file with the answers inline and does three things, in
this order: records the decisions in `.icm/project.md` (D49 onward — the autonomy line
first), writes or amends the contracts the answers imply (a fourth workspace, an amended
`WORKSPACES.md`, a `.icm/docs/README.md`), and cuts the work as scopes here and in
`jamienisbet` where the dashboard is touched. Nothing in §3 is built before Q37 and Q2 are
answered.
