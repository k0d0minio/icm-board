# Estate analysis — fidelity, the board, the handoff, two harnesses

> Fable 5 session, 2026-08-30, from the brief at
> [`2026-08-30-fable5-analysis-brief.md`](2026-08-30-fable5-analysis-brief.md).
> Read: every contract, all six scripts, all four commands, both agents, all ten stage
> contracts, the knowledge layer, all ten deal folders, `lib/tickets.ts` end to end,
> the sustentus pipeline (via survey), the OpenCode docs (fetched 2026-08-30), and
> stubs at both quality ends. Interrogation: three rounds, ten questions, all answered.
> **Uncommitted, deliberately** — Jamie decides what becomes work (§7 is the shape of it).
> Optimised for the lens he chose: **fidelity — the system stops lying.**

---

## 1 · What I verified, and what did not hold

Corrections first, per the brief's own instruction.

| § | Brief claimed | What is true |
|---|---|---|
| 4a | 123 open stubs across 8 repos | **121 across 7** (board's own count). The brief's 123 included icm-board's since-archived triage stub and double-counted sustentus's `intake/CONTEXT.md` as a stub. Real spread: agorasim 57 · dnd 28 · sustentus **27** · jamienisbet 6 · cafe-jardim, collabimmo, kau-american-bbq 1 each. |
| 4a | All big backlogs "added 2026-08-30" | **Cut 08-28 → 08-30, mostly 08-29.** agorasim's 57 landed in one commit on 08-29 (`d8b5a58`, message "ticket batch" — but it was a *logged, gated `/project` first run*: 16 decisions, 11 epics, register written). dnd: 27 on 08-29 via a documented `/project` **re-run** (its second), 1 on 08-30. The substantive point survives: everything is days old; staleness is not yet measurable. |
| 4a | Zero stubs exceed the 4,500-char deep-link cap | **Confirmed, stronger**: max encoded prompt estate-wide is **1,483** (dnd `guided-creation/wizard-frame`). The cap is a retired failure mode. |
| 4b | Git holds an unread ticket-history event log | **Confirmed exactly.** Every completion is an `R100` rename; 8 legible events on 08-30 alone in icm-board. `lib/tickets.ts` never fetches `_done/` (line 44 and the `/_done/` skip at 664). One nuance for §3: the *commit listing* per repo is a poll like the tree call; only per-commit reads (by SHA) are immutable-cacheable. |
| 4c | ~30 dangling PREFIX refs, all lies | **48 raw hits across 30 files — but most are honest history** (run logs, AUDIT "Done" entries, deal adoption lines: dated narrative citing a ticket as an event). The *live-surface* subset that actually misroutes a reader is small — see F9. The blind spot claim holds: `self-check.sh` lints markdown links only; bare IDs are invisible to it. |
| 4d | Contract enforced in one repo, the wrong one | **Confirmed at code level**, and worse in practice: `ticket-hygiene.sh` (the only estate-wide lint, incl. `no-prompt`) runs only when `/day` runs it — and `/day` is **"not a habit yet"** (Jamie, round 1). `today.md` has been written exactly once, by the rework PR that created it. The 3 promptless jamienisbet stubs: confirmed. Sustentus's promptless 27: confirmed legitimate (zero `## Prompt` anywhere there; `/pipeline new` picks up). |
| 4d | Missing `## Prompt` breaks pick-up | **Softened by the running system**: `tickets.ts:741` synthesises a pointer prompt ("Read `<path>` … do the work it describes") for any stub without one, so board pick-up degrades, it doesn't fail. TICKETS.md itself half-knows this (its dashboard table says "synthesised from the path when absent") while also saying "required." See §4 and §6b — this tension turns out to be the answer, not a bug. |
| 4e | Sell and start "are proven" | **Half.** Sell is proven — 01–04 all exercised across live deals (billy at 02, alix at 03 with a €7,500 quote, casey at 04). **Start is genuinely unproven**: no deal has run 05→07 inside the system (diogo-rita was adopted already-in-delivery). The register's "shipped, unproven" is stale for sell, accurate for start. |
| 4e | dnd Linear key "never revoked" | **Revoked** (Jamie, round 2). AUDIT's P1 line now overstates a closed risk — the "line is the record" mechanism worked but has no closure path. |
| 4f | Routing table maintained four times | **Real but managed.** Four projections (AGENTS.md, CONTEXT.md, `_system/README.md`, deliver/CONTEXT.md) share the four command rows' substance. The one observable propagation event — the today cap 3→10 — succeeded across every copy (zero stragglers found). A warn, not a lie. |
| 4g | Two stale worktrees | Confirmed, plus **~10 merged `claude/*` branches** never pruned. The worktrees also leak into the global ICM-detect hook's stage-contract listing (2 ghost CONTEXT.md paths every session). |
| 4h | Rails everywhere, machine nowhere | **Confirmed on disk** (22/23 AGENTS.md + importer + opencode.json; sustentus CLAUDE.md + opencode.json; zero `.opencode/` dirs) — **but the machine gap is smaller than briefed**: OpenCode natively reads `.claude/skills/`, so ticket-craft and pr-conventions (and sustentus's 31 skills) already work there today. What genuinely doesn't cross: the two hooks and the deep link. See §6c. |

Two things the brief did not know:

- **OpenCode is live and blocked.** `~/.config/opencode` was edited three times today
  (model ladder, pinned DCP, web-tester agent). Jamie's word: **"blocked on estate
  support"** — the missing operable layer is what stands between him and the epic's
  stated motive ("light stubs runnable on cheaper models"). §4h is an unfinished
  migration, not a staging choice.
- **A legal/tax workspace already existed and was retired.** The contabilista docs'
  own headers record `workspaces/legal-and-tax/` (2026-06→07), retired with the ICM
  factory on 2026-08-11. Investigation 5's answer is empirical, not speculative (§6).

---

## 2 · Fidelity findings, ranked

Format: **claimed · true · where it shows up · cost to close · owner.** Ranked by
what the lie costs, not how big it sounds.

**F1 — CLIENTS.md describes machinery that does not exist.**
*Claimed:* "A lead arriving mints a 'Reply to *name*' todo due +2 days" (`CLIENTS.md:26`,
citing JN-023), repeated in `sell/01_intake/CONTEXT.md:4-5`. *True:* nothing implements
it — zero matches for the string repo-wide; all three lead-creation paths
(`packages/services/src/queries/clients.ts:246,262,301`) are bare inserts with no side
effects; the only `createTask` call is a manual form. The *staleness* claim beside it
(7 days → red) **is** implemented — the contract is half true, which is worse than
wholly false because it reads as verified. *Shows up:* every `/client` intake run
tells Jamie a safety net exists that doesn't; a slow week loses a lead the contract
says is caught. *Cost:* S — either delete the claim from both files and let Needs-you's
real staleness surface carry the intent, or (Jamie's call) cut a jamienisbet feature
stub to build the todo and make the contract true forward. *Owner:* icm-board
(contracts); jamienisbet only if he wants the behaviour.

**F2 — The house form library is specified, cited, and empty.**
*Claimed:* "House questionnaires live in jamienisbet's `.icm/onboarding/` (JN-021),
sent from the dashboard's Forms card" (`start/05_onboarding/CONTEXT.md:13`,
`CLIENTS.md:27`). *True:* the folder holds one README whose own "Files" section links
`project-intake.md` — a dead link; the sending code (`sendFormToClient` /
`loadOnboardingForm`) is real and reads an empty shelf. The *working* pattern is
per-client forms cut into the client's repo (billy: two questionnaires in vinecliff's
`.icm/onboarding/`, PR #11 — currently the deal's critical path). *Shows up:* the next
deal to reach 05 (casey, plausibly weeks away) walks a stage whose Layer-4 input
doesn't exist. *Cost:* M to write the default `project-intake.md` (the vinecliff pair
and the discovery bank are the raw material) — or S to reword both contracts to the
per-client pattern that is actually used. *Owner:* jamienisbet (library) + icm-board
(contract wording).

**F3 — The rollout finished; the system still describes itself as mid-rollout, and the
decision that was parked "for after" has no trigger.**
*Claimed:* "icm-board pilots this set; the rest of the estate still carries Layer 0 as
a full CLAUDE.md" (`_system/README.md:99-101`); "both are legal until the rollout
completes… that is `estate-rollout`'s per-repo PR work" (conformance contract §3);
same tense in `icm-check.sh` and `estate-conformance.sh` headers. *True:* the rollout
completed — 22/23 repos migrated, `opencode-sidecar/estate-rollout` archived done.
`template/README.md:63` says "retiring the legacy tolerance is a decision for after
the rollout, with evidence" — that decision is now **due** and nothing tracks it.
*Shows up:* every conformance session reads transition rules for a transition that
ended; the tolerance keeps a warn-shape alive that can no longer occur (only sustentus
is legacy-shaped, and it's exempt). *Cost:* S for the doc edits; one human decision
(retire the tolerance or name sustentus as its permanent reason); optionally S to
simplify the two scripts' identity logic afterwards. *Owner:* icm-board.

**F4 — The enforcement chain for the ticket contract is severed in practice.**
*Claimed:* TICKETS.md is the estate standard; hygiene lints it. *True:* the only
estate-wide lint runs inside a ritual that has never run. Consequences on disk today:
3 promptless jamienisbet triage stubs sit unflagged-in-practice; **cafe-jardim and
collabimmo are dormant with open stubs** — a state TICKETS.md § Dormant explicitly
forbids ("a dormant repo that gets a new stub drops the marker in the same commit")
and **no check anywhere covers**; six repos show `off-ticket` drift nobody has read.
(Nuance: at least vinecliff and casey-hebbel are *deliberately* ticket-empty per their
deal folders — the hygiene layer can't see deal state, so its off-ticket lane is
mostly noise today.) *Shows up:* the contract drifts silently until a `/day` habit
exists; the dormant rule is a rule only on paper. *Cost:* S — a 5-line
dormant-with-stubs check in `ticket-hygiene.sh`; the two marker-drop commits; and
either the `/day` habit or a lighter path to running hygiene (see §5 — the board
launcher pattern already solves this shape). *Owner:* icm-board + the two repos.

**F5 — Both boards hide sustentus's live runs on a decayed premise.**
*Claimed (in code comments):* "Sustentus archives merged runs elsewhere (its own CI),
so its runs/ holds history, not flight — skip it" (`tickets-board.sh:95-99`,
`tickets.ts:656-658`). *True:* sustentus's close-out CI moves **merged** runs out of
`.icm/` entirely (206 archived under `apps/docs/archive/`), so what remains in
`runs/` is by construction unmerged — six folders today, i.e. in-flight or stalled
work (sustentus's own `triage/front-only-runs-never-archived` documents the leak
case). *Shows up:* the estate strip shows "0 in flight" while six sustentus runs are
open — on the board whose whole point (D13) is seeing the estate in one place.
*Cost:* S–M — verify the six, then either lift the skip (runs/ semantics now match
the estate's) or re-justify it in the comment with the truth. *Owner:* icm-board
(script) + jamienisbet (tickets.ts); the sustentus root cause is already stubbed there.

**F6 — The register layer is behind the system it registers.**
*True state:* icm-board's own `project.md` — the exemplar register — says sell/start
"shipped, unproven" (half stale, §1), lists none of the opencode epics' outcomes, and
has never had a `/project` run (its header admits this honestly). jamienisbet — the
flagship repo, 7 epics of activity this week — has **no register at all**, so its
stubs were cut outside the ritual that owns cutting ("Epics are cut by `/project`" —
TICKETS.md line 7). agorasim and dnd registers are current and excellent. *Shows up:*
"the register records what is true, and the run log dates it" (AUDIT) is true in 2 of
23 repos; the on-demand-only decision covers the dormant thirteen but not the two
flagships that are missing/behind. *Cost:* M — one `/project icm-board` run and one
`/project jamienisbet` first run. *Owner:* each repo.

**F7 — AUDIT carries closed items as open.**
The dnd Linear key P1 is revoked (round 2) but still listed open with "never been
revoked". The generation table (Gen 0–3) predates the profile taxonomy that replaced
it (D12) and misplaces today's estate (jamienisbet "Gen 2"; agorasim "Gen 2" — both
now flagship intake repos). Open decision #5 (gh CLI) has been half-answered de facto:
the estate rails *allow* `gh`, sustentus's own opencode.json *denies* it — per-repo,
which is the house answer. All four open decisions remain live by Jamie's word
(round 2) — the list is honest wants, but #8 (scheduled routines, wanted since July)
has no vehicle: its tickets died in D14 and were never re-cut. *Cost:* S — one AUDIT
editing session; give #5/6/8/9 ticket homes or an explicit "parked, no vehicle" note.
*Owner:* icm-board.

**F8 — The scaffold seeds a retired convention into every new repo.**
`suggestedPrefixNote` (`lib/icm-scaffold.ts`) writes "register the prefix in
TICKETS.md" into each newly created client repo's intake README — the convention D14
retired. Two sibling echoes in live icm-board surfaces: `start/CONTEXT.md` stage
table ("Ends with … prefix registered") and `deals/README.md`'s folder diagram
("`06-repo.md` ← … prefix registered") — both contradicting the 06_repo stage contract
they sit above, which correctly says "there is no prefix to choose or register."
*Shows up:* the next won deal's repo is born with false instructions. *Cost:* S —
two line edits here; the scaffold fix is already stubbed
(`jamienisbet triage/scaffold-prefix-note-stale`). *Owner:* icm-board + jamienisbet.

**F9 — Live surfaces still route readers to purged tickets.**
The actionable subset of the 48 references: `estate-conformance.yml:38` — the CI
**error message** says "See ticket ICM-005" (if the PAT ever lapses, the remediation
pointer is dead); same ref in `estate-conformance.sh:43`; `self-check.sh:15`
(ICM-003); ~10 "(ICM-009)" provenance tags across every knowledge file and three sell
references — cosmetic, but unverifiable since D14 purged archives too. The deal-log
and run-log mentions are history and should **not** be "fixed." Add the missing lint:
self-check already sweeps every doc; a bare-ID pattern outside `_done/` is ~6 lines.
*Cost:* S. *Owner:* icm-board.

**F10 — Implementation with no claim (the system is richer than its docs).**
The inverse failure, three instances that deserve contracts:
(a) **the R100 event log** — open/close/drop dates and cycle time derivable per stub,
nothing reads it (§3 makes it the history answer);
(b) **the board is already the intake resolver** — `tickets.ts` computes each epic's
"next" (lowest unmet sequence, dependency-aware, `openDep` → waiting), swipe-right
starts it, and maintenance launchers (triage / sweep / **recut per epic** / estate
check) already exist as human-sent deep links — none of this appears in any contract;
the deliver stage contracts describe a terminal-only world while Jamie plans
board-first (round 1);
(c) **synthesized prompts** — the pick-up degrades gracefully estate-wide; TICKETS.md
still describes the strict rule. §6b resolves (b) and (c) together. *Cost:* folded
into §6b's contract edit. *Owner:* icm-board.

**F11 — Housekeeping and the global layer.**
Two stale worktrees + ~10 merged `claude/*` branches (they ghost into every
estate-wide grep and the ICM-detect hook's listing). The global CLAUDE.md says "the
one global hook" while at least two are wired (block-local-checks + the ICM-detect
SessionStart) and two more sit unwired in `~/.claude/hooks/`. The global OpenCode
AGENTS.md (a copy of the Claude one) tells OpenCode sessions about
`block-local-checks.sh` — a hook that doesn't exist in that harness (its equivalent is
the opencode.json denies). `~/.config/opencode/` is uncommitted yet contains a
prepared `.gitignore` — versioning was half-intended and never done; conformance is
blind to it. *Cost:* S each; the global-layer versioning is a Jamie decision (§6c).
*Owner:* icm-board / the global layer.

**Footnote-grade** (real, never cost anything): the brief's own header says
"Uncommitted" while it sits committed at `8b36e71`; `estateCheckSessionUrl`'s prompt
tells the session to "propose fixes as tickets rather than fixing" while the
conformance contract says run `--fix`; hygiene accepts `## Agent prompt` while
self-check requires exactly `## Prompt`.

---

## 3 · The board: recommendation

**Recommendation: no new store. Serve all three query families off reads that already
exist, and defer any index until the queries have proven themselves.** Three moves,
each riding an existing rail:

1. **Cross-estate filters and full-text over open work are a UI feature, not a data
   problem.** `listBoard()` already holds every open stub — parsed body, priority,
   lane, blocked, repo — in memory on every render. "All P0s everywhere", "everything
   blocked", "find the stub that mentions X" is a client-side filter/search over data
   the board has already paid for. Zero new reads, zero new store. *(jamienisbet)*
2. **History and metrics come from the commit log the positional doctrine already
   wrote.** One `GET /repos/{owner}/{repo}/commits?path=.icm/intake&per_page=100`
   listing per intake-carrying repo (7 today) per view — a poll on the same footing as
   the existing tree call — then per-commit detail reads **by SHA**, which are
   immutable and cache on exactly the trick blob reads already use. That yields open
   date, close date, drop + reason, cycle time, throughput per repo per week, epic
   archival — the full metrics family. Arithmetic: a cold year of icm-board history is
   a few hundred one-time cached reads; steady state is ~7 listing calls per history
   view against a 5,000/hr limit the board currently touches at ~1%. *(jamienisbet,
   same cache module, same tag)*
3. **The read-cost/staleness pain shrinks as a side effect of §6b**: a pointer-verb
   deep link means the session reads the stub fresh from `main` at pick-up, so the
   payload can't be stale even when the board's minute-clock is.

**Named runner-up:** a derived read-model (Neon tables written idempotently by the
existing daily `estate-conformance` workflow — no new process, rebuilt from git, never
edited by anyone). **The condition that flips to it:** history/metrics queries become
a daily phone habit *and* the per-repo listing read demonstrably chafes (>20 active
intake repos, or wanting full-text over **closed** stubs' content, which would need
blob reads at historical SHAs per query). Neither condition holds today; Jamie's own
"don't know yet" on queries (round 3) is the strongest argument for not building it.

**Why this is not migration 0013 again.** What 0013 killed was *content with its own
lifecycle*: deals, documents, generations — rows people edited in the app, a second
write path competing with reality, fourteen screens of ceremony around it. Its header
comment says so ("IRREVERSIBLE… what survives is one row per person"). The primary
recommendation adds **no tables and no write path at all** — it renders data GitHub
already serves. Even the runner-up is a cache nobody edits, rebuilt from git,
deletable without loss — closer to `lib/tickets.ts`'s Data Cache than to the deal
pipeline. But the honest 0013 lesson is subtler than "derived is safe": 0013 died
because the ceremony outran the need. The same test kills the runner-up *today* —
the need is unarticulated ("don't know yet") — and that is why it is the runner-up
and not the answer. Constraint check: files stay the AI's interface (untouched), git
stays source of truth (only reader changes), portability untouched, nothing new to
maintain (renders + existing cron only).

D13 stands throughout; nothing here writes.

---

## 4 · The handoff: what distinguishes a stub that lands

The evidence flips the brief's suspicion: the bulk cut is not the weak end. agorasim's
57 and dnd's 28 are sourced to file:line, sequenced, and their breakdowns carry
*verified* world-state ("PR #30 shows merged on GitHub but never reached main"). The
best prompt on the estate (`dnd guided-creation/wizard-frame`) hand-writes the exact
step `/pipeline new` automates: *"Verify the srd-2024-migration epic's first three
stubs are in its `_done/` — flag and stop if they aren't."* Prompt authors are
manually compensating for the missing resolver.

The structural fact from the interrogation: between cut and execution there is
**exactly one human filter — the breakdown review at cut time** ("gated, breakdowns
only"; stubs largely unread; prompts never re-read at send). All three failure modes
Jamie selected map onto that geometry:

- **Scoped wrong at cut** → the gate reviews breakdowns, so the breakdown must carry
  the scope *argument*, not just the list — `What I understood` + `Out of scope` are
  doing this well where it works.
- **Stale by pick-up** → nothing re-reads the world between cut and send. The fix is
  making fresh-reading the default (the §6b verb; the board's existing per-epic
  **recut** launcher), not asking a human to re-review.
- **Ignored conventions** → conventions restated per-prompt don't scale; they belong
  where every session loads them (the repo's AGENTS.md and skills), with the prompt
  carrying only the constraint the repo can't infer ("no global store",
  "apple-redesign tokens if landed").

**Prose ready for TICKETS.md** (the §Prompt section, replacing the strict rule):

> A stub must stand alone: a fresh session at the repo root, told only the stub's
> path, should build the right thing from the stub plus the repo's own contracts.
> Write claims a session can verify — name files and lines, state the world as
> checked ("PR #31 open, #30 never reached main"), and date them. State dependencies
> as facts to verify, not history to trust: the pick-up re-checks `depends-on`
> against `_done/` before building. Put repo-wide rules in the repo's AGENTS.md or
> skills, never in each stub; a stub carries only the constraints this work adds.
> The `## Prompt` section is the pick-up's cover note, not a second copy of the stub
> — where a resolver does the picking up (`/pipeline new`, the board's next-stub
> link, `/next`), it is optional, and the board synthesises a pointer when absent.

One more, cheap and grammar-native, because no concrete wrong-landing could be named
even when asked (round 1 — the failure is remembered as a pattern, not logged):
**when a session lands wrong, park a triage stub about it** (`lane: bug`,
`found-by: wrong-landing · <date>`, naming stub + PR). Three of those are worth more
than this whole section next time.

---

## 5 · Layering verdict

**The discipline holds and earns its cost — measured against what Jamie says actually
bites (money + latency + principle, explicitly *not* context-window pressure).**

- **Caps hold everywhere checked**: sell/start contracts run 33–49 lines (cap 80);
  deliver's three rituals 80–139 (named cap 160); references ≤105 (cap 200). Entry
  cost is genuinely thin: global CLAUDE.md + AGENTS.md + two hook lines ≈ two hundred
  lines before any work; `/day` and `/project` pull bounded, declared Inputs. The
  structure never front-loads the tree.
- **The four-way routing duplication (§4f) is real but has paid its bill**: the one
  observed propagation (cap 3→10) landed in every copy. Keep it; the cost shows up
  only if a command's semantics change without a sweep — which F3 shows *does* happen
  (the rollout language) when the change isn't a searchable token. A warn.
- **What is genuinely unused**: `/day` (never run; today.md dead; the SessionStart
  nag ignored every session) and, downstream of it, the whole today-flag loop — the
  board's Today strip has no living writer because the only writer is a ritual that
  doesn't fit how Jamie actually plans (board-first, phone). This is the one place
  the process layer describes a world its operator doesn't live in. The fix is not
  deleting `/day` — reconciliation is its real value and F4 needs it — but giving it
  a board-shaped ignition: a **"Plan today" launcher** on the board (the
  `estateCheckSessionUrl` pattern, exactly) that opens a session pre-filled to run
  `/day`. Human sends it; D13 intact; the ritual meets the habit where it lives.
- **The `pipeline` profile is scaffolding awaiting its tenant** (remi-ai's migration
  decision, per D12) — zero instances, so its templated assets have never once been
  seeded or exercised. Not a fiction (D12 names the tenant condition), but unproven
  inventory: expect first-use friction, and don't build more of it until remi-ai
  decides.
- **Lenses and scouts are real**: dnd's re-run used five lenses and dropped two with
  written reasons; agorasim's cut cites lens findings per stub. No ceremony found.
- **Leaks**: the worktree ghosts in every grep and in the ICM-detect listing (F11);
  hygiene's off-ticket lane blind to deal-state (F4 nuance); the ICM-009 provenance
  scatter (F9).

---

## 6 · The knowledge-layer seam (legal / financial / marketing)

**Verdict: the seam exists, is already in use, and it is not `_system/knowledge/`.**
The estate has run this experiment: `workspaces/legal-and-tax/` existed as an ICM
factory and was retired 2026-08-11. What survived tells you the true grammar —
three kinds of artifact, each already housed:

1. **Durable understanding** → reference docs in `.icm/docs/`
   (`contabilista/01-…`, `02-…`), carrying their own epistemic discipline: every line
   marked **✅ confident / ⚠️ needs confirmation**, "decision-support, not advice."
   That marking is an *invention the knowledge layer doesn't have* — knowledge/ knows
   `established` and `— not yet established`; professional-domain content needs the
   third state *asserted-pending-professional-confirmation*.
2. **Dated obligations** → **state, not prose**: `biz.compliance_dates` (recurrence,
   completion inserts the next occurrence) surfaced in Needs-you. Exactly right —
   obligations are Neon-shaped, per the estate's own "business state lives in Neon"
   rule.
3. **The advice interaction itself** → an outbound artifact addressed to a
   professional (the brief *is* the engagement conversation), gated by Jamie like any
   proposal.

**What breaks first if legal/financial is forced into `_system/knowledge/`:** the
citing-stage rule. knowledge/'s own README defines each file by which sell/start
stage cites it; personal-regulatory content serves no stage, so it would be dead
weight by the system's own logic — before the ≤200-line cap breaks (it would, next)
and long before the no-orchestrator rule is even approached (Needs-you already
surfaces dates as data; the human acts). Marketing splits the same way D8 already
ruled: playbooks that sell stages cite → sell references (outreach.md is this);
content production → jamienisbet's own workspaces.

**So the answer to "is it just more knowledge/?" is no — it is more of the seam the
contabilista work already found**: docs with the ✅/⚠️ discipline (worth writing down
as a one-paragraph convention in `.icm/docs/README` or the knowledge README, so the
next domain inherits it), obligations as compliance rows, briefs as gated outbound.
The only icm-board change this suggests is answering its own open question ("should
icm-board hold the estate `.icm/docs/` research?") — and the citing-stage logic says:
only if a workspace here starts citing it. Nothing to design this round, as briefed.

---

## 6b · The pick-up verb

**Recommendation: one verb, `/next`, defined once in the canonical skill and exposed
as a four-line command in both harnesses. The resolution logic already exists in
three places; this names it and puts it where sessions can run it.**

What exists today: sustentus's `/pipeline new` (group candidates by epic → lowest
unmet `sequence` → verify `depends-on` merged → announce and stop for confirmation);
the board's `nextOf` + dependency grouping + swipe-right (the same algorithm in
TypeScript); and the best stubs hand-writing the check into their prompts. What no
surface has: a terminal-side or OpenCode-side resolver for the 22 intake repos —
which is precisely the "estate support" Jamie says blocks OpenCode, and one of the
three pick-up routes he actually uses ("terminal-first: name the stub").

The shape, harness-neutrally:

- **The logic lives in `ticket-craft`** (a "Picking up" section): candidate set =
  epic stubs (triage excluded, as `/pipeline new` does); one epic → its next, several
  → ask; verify `depends-on` in `_done/` *and the work actually on main*; announce
  the pick and stop for confirmation; then work the stub, and the finishing PR
  `git mv`s it. OpenCode reads `.claude/skills/` natively (docs, verified
  2026-08-30), so **both harnesses get the logic from the same file** — no fork.
- **Two four-line command files invoke it**: `.claude/commands/next.md` and
  `.opencode/commands/next.md` ("Load the ticket-craft skill's Picking-up procedure;
  argument optional: `<epic>/<slug>` skips resolution"). Seeded estate-wide by adding
  them to the template + `icm-check.sh`'s canonical list — the existing propagation
  mechanism, nothing new. The OpenCode command can pin the cheap model in its
  frontmatter — which is the "light stubs on cheaper models" motive delivered.
- **The board's deep link carries the verb, not the essay.** Today the link freezes
  the `## Prompt` at tap time; a pointer payload ("Pick up `.icm/intake/<epic>/<slug>.md`
  per this repo's pick-up contract" — essentially the synthesised prompt the board
  already emits for promptless stubs) makes the session read the stub **fresh from
  main**, killing payload staleness and retiring the 4,500-char cap outright. Copy
  prompt stays as the no-tooling fallback.
- **TICKETS.md is rewritten to match** (the §4 prose): the *stub* must stand alone;
  the `## Prompt` becomes a cover note, optional where a resolver exists. This closes
  the contract's internal tension (required ↔ synthesised-when-absent), legitimises
  jamienisbet's softened micro-copy, and moves the quality bar to where the failure
  modes actually live.

One human gate, kept: the verb announces its pick and stops — same as `/pipeline new`,
same as the deep link's "the human sends it." Nothing self-advances; this is a
resolver, not an orchestrator, by exactly the D11 line (deterministic, one job, reads).

**Runner-up:** a `pipeline-lite` profile (one-stage run spine: run folder + single
gate). **Flip condition:** an intake repo starts needing per-ticket spec approval or
an auditable run record — none does today, and Jamie's "most projects don't need 3
stages per ticket" rules it out as the default. The paste-is-already-right position
was considered and fails his own evidence: no re-read at send + staleness as a named
failure mode means a frozen paste is the wrong default even when well written.

---

## 6c · The harness verdict

**Where the line sits:** *the process layer crosses; the ambient layer stays.*

**Crosses now (cheap, mostly already true):**
- **Skills** — already cross-harness: OpenCode's documented search path includes
  `.claude/skills/<name>/SKILL.md`. ticket-craft, pr-conventions, and sustentus's 31
  (including `/pipeline`'s body) load today. Zero work.
- **Commands** — the four icm-board commands are 5–30-line routers over
  harness-neutral stage contracts; `.opencode/commands/*.md` supports the same shape
  ($ARGUMENTS, file refs, per-command model). Porting is transcription, in icm-board
  only (the estate never carried them). Sustentus can shim `/pipeline` the same way —
  its call, it's exempt.
- **Agents** — `project-lens` and `ticket-scout` port as `.opencode/agents/*.md`
  (mode: subagent, permission-restricted). Small rewrite, icm-board only.
- **`/next`** — born dual (§6b).
- **Rails** — done estate-wide since opencode-buildout.

**Stays Claude-only, deliberately and said out loud:**
- **The two hooks.** OpenCode has no SessionStart context-injection and no stop gate
  (verified against docs and the plugin typings; `session.idle` is observational).
  The board greeting and the wrap-reminder are CC's. Mitigation that fits the
  grammar: the ported commands *carry* the check instead — OpenCode command templates
  support shell injection, so `/day` and `/next` open with the `tickets-board.sh
  --today` output inline. Explicit beats ambient; acceptable degradation, documented.
- **The deep link.** No URL scheme exists in OpenCode — not undocumented, absent.
  The honest board story: Copy prompt (uncapped, exists) plus a "copy as
  `opencode --prompt '…'`" affordance for terminal-first pick-up. A local
  URL-handler shim would work and is rejected by name: it is exactly the "nothing
  new to maintain" violation, for one tap saved.

**The docs that must stop implying parity** (or start claiming it, once §6b lands):
`AGENTS.md` (state which harnesses operate what), `_system/README.md` § shape-of-a-repo
(F3's rewrite is the same edit), `_system/template/README.md`. One sentence each of
truth: *"Claude Code runs the full machine (commands, hooks, deep links); OpenCode
runs the contracts, skills and commands, with pick-up via `/next` or pasted prompts;
the two hooks and the one-tap link are Claude-only."*

**The global layer:** `~/.config/opencode/` should come under version control (its
`.gitignore` is already written for exactly that) — it now carries real decisions
(model ladder, pinned plugin versions, the security reasoning in its comments) that
the estate's no-plaintext-audit posture would want recoverable. Thin-global doctrine
is untouched: versioning ≠ thickening. Jamie's call on where (own repo vs a tracked
mirror in icm-board's `_system/`); flagged, not prescribed. The stale
`block-local-checks.sh` sentence in its AGENTS.md goes in the same pass (F11).

---

## 7 · Proposed cut — unwritten, for the gate

Epic titles, build order, one-line stubs. **No files created.** Repo ownership per
"tickets live next to the logic they describe."

**icm-board · `doc-truth`** — the fidelity sweep (F1–F3, F7–F9)
1. `audit-refresh` — Linear-key line to Done (revoked, date); gen-table retired or
   re-drawn as profiles; #5 annotated with the de-facto per-repo answer; #8 given a
   vehicle or a "parked" marker.
2. `phantom-behaviour-contracts` — CLIENTS.md + 01_intake todo-mint claim removed (or
   re-scoped to Needs-you reality); 05_onboarding + CLIENTS.md form-library rows told
   the per-client truth (pairs with jamienisbet `house-intake-form` if he wants the
   library real instead).
3. `rollout-language` — README/conformance/template/scripts stop describing the
   finished rollout as in-flight; carries the tolerance-retirement decision to Jamie.
4. `prefix-echoes` — start/CONTEXT.md + deals/README.md lines.
5. `legacy-id-sweep` — ICM-005/ICM-003 live pointers replaced with real instructions;
   self-check gains the bare-ID lint (history and `_done/` exempt).
6. `sustentus-runs-skip` — verify the six live runs, then fix or re-justify the skip
   in `tickets-board.sh` (jamienisbet twin below).

**icm-board · `pickup-verb`** (§6b) — after doc-truth 2/3 land
1. `ticket-craft-resolution` — the Picking-up section (the logic, once).
2. `next-commands` — `.claude/commands/next.md` + `.opencode/commands/next.md` in the
   template; `icm-check.sh` canonical list extended to seed them.
3. `tickets-md-prompt-rule` — the §4 prose replaces the strict rule; micro-copy
   template updated (propagates on future fixes, per doctrine).

**icm-board · `opencode-operability`** (§6c)
1. `port-commands` — the four routers as `.opencode/commands/` here.
2. `port-agents` — project-lens + ticket-scout as `.opencode/agents/`.
3. `command-attached-board` — `/day`/`/next` open with the board via template shell
   injection (the hook-loss mitigation).
4. `harness-truth-docs` — the one-sentence parity statement in the three files.
5. `global-layer-versioning` — human decision stub: track `~/.config/opencode/`
   (where), fix its AGENTS.md hook sentence.

**icm-board · `hygiene-holes`** (F4, F11 — small)
1. `dormant-with-stubs-check` — the missing lint in ticket-hygiene.
2. `worktree-branch-prune` — two worktrees, ~10 merged branches (chore).

**jamienisbet · `board-queries`** (§3)
1. `open-board-filter-search` — client-side filters + full-text over `listBoard()`'s
   already-fetched data.
2. `history-read` — commits-by-path listing + immutable per-commit reads, same cache
   module/tag; cycle-time and shipped-this-week surfaces.
3. `deep-link-verb-payload` — pointer prompt replaces frozen `## Prompt` (pairs with
   pickup-verb 3); "copy as opencode" affordance beside Copy prompt.
4. `plan-today-launcher` — the board button that opens a `/day` session (§5).
5. `sustentus-runs-strip` — tickets.ts twin of doc-truth 6.
   *(Existing stubs already cover the scaffold issues; `house-intake-form` joins
   triage only if F2 resolves toward a real library.)*

**cafe-jardim, collabimmo** — one commit each: drop `.icm/dormant` (open stub
present) or close the stub; either restores the contract.

Not cut, deliberately: anything for Investigation 5 (verdict only, as briefed); the
runner-up index; any `/day` redesign beyond the launcher (habit first, then judge).

---

## 8 · What I left unasked, and what it blocks

- **Concrete wrong-landing cases.** Asked directly (round 1, with a notes invitation);
  none named. §4's failure-mode mapping is therefore pattern-level, not case-level —
  the wrong-landing triage convention exists to fix this for next time. Blocks:
  nothing now; sharpens everything later.
- **Handover practice** — whether `.icm/` ships when a build-once site is handed to a
  client. His portability constraint stands regardless; the answer would only tune
  how much the micro-copy README must carry. Blocks: nothing in this report.
- **Sustentus convergence** — exempt by standing decision and its own author; no
  recommendation here depends on the answer.
- **today.md's fate if the launcher doesn't take** — deliberately left as the gate on
  §5's recommendation rather than a question: try the board-shaped ignition; if the
  flag stays dead a month later, retire it honestly (the fidelity lens cuts both ways).
- **The 0013-adjacent worry inverted** — whether *this report's* cut is itself too
  much ceremony for one person. The mitigation is baked in: every epic above is
  independently droppable, doc-truth 1–4 are one-session work, and nothing depends on
  anything outside its own repo.
