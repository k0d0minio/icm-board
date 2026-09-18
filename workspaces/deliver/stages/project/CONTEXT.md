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
| 3 | [`PIPELINE.md`](../../../../_system/contracts/PIPELINE.md) · [`template/README.md`](../../../../_system/template/README.md) | The pipeline profile: what the template seeds, which files are the repo's own (§1c) |
| 4 | The repo itself — `.icm/`, `CLAUDE.md`, docs, git history | The reality being reconciled |

**Writes only inside `.icm/`** — `project.md`, `intake/`, `docs/` — with one bounded
exception: setting a repo up on the pipeline profile (§1c) also touches the repo's own
surfaces that profile needs (`.claude/settings.json`, `.github/`, the formatter's ignore
file, Layer 0's delivery section), on a `claude/` branch, as a PR. Never a code file. The
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

**1c. Pipeline profile — set the repo up when Jamie declares it.** Declaring the profile
is Jamie's act ([`PIPELINE.md`](../../../../_system/contracts/PIPELINE.md); the fix never
upgrades one): on a first run, or whenever `.icm/CONTEXT.md` lacks the line and the repo
has the flow for it — specs, runs, gated merges, a docs tree — ask once. "No" ends the
step. "Yes", or a repo that already declares it with the project-owned stubs unfilled, is
the onboarding — the mechanical half here, the questions in §3, the writing in §6 — on a
`claude/` branch in the repo, one PR:

1. **Declare, and rewrite the map.** `- profile: pipeline` under the H1 of
   `.icm/CONTEXT.md`, and the file itself on the reference shape (sustentus's,
   generalised: the spine table, the lanes, the layers, the layout, the `run.md`
   template, the where-defined table). It is the repo's own, never synced.
2. **Guard the formatter first.** Before a single template-owned file is committed,
   exclude the template-owned paths (`.icm/stages/`, `.icm/lanes/`, `.icm/_shared/`,
   `.icm/intake/CONTEXT.md`, `.claude/skills/pipeline/SKILL.md`,
   `.github/pull_request_template.md`) and `.icm/runs/` from the repo's formatter
   (`.prettierignore`, `biome.json`, …) and commit that alone. A pre-commit hook that
   reformats them re-drifts every contract on the first commit (D17/D19; remi-ai #105).
3. **Seed, then sync.** `_system/scripts/icm-check.sh --fix` seeds what is missing — the
   template-owned files, the project-owned stubs with `project.json`'s `name` filled, the
   router, the PR template. Then `_system/scripts/icm-sync.sh --apply projects/<repo>` on
   a clean `.icm/`, and commit the template-owned files on their own. Anything the sync
   reports as *not in the manifest* is a previous pipeline's — `git rm` it in the next
   commit; what it knew that the template does not is re-homed into the project-owned
   files, never edited into a template-owned one.
4. **Read the repo for what the project-owned files need**, so §3 asks only what a file
   cannot answer: the default branch's ruleset (`gh api repos/<o>/<r>/rulesets`) for the
   required check names and the bypass list; the workflows for the other check runs and
   whether drafts run a cheaper tier; a recent PR head's statuses for the deploy projects
   as they name themselves and whether drafts build previews; `package.json` for the
   formatter and linter; the docs tree and its roles page for `docs_path` and the persona
   vocabulary; the mail or chat vendor already wired for what `notify.sh` can send with.

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
*Pipeline setup (1c):* the same rounds settle what the project-owned files need and
the repo cannot answer — who authors requests and where they arrive, how the repo
announces a merge and where its changelog lives, the persona vocabulary where no roles
page exists, which identities may push the front to `main` — asked once, written into
`project-rules.md` and the register alike.
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

**6. Write — the profile's files, the register, then the cut.** In a repo being set up
(1c), the project-owned files come first, on the setup branch: `.icm/project.json`
(`docs_path`, `required_checks` — a name may contain a comma, the array carries it —
`personas`, `required_env`, `smoke_check` only where a preview walk exists, the archives at
the defaults); `_shared/project-rules.md` with every section filled — the operator and
the authors, the verified push identities, the docs tree and code rules, the required
check and its tiering or the absence of one, the other check runs and their class, the
deploy projects and whether drafts preview, the archive, how the repo announces and
where its changelog lives, capability skills or "none"; `_shared/knowledge-map.md` with
the pages named as `validate-knowledge-map.sh` resolves them; `scripts/notify.sh` wired
to the repo's channel or left the stub with the reason; `scripts/format.sh` and
`lint.sh` wired to the repo's own tools over changed files or left as `SKIP` stubs;
`runs/README.md`. Then the repo's own surfaces: `.claude/settings.json` allowlists every
`.icm/scripts/*.sh` (the reference repo's set) and carries no `PIPELINE_REQUIRED_CHECKS`;
`.github/labels.yml` carries the persona axis; a workflow that projects the PR body's
gates is named `(advisory)`; a labels workflow diffs `origin/$BASE_REF...$HEAD_SHA`; Layer
0 and the docs pages that describe delivery say the four stages; the previous pipeline's
files, folders and layouts are removed, not kept. Merged runs still in `.icm/runs/` are
closed out with `close-out.sh` on the branch. That PR is Jamie's to merge; the register
and the cut below go to `main` as usual.
Then `.icm/project.md` per
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
- Declares (or declines) the pipeline profile (1c); merges the setup PR from GitHub.

## Outputs

| Artifact | Lands in |
|---|---|
| `.icm/project.md` (written/amended) | the target repo |
| The pipeline profile's project-owned files and the repo's own surfaces (1c, when declared) | the target repo, on a `claude/` branch — one PR |
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
- A repo set up on the pipeline profile proves it before the PR opens:
  `.icm/scripts/env-check.sh` → `PASS`; `icm-sync.sh --apply` a second time →
  `UNCHANGED`; `icm-check.sh --repo projects/<repo>` → no `missing`, no `pipeline drift`;
  `validate-knowledge-map.sh` → `OK`; `validate-intake.sh` → `OK` on every batch and on
  `triage/`; nothing of a previous pipeline left in the live machinery.
