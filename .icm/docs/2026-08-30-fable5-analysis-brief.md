# Fable 5 analysis brief — the icm-board estate system

> Authored 2026-08-30 by a Claude Opus 5 session that read the whole control layer,
> both ticket contracts, all four commands, all six scripts, the template library, every
> stage contract, and `jamienisbet/websites/admin-dashboard/lib/tickets.ts` end to end,
> then interrogated Jamie over two rounds. **Uncommitted.** Paste the body below into a
> Fable 5 session opened at `~/Apps`.

---

You are analysing a working system for the person who built it. He is not asking you to
admire it. He is asking you to find what is missing, what needs improving, and what needs
removing — and he has told you exactly which lens to use.

## Who you are working for

Jamie Nisbet. Solo software engineer and AI consultant, Mafra, Portugal. He runs ~23
repos: a handful of live products and clients, thirteen finished build-once client sites,
and this control repo. He works alone. **Every rule in his system has to earn its
maintenance cost against one person's attention** — that constraint outranks elegance and
is the reason several obvious "improvements" are wrong here.

His stated end state is that this system eventually handles everything — legal advice
specific to his business, financial advice, marketing, growth. **This round is not that.**
This round is about the machine that produces output: codebases, features, designs, AI
systems.

## Your posture

You are not a consultant delivering a maturity model. You are a colleague who has been
handed the keys to something that mostly works and asked where it lies to itself.

Three things follow:

1. **Read before you conclude.** A brief is not the system. Everything below is a map and
   a set of leads. Open the files.
2. **Verify the evidence handed to you.** The findings in §4 were gathered by another
   session in one pass. Several are load-bearing. Check each one before you build on it,
   and say plainly when one does not hold — being wrong in this brief is a better outcome
   than being echoed.
3. **Interrogate him.** §6 is not optional and not a formality. He expects to be asked
   hard questions and he answers them well. A finding you could have confirmed with one
   question, and didn't, is a finding you have to hedge.

---

## 1 · What the system is

`~/Apps` **is** the repo `icm-board`. It holds no application code and ships no product.
It is the business written down as an ICM system (Interpretable Context Methodology, Van
Clief & McDermott 2026 — the paper is at `_system/reference/icm.pdf`). The founding idea:
**the folder tree is the orchestration.** Markdown is the interface. There is a human gate
at every boundary.

### Five layers

| Layer | Files | Answers |
|---|---|---|
| 0 | `AGENTS.md` (`CLAUDE.md` is a one-line `@AGENTS.md` import) | Where am I? |
| 1 | `CONTEXT.md`, each workspace's `CONTEXT.md` | Where do I go? |
| 2 | `workspaces/*/stages/*/CONTEXT.md` | What do I do? |
| 3 | `_system/knowledge/`, `_system/contracts/`, each workspace's `references/` | What rules apply? |
| 4 | `workspaces/deals/`, and for deliver the estate repos themselves | What am I working with? |

Layer 3 is the factory — configured once, stable, internalised as constraints. Layer 4 is
the product — unique per deal or day, processed as input. The rule that keeps them apart:
*a reference file that names a real client is a Layer-4 artifact in the wrong folder.*

### Three workspaces, one number line

- `sell/` — `01_intake → 02_discovery → 03_quote → 04_proposal`. Once per deal.
- `start/` — `05_onboarding → 06_repo → 07_kickoff`. Once per won deal.
- `deliver/` — `project` · `day` · `conformance`. Forever, cyclically. Deliberately
  unnumbered: they are re-entrant rituals, not a sequence.

Sell and start share one number line because a deal is one story and its artifacts sort
chronologically in its folder.

### Four thin commands

`/client <name>` · `/project <repo>` · `/day [wrap]` · `/icm-check`. Each is 5–30 lines
and holds **no process** — it opens its stage's `CONTEXT.md` and follows it. **The stage
contracts are the process**, and there is deliberately no second narrative describing them.
Routing is dispatch-free: `/client` reads the deal's `DEAL.md` Stage row and lands itself;
the tables in `CONTEXT.md` are "for orientation, not dispatch."

Two agents back deliver: `project-lens` (one of seven analysis lenses per invocation) and
`ticket-scout` (in-flight work no ticket knows about).

### Six scripts

Each does one job, takes config from the environment (never `.env`), and prints exactly one
`RESULT:` line last on stdout.

| Script | Job |
|---|---|
| `icm-check.sh` | Every repo **on disk** vs the baseline + canonical assets. `--fix` seeds gaps, never overwrites. |
| `estate-conformance.sh` | The same question **over the GitHub API**, so it runs in CI where `projects/` doesn't exist. Reports only. |
| `tickets-board.sh` | The estate board. `--today` powers the SessionStart hook. |
| `ticket-hygiene.sh` | Read-only drift report + contract lint over every ticket. |
| `self-check.sh` | Holds icm-board to its own rules: links resolve, tickets meet the contract. |
| `pull-all.sh` | Pull every repo. |

The first two are a deliberate pair, not duplication: one severity model, two vantage
points. `GAP` = what `--fix` would seed; `warn` = never auto-fixed.

### Tickets

Re-founded 2026-08-28 on the sustentus model. Contract: `_system/contracts/TICKETS.md`.

- **Identity is the path.** A ticket is `<epic-slug>/<feature-slug>`; estate-wide,
  `repo · epic/slug`. No number series — `PREFIX-NNN` is retired.
- **Every stub belongs to an epic** (a batch cut from one intent, with a `breakdown.md`
  that is the single review surface) **or to `triage/`** (parked one-off findings).
  Nothing lives loose in `intake/`.
- **Status is positional.** No Status field, no vocabulary. Where a file sits is its state.
  Done is `git mv` into `_done/`. Dropped is the same move with a `> Dropped: <reason,
  date>` line. A completed epic archives whole. Nothing is deleted; no slug is reused.
- **`## Prompt`** must stand alone pasted into a fresh agent session at the repo root. It
  is the entire pick-up contract in `intake`-profile repos.
- **`.icm/today.md` in icm-board is the one home of the today flag** — ≤10 entries across
  the whole estate, rewritten wholesale by `/day`.

Profiles (`_system/contracts/PIPELINE.md`): `intake` (default) · `pipeline` (adds a run
spine: `stages/`, `lanes/`, `runs/`, gated PRs) · `pipeline-full` (deliberately not
templated; sustentus is its only instance) · plus an empty `.icm/dormant` marker for parked
repos.

### Templating

`_system/template/` is the canonical scaffold and Claude-asset library. Three rules:
**seed what's missing, never overwrite** · **report drift, never repair it** · **the repo
wins**. Template edits propagate only to repos fixed after the edit; there is no retro-sync,
deliberately.

### The dashboard

`projects/jamienisbet/websites/admin-dashboard` — a phone-first Next.js app over Neon
(`biz.*`) and Stripe. Leads, money, and `/tickets`: the estate board, **read-only by
decision D13**, reading each repo's `.icm/` from `main` over the GitHub API.
`lib/tickets.ts` (1,275 lines, unusually well-commented — read the header in full) runs
three cache clocks: discovery hourly (which repos exist / carry an intake), position every
60s (one recursive tree call per repo), content monthly (blob reads **by SHA**, which can
never go stale). Concurrency capped at 8 after a real outage where ~100 parallel requests
returned 403 across the whole estate. Every row is a **deep link** — `claude.ai/code/new`
(documented universal link, opens the app on a phone) and `claude-cli://open` (documented
terminal scheme) — with the ticket's `## Prompt` pre-filled. **The human sends it.** That
is what keeps the board read-only.

### The house rules that outrank everything

- **Never build an orchestrator.** The folders are the orchestration. Nothing advances work
  across a human gate; nothing triggers the next stage; no outbound action leaves a session.
  Decision D11 narrows this: a *project repo's own* deterministic one-job scripts, and CI
  acting only after a human-authorised merge, are **factory, not orchestrator**. icm-board
  itself drives nothing.
- **Gates are human checkboxes.** Read them; never tick them. No scripted exception.
- **CI is the source of truth.** Never run `build`/`lint`/`typecheck`/`test`/`format` or a
  dev server locally — push and read the checks. This is enforced by `opencode.json` deny
  rules and a global hook.
- **The repo wins.** Where a repo's own contracts conflict with the estate baseline, the
  repo is authoritative. **Sustentus is exempt outright** — its `.icm/` is the source this
  template was extracted from. The board reads it; the tooling never writes to it.
- **Adopt or stop.** Resolve an existing run, register, deal or ticket set; never fabricate
  one.
- **Edit the source, not the output.** The same correction made twice at the same stage is
  a Layer-3 bug — fix the reference file so every future run inherits it.
- **Tickets live next to the logic they describe.** A ticket about the dashboard is cut in
  `jamienisbet`, not here. Ticket-only commits go straight to `main`; code goes through a
  PR on a `claude/` branch.
- **No secrets in git, ever.** Deal folders record that access exists, never its value.

---

## 2 · What is already decided — do not relitigate

`.icm/project.md` carries decisions **D1–D15** with dates and supersessions. Read them
before proposing anything. The ones most likely to trip you:

- **D3 / D11** — the business processes returned as ICM *workspaces* (contracts + human
  gates), never a driver. The never-build-an-orchestrator rule survived.
- **D10** — the epic/stub/triage model, path identity, positional status, `today.md`.
- **D12** — Gen-3 *is* a template product, extracted from sustentus into tiered profiles.
- **D13** — **the dashboard board stays read-only** and reads both ticket shapes over the
  GitHub API, sustentus included. No sync, no second store. Jamie was asked directly in the
  interrogation whether read-only now chafes; **he said it does not.** Do not propose
  dashboard writes.
- **D14** — the clean slate: every legacy `PREFIX-NNN` ticket, open and archived,
  estate-wide, was purged rather than re-cut. This has consequences you will find in §4.
- **D15** — conformance gaps exit 0; only an unreachable check exits 2. "A always-red
  schedule teaches you to stop reading it."

`_system/AUDIT.md` records what is settled under **Done (don't re-litigate)** and what is
still open. Respect both columns.

Two more settled points from the interrogation:

- **`/project` coverage is deliberate.** It has written `.icm/project.md` in 2 of 23 repos.
  Jamie confirms this is on-demand by design — thirteen dormant build-once client sites
  will never need a register. **Do not propose a rollout.** Whether the *contracts* say so
  clearly enough is a different question, and a live one.
- **This round produces a report, not tickets.** See §7.

---

## 3 · What Jamie told the interrogating session

Answers, verbatim in substance. These are your brief's spine.

**On the board — what actually hurts (multi-select):**
> Read cost / staleness · Can't query across the estate · No history or metrics

He did **not** select "read-only chafes."

**If tickets moved to a database, what must stay true (multi-select — he chose all four):**
> The AI keeps direct file access · Git stays the source of truth · Repo-portability
> survives · Nothing new to maintain

**On `/project` running in only 2 of 23 repos:**
> Deliberate — on-demand only.

**What your analysis should optimise for:**
> **Fidelity — the system stops lying.** Docs match reality, registers exist, the board is
> true, drift is closed.

He explicitly did *not* choose throughput, leverage, or simplification. Weigh accordingly:
a simplification that closes a lie is in scope; one that merely trims is not the goal.

**What a working day looks like:**
> Both, split by mode. Board when deciding what's next; terminal when doing. **The handoff
> between the two is where friction lives.**

**If he cloned himself, which half he'd hand over:**
> **Ticket quality — sessions land wrong.** Stubs are too vague or too stale, so a session
> builds the wrong thing and he reworks it.

**On legal / financial / marketing / growth:**
> Audit whether the knowledge layer is already the seam. `_system/knowledge/` already holds
> services, pricing, voice, terms and stack with honest gaps. Ask whether legal/financial
> is just more of that, and what would break.

**Added mid-interrogation, unprompted — treat both as first-class constraints:**

> *"Take inspiration from the sustentus model of just needing to call pipeline new,
> pipeline build, pipeline release. It is practical, although for most of my other
> projects we don't need 3 stages per ticket."*

> *"Make sure your findings take into account that we want to operate within OpenCode as
> well as Claude Code."*

The second is a **cross-cutting constraint on every recommendation in this brief**, not a
topic of its own. Any mechanism you propose — a command, a check, a hook, a pick-up verb,
a launcher — must be answerable in both harnesses, or you must say plainly that it is
Claude-Code-only and what that costs. See §4h for where the estate stands today.

---

## 4 · Evidence dossier — verify each of these

Gathered in one pass on 2026-08-30. **Confirm before building on any of it.** Where a claim
does not hold, say so — a corrected brief is worth more than a confirmed one.

### 4a · Scale (verified)

- **123 open stubs across 8 of 23 repos.** 113 of them sit in three: agorasim 57,
  sustentus 28, dungeons-dragons 28. jamienisbet has 7; three repos have 1 each.
- **13 of 23 repos are dormant** (empty `.icm/dormant` marker).
- **All of agorasim's 57, dungeons-dragons' 28 and jamienisbet's 7 were added on
  2026-08-30** — the backlog was cut in bulk, days ago. Staleness is therefore not yet
  measurable from the data. Do not assert it; ask about it.
- **Zero stubs exceed the deep-link's 4,500-encoded-character cap.** That failure mode can
  be retired rather than designed around.

### 4b · Git already holds the ticket history the board says it lacks

This is the most consequential finding in the dossier and it reframes the whole database
question. Verify it first.

Because "done is a folder move," every completion is recorded as an `R100` rename:

```
2026-08-30  41fcd0c  R100  .icm/intake/triage/opencode-rails-propagation.md
                        →  .icm/intake/triage/_done/opencode-rails-propagation.md
2026-08-30  7a8ed09  R100  .icm/intake/opencode-buildout/_done/browser-agent-gating.md
                        →  .icm/intake/_done/opencode-buildout/_done/browser-agent-gating.md
```

- Open date = the adding commit (`--diff-filter=A --follow`)
- Close date = the rename into `_done/`
- A drop = the same rename, with a `> Dropped:` line in the diff
- Cycle time = the difference
- Epic archive = the folder-level rename

The positional-status doctrine accidentally produced a clean append-only event log.
**Nothing reads it.** `lib/tickets.ts` reads Trees and Blobs, and its header states plainly
that `_done/` is never fetched. Commits, like blobs, are immutable — so a commit read
caches forever on exactly the trick the file already uses for blob content.

### 4c · D14 purged the tickets and left the references

~30 dangling `PREFIX-NNN` mentions survive outside `_done/` archives, including in **live
stage contracts**:

- `workspaces/sell/stages/02_discovery/CONTEXT.md` → ICM-006
- `workspaces/start/stages/05_onboarding/CONTEXT.md` → JN-021
- `_system/contracts/CLIENTS.md` → JN-023, JN-021
- `workspaces/sell/references/{target-profile,qualification,outreach}.md` → ICM-009
- `_system/setup/questionnaire.md` → ICM-009 (×3)
- `_system/AUDIT.md` → ICM-008 (×2) · `.icm/project.md` → ICM-009 (×2)
- Eight deal folders' `DEAL.md` → ICM-011, JN-021
- `projects/jamienisbet/.icm/intake/triage/contabilista-dead-ticket-link.md` documents one
  such orphan as a stub in its own right

`self-check.sh` verifies that **markdown links** resolve. These are bare IDs, so the
estate's own anti-lying check has a blind spot precisely where D14 created the lies.

### 4d · The ticket contract is enforced in exactly one repo — the wrong one

- `self-check.sh` runs in CI (`.github/workflows/self-check.yml`) for **icm-board only**.
- `ticket-hygiene.sh` lints the whole estate — including a `no-prompt` check — but runs
  only on Jamie's machine, invoked by `/day`.
- `.icm/today.md` currently reads "not yet planned," so `/day` is not in routine use.
- agorasim, dungeons-dragons, jamienisbet, cafe-jardim, collabimmo, kau-american-bbq,
  vinecliff and remi-ai all have `.github/workflows/`; **none of them looks at `.icm/`.**
- Consequence, on disk today: **three jamienisbet triage stubs carry no `## Prompt` at
  all** — `contabilista-dead-ticket-link`, `scaffold-claude-assets`,
  `scaffold-prefix-note-stale` — in an `intake`-profile repo where the Prompt is the whole
  pick-up contract. (Sustentus's 28 promptless stubs are legitimate: it is exempt, and its
  pipeline profile picks work up via `/pipeline new`.)

### 4e · Register and reality disagree

- `.icm/project.md` Features table lists the sell and start workspaces as **"shipped,
  unproven."** `workspaces/deals/` holds **ten** deal folders, three of them live:
  alix-hahusseau at `03_quote`, billy-carlson at `02_discovery`, casey-hebbel at
  `04_proposal`. Three closed, one in delivery. They are proven.
- `_system/AUDIT.md` still carries a **P1 security item with no ticket behind it**:
  dungeons-dragons shipped a Linear API key in the public browser bundle via a
  `NEXT_PUBLIC_` prefix, never revoked. Its ticket went in the D14 purge and the AUDIT line
  is now the only record.
- AUDIT open decisions **5** (`gh` CLI banned by docs, granted in settings — which is
  real?), **6** (the ≤50-line `CLAUDE.md` rule that flagship repos break), **8** (scheduled
  routines wanted since July, none exist) and **9** (tenderdesk / courseday: migrate or
  archive?) have been open since mid-August.
- The AUDIT "estate by generation" table lists repos that may have moved generation since
  it was written. Check it.

### 4f · Possible self-violation of "redirect files, not copies"

The routing table appears in near-identical form in at least four places: `AGENTS.md`,
`CONTEXT.md`, `_system/README.md` (§ "Four commands, three workspaces"), and
`workspaces/deliver/CONTEXT.md`. The house rule says redirect, not copy — with one named
exception (`.icm/intake/README.md`, so a cloud session seeing only a client repo still has
the contract). Determine whether these four are the same information maintained four times,
and what happens when one changes.

### 4g · Housekeeping

Two stale git worktrees under `.claude/worktrees/` (`opencode-json-drift-8cd5fc`,
`pin-opencode-dcp-version-46e088`) from merged PRs. They double every estate-wide grep and
inflate any file-count metric. Minor, but they are noise in exactly the tooling that is
supposed to see clearly.

### 4h · The vendor-neutral migration went exactly one layer deep

The `opencode-sidecar` and `opencode-buildout` epics are both archived complete in
`.icm/intake/_done/`. What they delivered, verified across all 23 repos plus the root:

| Present everywhere | Present nowhere |
|---|---|
| `opencode.json` — rails only (deny local checks, `git push` → ask, share disabled, formatter off) | **`.opencode/command/` — zero directories estate-wide** |
| `AGENTS.md` — vendor-neutral Layer 0 (22 of 23; sustentus keeps a full `CLAUDE.md`) | `.opencode/agent/` — none |
| `CLAUDE.md` — the one-line `@AGENTS.md` importer | any OpenCode plugin or hook wiring |

Everything that makes the system **operable** is Claude Code only:

- The four commands (`/client`, `/project`, `/day`, `/icm-check`) — `.claude/commands/*.md`
- Both agents (`project-lens`, `ticket-scout`) — `.claude/agents/`
- The canonical skills (`ticket-craft`, `pr-conventions`) — `.claude/skills/`, in all 23 repos
- Sustentus's 31 skills, including the `/pipeline` router
- Both hooks (SessionStart board, Stop wrap-reminder) — wired in `.claude/settings.json`
- The board's deep links — `claude.ai/code/new` and `claude-cli://open`, with no OpenCode
  equivalent, so the board→terminal handoff Jamie named as his friction point does not
  exist in OpenCode at all

A global OpenCode layer does exist at `~/.config/opencode/` (`AGENTS.md`, `opencode.json`,
`agents/`, a `dcp.jsonc`) and is **uncommitted** — outside version control, outside the
conformance tooling's sight, and not part of any repo's portability story.

**So: in OpenCode you get the rails and the map, and none of the machine.** Whether that
is a deliberate staging point or an unfinished migration is a question for §6 — but
`AGENTS.md` claiming vendor neutrality while the entire operable surface is single-vendor
is, on its face, a §5.1 fidelity finding.

---

## 5 · The six investigations

In priority order. **Investigation 1 is the primary** — it is the lens Jamie chose.
Investigation 2 is the topic he named. Do not let 2 crowd out 1.

### Investigation 1 — The fidelity sweep

**Question: everywhere this system describes itself, is the description true?**

The estate's own named failure mode, recorded in `_system/AUDIT.md`, is *"aspirational docs
are richer than the running system."* Jamie has asked you to attack it directly.

Sweep for both directions of untruth:

- **Claims with no implementation.** A contract that specifies behaviour nothing performs;
  a script documented in a table that does something narrower; a rule stated in three
  places and enforced in none.
- **Implementation with no claim.** Behaviour the system has that no contract describes —
  §4b is the largest instance found so far, and there may be others.
- **Enforcement gaps.** Rules that exist as prose where a check could exist, and rules
  whose check exists but runs where it cannot help (§4d).
- **Decayed references.** §4c, and whatever else the D14 purge or the 2026-08-26 repo split
  left pointing at nothing.
- **Register vs reality.** §4e. Also: `_system/knowledge/` carries deliberate
  `— not yet established` gaps; distinguish honest gaps from rot, because the contract says
  honest gaps are correct and must not be filled by invention.

For each finding, state: **what is claimed · what is true · where the gap shows up in
practice · what closing it costs.** That last field is what makes this actionable for one
person. A finding with no cost estimate is half a finding.

Rank ruthlessly. A lie that has never cost anything and never will is a footnote, not a
finding. Say which are which.

### Investigation 2 — The board: what the tickets question actually is

**Question: given the four constraints Jamie will not trade, what is the right answer?**

His constraints (all four, simultaneously):
1. The AI keeps **direct file access** — a session at a repo root reads tickets as files,
   no network, no MCP, no API.
2. **Git stays the source of truth.**
3. **Repo-portability survives** — a handed-over client repo, or a cloud session, carries
   its whole backlog with no dependency on his Neon.
4. **Nothing new to maintain** — no sync daemon, no webhook plumbing, no second write path.

His pains: read cost and staleness · no cross-estate query · no history or metrics.

Taken together, these rule out database-as-source-of-truth. The live question is whether
anything derived earns its place, and what it is.

**Confront these directly. Each is a place where a lazy answer fails:**

- **§4b changes the question.** History is not missing from the storage model; it is
  missing from the read path. Establish what a commit-log read actually delivers — open
  date, close date, cycle time, drop reasons, throughput per repo per week — and at what
  API cost. `GET /repos/{owner}/{repo}/commits?path=.icm/intake` is one paginated call per
  repo, and commits are immutable, so they cache on the same trick `lib/tickets.ts` already
  uses for blobs. **Then ask what remains that this does not answer.** That residue is the
  only honest case for an index.
- **The 0013 precedent is the strongest argument against you.** Migration
  `0005_icm_pipeline` created `deals`, `documents`, `generations` and `workshop_messages`;
  `0013_simplify_to_leads` dropped every one of them. Its own comment records the reversal,
  and the `lead-engine` breakdown in jamienisbet says "fourteen screens became four." Any
  proposal must explain — in a paragraph, not a clause — why it is not that again. The
  distinction worth testing: what died was *content with its own lifecycle*. A derived
  index holds nothing anyone edits. Decide whether that distinction actually holds under
  the weight you are putting on it.
- **"Nothing new to maintain" is a hard constraint, not a preference.** Anything derived
  must ride something that already runs. `.github/workflows/estate-conformance.yml` already
  runs daily and already enumerates the estate over the API. `self-check.yml` already runs
  on every push. If your answer needs a process that does not exist yet, it has failed the
  constraint — say so rather than arguing the constraint down.
- **Scale honestly.** 123 stubs, 113 of them in three repos, 13 of 23 dormant. Do not
  design for 10,000 tickets. Do name the number at which the current read path genuinely
  breaks, with the arithmetic — one recursive tree call per intake-carrying repo plus one
  blob read per changed file, at 8 concurrent, against a 5,000/hr authenticated limit.
  Distinguish *"this will break at N"* from *"this feels like it might not scale."*
- **Read-only stands.** D13 holds and Jamie confirmed it. Deep links plus the human sending
  them is the mechanism, not a limitation to route around.
- **Cross-estate query is the one pain a filesystem genuinely cannot serve well.** Weigh
  it separately from the other two — it may have a different answer, and it may already be
  half-served by `tickets-board.sh` running locally.

Deliver a recommendation with a named runner-up and the condition that would flip between
them. "It depends" is not a recommendation.

### Investigation 3 — The handoff, and why sessions land wrong

**Question: what makes a stub fail to produce the right work, and what would catch it
before he does?**

This is his stated bottleneck and it lines up exactly with his description of the day —
board when deciding, terminal when doing, *"the handoff between the two is where friction
lives."* The `## Prompt` section **is** that handoff.

- The contract says a Prompt must stand alone pasted into a fresh session at a repo root.
  **Is that testable?** `ticket-hygiene.sh` checks the heading exists (§4d). Nothing checks
  whether the body is sufficient. Consider what a cheap, honest check could verify — named
  file paths that exist, the acceptance criteria present, the epic's build-order position
  legible — versus what only a human or a trial run can.
- **Read real stubs, at both ends of the range.** `projects/jamienisbet/.icm/intake/triage/
  scaffold-claude-assets.md` is excellent: it explains a mechanical constraint (the GitHub
  Contents API always writes mode `100644`, so an executable hook cannot be seeded) and
  explains why the gap was deliberately kept open rather than half-closed. Compare it
  against the weakest stubs in agorasim's 57. **Characterise the difference in a way that
  could be written into `TICKETS.md`** — that is the highest-leverage output of this
  investigation.
- **Bulk cutting is a variable.** agorasim's 57 and dungeons-dragons' 28 landed on one day.
  Ask whether a bulk `/project` cut produces different quality from an incremental one, and
  whether he trusts stubs he has not personally read.
- **There is no telemetry.** No record exists of a session landing wrong. Get specifics
  from him: which stub, what it produced, what was missing. Two or three real cases beat
  any amount of inference.
- **The `/project` gate may be the real control.** The contract has Jamie seeing the
  proposed cut *before* anything is written, with `breakdown.md` as the review surface.
  Establish whether that gate is actually being used, and whether skipping it correlates
  with the stubs that go wrong.

**The missing verb — the sharpest sub-question here.** Jamie raised the sustentus
`/pipeline` model unprompted, and it exposes an asymmetry nobody has named:

- **`pipeline` repos have a pick-up verb.** `/pipeline` is one skill routing to stage
  contracts discovered by folder order (`ls .icm/stages/` → `NN_<name>/CONTEXT.md`);
  *"adding a stage is a folder plus a routing row — never a new skill."* Crucially,
  **`/pipeline new` with no argument** groups the candidate stubs by epic, picks the
  lowest unmet `sequence: n of m`, checks dependencies, and starts. It answers *"what do I
  do next"* and then does it.
- **`intake` repos have no verb at all.** A stub is picked up by pasting its `## Prompt`
  into a fresh session. That is the entire mechanism. Read `TICKETS.md` on this: the
  Prompt is *"required in `intake`-profile repos (it is the whole pick-up contract);
  optional where the `pipeline` profile's `/pipeline new` does the picking up."* The
  contract says out loud that one profile has a command and the other has a paste.

**That gap is the handoff friction, described precisely.** Twenty-two of twenty-three
repos are `intake`. The board's deep link exists to bridge it, and it bridges it by
carrying the paste — which is why prompt quality is load-bearing and why a weak stub fails
silently.

Jamie's own framing is the constraint: *"it is practical, although for most of my other
projects we don't need 3 stages per ticket."* So the question is **not** "roll the pipeline
profile out." It is:

- **What is the one-stage equivalent?** A single verb that resolves the next stub, opens
  the branch, does the work, moves the stub to `_done/` in the finishing PR, and stops at
  **one** human gate instead of two. Does that collapse cleanly, or does removing Define
  lose the thing that makes a spec-approved gate worth having?
- **What does the estate already have that would serve as the body?** `ticket-craft` and
  `pr-conventions` are canonical skills in all 23 repos and already encode most of the
  rules such a verb would follow. Is the missing piece a command, or just the *resolution*
  step — "which stub is next" — that `/pipeline new` performs and nothing else does?
- **Does it belong in `icm-check --fix`'s baseline**, seeded into every live repo, or is it
  a third profile between `intake` and `pipeline`? Weigh against the standing complaint
  that profiles multiply.
- **It must exist in both harnesses** (§4h). A verb that is a `.claude/skills/` entry only
  deepens the split; a verb expressed as a folder plus a routing table — which is exactly
  what `/pipeline` already is — is portable in a way a hardcoded command is not. That
  design property may be the most reusable thing sustentus has.
- **And it must reach the board.** If the pick-up becomes a verb, the deep link should
  carry the verb rather than the whole prompt — which incidentally answers the read-cost
  question from a direction Investigation 2 will not reach on its own.

### Investigation 4 — Context layering and token economics

**Question: does the layering actually cost less than loading everything, and where does
it leak?**

The mechanisms: load-depth ("load down only as far as the task needs") · hard caps (≤80-line
stage contracts, ≤200-line references, a named 160-line exception for deliver's three
rituals) · thin routers · redirect-not-copy with one declared micro-copy exception ·
subagent fan-out so lens reading never enters the main context.

- **Measure the real entry cost.** What is actually in context at the top of a session
  before any work: the global `~/.claude/CLAUDE.md`, `CLAUDE.md` → `AGENTS.md`, the
  SessionStart hook's board output, and whatever the command pulls. Compare `/day` against
  `/project`. Is the discipline holding, or does the chain front-load most of the tree
  anyway?
- **§4f — four copies of the routing table.** Is the redirect-not-copy rule being broken by
  its own author, and does it matter?
- **Where does the layering pay, and where is it ceremony?** Six contracts, seven lenses,
  three profiles, two conformance scripts, four commands. Find what is genuinely unused —
  not merely under-used. Jamie chose fidelity over simplification, so removal is justified
  by *"this claims to do something it doesn't"*, not by *"this is more structure than I'd
  choose."* Hold that line.
- The `pipeline` profile is templated and **currently has no instances** outside the exempt
  sustentus. Determine whether it is scaffolding awaiting a tenant or a maintained fiction.
  D12 says extract it when a second repo has a business author. Has that happened?

### Investigation 5 — Is the knowledge layer the seam for legal, financial and marketing?

**Question, in his words: is legal/financial just more of `_system/knowledge/`, and what
would break?**

`_system/knowledge/` holds services, pricing, voice, terms and stack — Layer 3 for sell and
start, filled by `_system/setup/questionnaire.md`, with honest `— not yet established` gaps.

- Would legal and financial advice specific to his business be **more Layer-3 knowledge**
  (rules a session internalises as constraints), or a **fourth workspace** with its own
  stages and gates, or something the grammar cannot hold at all?
- What breaks first: the contract caps, the sell/start number line, the deals folder shape,
  the `no secrets in Layer 4` rule, or the never-build-an-orchestrator rule when advice
  starts implying action?
- Portugal/EU context matters and he is a *trabalhador independente* — there are already
  contabilista research documents at `projects/jamienisbet/.icm/docs/contabilista/`. Read
  them; they are evidence of what this content actually looks like when it arrives.
- **Cut no tickets for this and design nothing.** The deliverable is a verdict on whether
  the seam exists, with the named thing that would break first.

### Investigation 6 — Two harnesses, one system

**Question: what does it take for this system to be genuinely operable in OpenCode, and
what should deliberately stay Claude-Code-only?**

Cross-cutting: it constrains every recommendation in the other five. Do not treat it as a
port-everything exercise — treat it as deciding where the line goes and then making the
docs tell the truth about it.

- **Establish the real gap** from §4h, verified. Which of the Claude-only surfaces have an
  OpenCode equivalent at all (commands, agents, skills, hooks, plugins), which have a
  different shape, and which have none? Read OpenCode's actual configuration model before
  asserting parity or its absence — do not infer it.
- **Sort the surface by what it costs to lose.** The four commands are thin routers over
  stage contracts; in OpenCode the contracts are still readable and a human can say "read
  `workspaces/deliver/stages/day/CONTEXT.md` and follow it." That degradation may be
  entirely acceptable. The two hooks are different: the SessionStart board and the Stop
  wrap-reminder are the only *automatic* integrity checks a session gets, and losing them
  silently is not the same as losing a shortcut. Rank by that distinction.
- **`/pipeline`'s design is the portable one.** A router that discovers stages from the
  folder tree is closer to harness-neutral than any hardcoded command, because most of it
  is a contract a human or a model can be pointed at. Test whether that property
  generalises — it may be the answer to Investigation 3's verb question and this one at
  the same time.
- **The board's launchers.** `claude.ai/code/new` and `claude-cli://open` are both
  documented Anthropic schemes; `lib/tickets.ts` comments explain why each was chosen and
  what the undocumented alternative cost. Establish whether an OpenCode launcher is even
  possible, and if not, what the honest fallback is (Copy prompt already exists and has no
  cap).
- **Conformance is blind to OpenCode.** `icm-check.sh` and `estate-conformance.sh` check
  `.claude/` assets and `opencode.json` presence. Neither checks anything *inside* the
  OpenCode surface, and the global layer at `~/.config/opencode/` is uncommitted and
  therefore invisible to both. Decide whether that global layer belongs under version
  control at all, given the standing doctrine that the global layer stays thin and repos
  own their semantics.
- **Then make the docs true.** Whatever the verdict, `AGENTS.md`, `_system/README.md` and
  `_system/template/README.md` should state which harnesses the system is operable in and
  what each gets. Right now the vendor-neutral filename implies a parity that does not
  exist — and that is a fidelity finding whether or not any porting ever happens.

---

## 6 · Interrogate him — this is required

Use the estate's own discipline, because it is good: **rounds of at most four questions,
highest leverage first.** Stop when the remaining questions no longer change your findings,
and say what you left unasked. Every question carries an escape hatch — "don't know yet" is
a valid answer that becomes an open question rather than a gap you paper over.

Ask what changes your analysis, not what you could look up. He is direct, technical, and
answers precisely; a vague question wastes a good answer.

These went unasked in the first interrogation and are yours:

1. **Which of the four commands does he actually run, and how often?** `/project` has landed
   twice. Is `/day` a habit or an aspiration? `today.md` says "not yet planned."
2. **What is the evidence the pipeline is "working really well"?** A specific thing that
   shipped better than it would have. Protect that mechanism, not the doctrine around it.
3. **Two or three concrete cases where a session landed wrong.** Which stub, what it built,
   what was missing from it. This is the bottleneck and there is no telemetry for it.
4. **The bulk cut.** agorasim's 57 stubs in one day — from a `/project` run? Has he read
   them? Does he trust them?
5. **Token and cost economics.** What is he actually spending, and what is the concern
   behind "token efficiency rules"? Context-window pressure, money, or session latency?
   They imply different answers.
6. **Handover.** When a build-once client site is handed over, does `.icm/` go with it? That
   is the real test of the repo-portability constraint.
7. **AUDIT open decisions 5, 6, 8, 9.** Open on purpose, or just old?
8. **Sustentus.** Exempt, 28 stubs on the board, and the source the template was extracted
   from. Converging eventually, or permanently separate?
9. **The dungeons-dragons Linear key.** A live P1 in AUDIT whose ticket D14 purged. Has it
   been revoked?
10. **OpenCode: how much, and when?** Is he running it today, or is this a direction? Same
    machine or different? What made him reach for it — cost, model access, speed,
    independence from one vendor? The answer decides whether §4h is a bug or a roadmap.
11. **Which harness for which mode?** He works board-when-deciding, terminal-when-doing. Is
    OpenCode meant for one of those specifically, or for both?
12. **The verb.** Walk him through what actually happens today between "this is the ticket"
    and "the session is working." Every step, including the ones he does without thinking.
    That transcript is the specification for Investigation 3's verb, and he is the only
    source for it.

---

## 7 · What to produce

**A report. No tickets this round.** Jamie was asked directly and chose analysis only — he
decides separately what becomes work.

But write it **ticket-ready**: every finding structured so cutting an epic from it is
mechanical, not interpretive. Name the repo a finding belongs to, because *tickets live next
to the logic they describe* — a dashboard finding is jamienisbet's, a contract finding is
icm-board's.

Suggested shape, adapt as the findings demand:

1. **What I verified, and what did not hold.** The §4 dossier, corrected. Lead with the
   corrections.
2. **Fidelity findings**, ranked. Each: claimed · true · where it shows up · cost to close ·
   which repo owns it.
3. **The board recommendation.** One answer, one named runner-up, the condition that flips
   between them, and the paragraph on why this is not migration 0013 again.
4. **The handoff.** What distinguishes a stub that lands from one that doesn't — written as
   prose that could go into `TICKETS.md`.
5. **Layering verdict.** What earns its cost, what leaks, what is unused.
6. **The knowledge-layer seam.** Verdict and first-thing-that-breaks.
6b. **The pick-up verb.** What the one-stage equivalent of `/pipeline new` is, or the
    argued case that the paste is already right. Expressed harness-neutrally.
6c. **The harness verdict.** Where the Claude-Code/OpenCode line should sit, what crosses
    it, what deliberately doesn't, and which docs have to change to stop implying parity.
7. **Proposed cut, unwritten.** Epic titles with build orders and one-line stubs — the shape
   of the work, for him to gate. Do not create the files.
8. **What you left unasked, and what it blocks.**

Write it to `.icm/docs/<YYYY-MM-DD>-<slug>.md` and leave it **uncommitted**.

---

## 8 · Guardrails

Violating any of these makes the analysis unusable, however good the reasoning.

**Never propose:**
- An orchestrator, a scheduler that advances work, or anything that crosses a human gate.
- Ticking a gate, or a script that ticks one.
- Running `build`, `lint`, `typecheck`, `test`, `format` or a dev server locally — this is
  hard-denied in config and CI is the source of truth.
- Enforcing cross-repo consistency beyond the baseline. The repo wins, deliberately.
- Changes to sustentus's contracts. It is exempt and it is the source.
- Dashboard write actions. D13 stands and he reconfirmed it.
- Content for `_system/knowledge/` gaps. Honest gaps are correct; inventing them mid-task is
  a named violation.
- A rule whose maintenance cost one person cannot carry. Every rule has to earn it.

- A mechanism that only works in one harness **without saying so**. Single-vendor is an
  allowed answer; silent single-vendor is not (§4h).
- Rolling the `pipeline` profile out to `intake` repos. He said plainly that most projects
  do not need three stages per ticket. Design the lighter thing or argue the paste is
  already right — do not reach for the heavy option because it exists.

**Also:**
- **Read before concluding.** Contracts, scripts, `lib/tickets.ts` in full.
- **Verify §4.** It was one session's pass. Correct it out loud.
- **Do not confuse "the docs say X" with "the system does X."** That confusion is the entire
  subject of this brief.
- **Cite evidence.** A finding without a file path, a line, a commit, or Jamie's own words
  is an opinion.
- **Do not write into any repo except the report file**, and leave that uncommitted.
- **Cost every recommendation.** Cheap and partial beats thorough and unaffordable, for one
  person running twenty-three repos alone.
