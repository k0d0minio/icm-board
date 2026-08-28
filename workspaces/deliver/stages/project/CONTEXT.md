# deliver/project — what are we building, and what's the next ticket?

Entered by `/project <repo>`. Argument: a repo name (`cafe-jardim`) or a client's name —
resolve with Jamie if ambiguous. Work from the Apps root.

**One ritual, every stage of a repo's life.** First run adopts it and establishes intent.
Every run after asks whether the intent still holds and reconciles the tickets to the
answer. There is no separate onboarding, discovery or sprint-planning command — this is
all three, and running it twice in a row is harmless.

**Sustentus is exempt** — its `.icm/` owns its own semantics. Refuse unless Jamie names
it explicitly, and then honour its contracts, not this one.

## Inputs

| Layer | File | Why |
|---|---|---|
| 3 | [`PROJECT.md`](../../../../_system/contracts/PROJECT.md) | The register this ritual reads first and writes last |
| 3 | [`TICKETS.md`](../../../../_system/contracts/TICKETS.md) | What findings become |
| 3 | [`LENSES.md`](../../../../_system/contracts/LENSES.md) | The analysis roster §4 fans out |
| 4 | The repo itself — `.icm/`, `CLAUDE.md`, docs, git history | The reality being reconciled |

**Writes only inside `.icm/`** — `project.md`, `intake/`, `docs/`. Never a code file. The
lens agents write nothing at all.

## Process

**0. Guards — never error, always land somewhere.** Every one of these is a normal state:

| Found | Do |
|---|---|
| Repo not on disk | Clone it (`gh repo clone k0d0minio/<name> projects/<name>`) |
| Repo not on GitHub | **Stop.** The dashboard creates client repos (`createClientRepo`); say so and end |
| No `.icm/` | `_system/scripts/icm-check.sh --fix`, report what it seeded |
| No `project.md` | First run — 1a |
| `project.md` present | Re-run — 1b |
| No tickets, no git history, no docs | Fine. Thin repo, thin first pass, more questions |
| Uncommitted changes | Leave them strictly alone; never `git add -A` |

**1a. First run — establish the register.** Read what already exists before asking
anything: `.icm/docs/` (client requests, proposals, discovery reports — a repo born
through [`start/07_kickoff`](../../../start/stages/07_kickoff/CONTEXT.md) arrives with
the deal's documents already there), `CLAUDE.md`, `README.md`, requirements docs.
**Adopt, never fabricate.** Existing scope docs and decision registers get *folded in*
with provenance cited — those decisions are made and must not be re-asked. Only genuine
gaps become questions.

**1b. Re-run — reconcile before asking.** Read `.icm/project.md`; from its run log take
the last commit and get what happened since (`git -C <repo> log <sha>..HEAD --oneline`
plus changed paths). Then state the **posture** out loud so Jamie can correct it:
*launch* (no v1; unshipped essentials) · *maintenance* (v1 shipped; defects, health,
drift) · *expansion* (stable; new features). Posture decides where interrogation and
lenses aim. Do not guess silently.

**2. Scan — cheap, structural, no fan-out.** Enough to ask good questions: the stack,
routes/entry points, ticket state (every epic's stubs, `_done/` and build order; the
`triage/` backlog; any legacy flat tickets still unmigrated), what shipped since last
run, whether the Features table still matches reality.
**Reconcile the board first** — a ticket whose work visibly merged goes to `_done/` now;
distinguish the commit that *created* a ticket from the one that *did the work*; where
ambiguous, ask. Spawn `ticket-scout` if the repo has real git history.

**3. Interrogate — features and business logic first.** The phase that decides ticket
quality. Aim at what the project must *do* and the rules that govern it — a question
that changes the feature set beats one that changes an implementation detail. Rounds of
**at most 4**, highest-leverage first; stop when remaining questions no longer change
the ticket set, and say what you left unasked.
*First run:* who it is for · the one job · what done looks like · the business rules in
the domain's own words · what is explicitly out and why.
*Re-run:* lead with the register — "Last run you decided X, Y, Z. Still true?" A re-run
where nothing changed is a valid outcome: say so, skip to 7.
*Constraints are asked about, not derived* — ask the bar once, record it, let every
ticket inherit it. *Every question carries an escape hatch:* "don't know yet" becomes an
Open question, or a decision ticket if it blocks. Client-only questions route to a form
in `.icm/onboarding/`; on Jamie's own repos they become decision tickets. Never invent a
recipient.

**4. Analyse — lenses, scoped by what §3 established.** Fan out `project-lens` agents
per [`LENSES.md`](../../../../_system/contracts/LENSES.md), **in a single message** so
they run concurrently. Each prompt carries: repo path, its lens, the intent and business
logic, the constraints, the open ticket titles. Scope the fan-out — first run: every
lens with substance (say which were dropped and why) · intent changed: the lenses intent
touches plus the diff's domains · intent unchanged: only what the diff touches. A lens
with nothing to say costs one line; a lens run on a question nobody asked buries the
findings that mattered.

**5. Reconcile — intent in, tickets out.** Synthesis is **yours**, not an agent's.
Dedupe (merge, keep strongest evidence) · drop what open tickets or shipped work already
cover · rank by what moves the project (blocks launch/revenue · harms users now ·
explicitly asked · rest — if a third is P0, none of it is) · reconcile against the
Features table (every finding maps to a *wanted* feature or a breached constraint;
matching nothing = new feature row or noise, say which). Then each existing stub vs
intent: still fits → untouched · wrong priority/scope → amend in place with why · no
longer fits → `git mv` to its epic's `_done/` with `> Dropped: <reason, date>` ·
missing → cut. **Never delete a stub file, never reuse a slug within an epic.**
A repo still carrying legacy flat `PREFIX-NNN` tickets gets its migration here: re-cut
the survivors into epics/triage from the evidence (drop bias applies), and `git mv` the
old files to `intake/_done/` with a `> Recut as <epic>/<slug>` (or `> Dropped:`) line.

**6. Write — register, then the cut.** `.icm/project.md` per
[`PROJECT.md`](../../../../_system/contracts/PROJECT.md): decisions appended with stable
IDs (supersede, never edit away), Features table brought current (rows point at epic
paths), open questions carried forward, run-log row with date and `HEAD`. Then the cut
per [`TICKETS.md`](../../../../_system/contracts/TICKETS.md): related work becomes an
epic — `intake/<epic-slug>/` with a `breakdown.md` (what I understood + build order) and
one stub per unit of work, sequenced `1..m` in dependency order; one-offs become
`triage/` stubs with their lane. Every stub carries a `- sources:` line citing evidence —
the client's own words where they exist — and, in `intake`-profile repos, a standalone
`## Prompt`.

## Gate — Jamie

- Corrects the stated posture (1b) before the run aims itself.
- **Sees the plan before anything is written** (between 5 and 6): the proposed cut —
  epics with their build orders (sequence · slug · title · priority · size · lens),
  triage stubs, amendments, drops with reasons. The breakdown is the review surface:
  after 6, editing `breakdown.md` and asking for a re-cut steers it. His yes gates 6.
- Decides push: everything stays **uncommitted** unless he says otherwise (ticket-only
  commits straight to `main`, staged explicitly).

## Outputs

| Artifact | Lands in |
|---|---|
| `.icm/project.md` (written/amended) | the target repo |
| Epics + stubs cut/amended/moved | the target repo's `.icm/intake/` |
| Closing summary | the session: posture · intent changed? · epics and counts by priority · the picks you'd put in `today.md` (the ≤10 cap is `/day`'s call) · what's unanswered and what it blocks |

## Audit

- Register and board agree with each other and with the code — no feature row without
  its epic or stubs, no stub contradicting a decision.
- Every epic's bookkeeping holds: sequences contiguous, depends-on ordered, build order
  agreeing with the stubs (`validate-intake.sh` where the repo carries it).
- Nothing was asked that a document already answered; nothing fabricated that no one
  stated.
- In `intake`-profile repos, every new stub's Prompt stands alone pasted into a fresh
  session.
